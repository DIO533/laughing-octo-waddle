function results = main(simulation_mode, driving_cycle, varargin)
% MAIN 再生制动仿真系统主程序
%
% 执行再生制动仿真，支持多种模式和工况
%
% 输入参数:
%   simulation_mode - 仿真模式: 'baseline' | 'optimized' | 'comparison' | 'factor_analysis'
%   driving_cycle   - 驾驶循环: 'NEDC' | 'UDDS'
%   varargin        - 可选参数（名称-值对）
%                     'mass' - 车辆质量 (kg)
%                     'temperature' - 环境温度 (℃)
%                     'slope' - 道路坡度 (%)
%                     'initial_SOC' - 初始SOC (%)
%
% 输出参数:
%   results - 仿真结果结构体
%
% 示例:
%   % 运行基准策略NEDC工况
%   results = main('baseline', 'NEDC');
%
%   % 运行优化策略UDDS工况，指定质量
%   results = main('optimized', 'UDDS', 'mass', 1800);
%
%   % 对比两种策略
%   results = main('comparison', 'NEDC');

    % 添加路径（使用persistent变量避免重复添加）
    persistent paths_added;
    if isempty(paths_added)
        addpath(genpath('config'));
        addpath(genpath('models'));
        addpath(genpath('controllers'));
        addpath(genpath('utils'));
        addpath(genpath('visualization'));
        paths_added = true;
    end
    
    % 加载配置
    config = simulation_config();
    params = vehicle_params();
    
    % 解析可选参数
    p = inputParser;
    addParameter(p, 'mass', params.vehicle.mass_default);
    addParameter(p, 'temperature', params.environment.temperature_default);
    addParameter(p, 'slope', params.environment.slope_default);
    addParameter(p, 'initial_SOC', params.battery.SOC_default * 100);
    addParameter(p, 'plot', config.plot_results);
    parse(p, varargin{:});
    
    % 更新参数
    mass = p.Results.mass;
    temperature = p.Results.temperature;
    slope = p.Results.slope;
    initial_SOC = p.Results.initial_SOC;
    config.plot_results = p.Results.plot;
    
    % 显示仿真信息
    if config.verbose
        fprintf('\n========================================\n');
        fprintf('再生制动仿真系统\n');
        fprintf('========================================\n');
        fprintf('仿真模式: %s\n', simulation_mode);
        fprintf('驾驶循环: %s\n', driving_cycle);
        fprintf('车辆质量: %.0f kg\n', mass);
        fprintf('环境温度: %.0f ℃\n', temperature);
        fprintf('道路坡度: %.1f %%\n', slope);
        fprintf('初始SOC: %.1f %%\n', initial_SOC);
        fprintf('========================================\n\n');
    end
    
    % 根据仿真模式执行
    switch lower(simulation_mode)
        case 'baseline'
            results = run_single_strategy('baseline', driving_cycle, ...
                mass, temperature, slope, initial_SOC, params, config);
            
        case 'optimized'
            results = run_single_strategy('optimized', driving_cycle, ...
                mass, temperature, slope, initial_SOC, params, config);
            
        case 'comparison'
            results = run_comparison(driving_cycle, mass, temperature, ...
                slope, initial_SOC, params, config);
            
        case 'factor_analysis'
            results = run_factor_analysis(driving_cycle, params, config);
            
        otherwise
            error('main:InvalidMode', '不支持的仿真模式: %s', simulation_mode);
    end
    
    % 保存结果（可选）
    if config.save_results
        save_simulation_results(results, simulation_mode, driving_cycle, config);
    end
    
    % 绘制结果
    if config.plot_results
        if strcmpi(simulation_mode, 'factor_analysis')
            visualization_enhanced(results, 'factor_analysis');
        else
            visualization(results, simulation_mode);
        end
    end
    
    % 显示总结
    if config.verbose
        display_summary(results, simulation_mode);
    end
    
end


function results = run_single_strategy(strategy_type, driving_cycle, ...
    mass, temperature, slope, initial_SOC, params, config)
% RUN_SINGLE_STRATEGY 运行单个策略的仿真
    
    % 加载工况数据
    [time, velocity, brake_events] = driving_cycle_data(driving_cycle);
    n = length(time);
    
    % 初始化结果数组
    motor_brake_ratio_series = zeros(n, 1);
    hydraulic_brake_ratio_series = zeros(n, 1);
    motor_power_series = zeros(n, 1);
    brake_power_series = zeros(n, 1);
    SOC_series = zeros(n, 1);
    SOC_series(1) = initial_SOC;
    kinetic_energy_series = zeros(n, 1);
    motor_efficiency_series = zeros(n, 1);
    battery_efficiency_series = zeros(n, 1);
    
    % 预计算常量
    v_ms_series = velocity / 3.6;  % 向量化速度转换
    kinetic_energy_series = 0.5 * mass * v_ms_series.^2;  % 向量化动能计算
    
    % 预计算制动判断（向量化）
    velocity_diff = [0; diff(velocity)];
    is_braking_series = (velocity_diff < -0.5) & (velocity > 1);
    
    % 仿真循环
    for i = 1:n
        if ~is_braking_series(i)
            % 非制动状态 - 快速路径
            if i < n
                SOC_series(i+1) = SOC_series(i);
            end
            continue;
        end
        
        % 制动状态处理
        v = velocity(i);
        SOC = SOC_series(i);
        
        % 计算制动参数
        dv = velocity(i-1) - velocity(i);
        dt = time(i) - time(i-1);
        actual_decel = (dv / 3.6) / dt;
        brake_force_req = mass * actual_decel;
        brake_demand = min(100, (actual_decel / (0.8 * params.vehicle.gravity)) * 100);
        
        % 调用制动力分配策略
        if strcmp(strategy_type, 'baseline')
            [motor_ratio, hydraulic_ratio, motor_force, ~] = ...
                baseline_strategy(brake_demand, v, brake_force_req, params);
        else
            [motor_ratio, hydraulic_ratio, motor_force, ~] = ...
                optimized_strategy(brake_demand, v, SOC, brake_force_req, params);
        end
        
        motor_brake_ratio_series(i) = motor_ratio;
        hydraulic_brake_ratio_series(i) = hydraulic_ratio;
        
        % 计算功率
        motor_power = motor_force * v_ms_series(i) / 1000;
        [~, motor_eff, ~, ~] = motor_model(v, brake_demand, params);
        motor_efficiency_series(i) = motor_eff;
        
        motor_power = motor_power * (motor_eff / 100);
        motor_power_series(i) = motor_power;
        brake_power_series(i) = brake_force_req * v_ms_series(i) / 1000;
        
        % 电池充电
        [~, battery_eff, SOC_new, ~] = battery_model(motor_power, SOC, ...
            temperature, config.sampling_time, params);
        battery_efficiency_series(i) = battery_eff;
        
        if i < n
            SOC_series(i+1) = SOC_new;
        end
    end
    
    % 计算能量回收效率
    [efficiency, energy_recovered, energy_total, efficiency_series] = ...
        efficiency_calculator(motor_power_series, brake_power_series, time, config);
    
    % 组装结果
    results = struct();
    results.strategy_type = strategy_type;
    results.driving_cycle = driving_cycle;
    results.time_series = time;
    results.velocity_series = velocity;
    results.motor_brake_ratio = motor_brake_ratio_series;
    results.hydraulic_brake_ratio = hydraulic_brake_ratio_series;
    results.motor_power_series = motor_power_series;
    results.brake_power_series = brake_power_series;
    results.SOC_series = SOC_series;
    results.kinetic_energy_series = kinetic_energy_series;
    results.motor_efficiency_series = motor_efficiency_series;
    results.battery_efficiency_series = battery_efficiency_series;
    results.efficiency_instant = efficiency_series;
    results.efficiency_average = efficiency;
    results.energy_recovered = energy_recovered;
    results.energy_total = energy_total;
    results.brake_events = brake_events;
    results.num_brake_events = length(brake_events);
    results.parameters.mass = mass;
    results.parameters.temperature = temperature;
    results.parameters.slope = slope;
    results.parameters.initial_SOC = initial_SOC;
    
end


function results = run_comparison(driving_cycle, mass, temperature, ...
    slope, initial_SOC, params, config)
% RUN_COMPARISON 对比基准策略和优化策略
    
    fprintf('运行基准策略...\n');
    results_baseline = run_single_strategy('baseline', driving_cycle, ...
        mass, temperature, slope, initial_SOC, params, config);
    
    fprintf('运行优化策略...\n');
    results_optimized = run_single_strategy('optimized', driving_cycle, ...
        mass, temperature, slope, initial_SOC, params, config);
    
    % 计算效率提升
    efficiency_improvement = results_optimized.efficiency_average - ...
                            results_baseline.efficiency_average;
    improvement_percentage = (efficiency_improvement / results_baseline.efficiency_average) * 100;
    
    % 组装对比结果
    results = struct();
    results.baseline = results_baseline;
    results.optimized = results_optimized;
    results.efficiency_improvement = efficiency_improvement;
    results.improvement_percentage = improvement_percentage;
    results.driving_cycle = driving_cycle;
    
    fprintf('\n对比结果:\n');
    fprintf('  基准策略效率: %.2f%%\n', results_baseline.efficiency_average);
    fprintf('  优化策略效率: %.2f%%\n', results_optimized.efficiency_average);
    fprintf('  效率提升: %.2f 个百分点 (%.1f%%)\n', ...
        efficiency_improvement, improvement_percentage);
    
end


function results = run_factor_analysis(driving_cycle, params, config)
% RUN_FACTOR_ANALYSIS 运行单因素影响分析
    
    fprintf('执行单因素影响分析...\n');
    
    % 定义需要分析的7种因素
    factors = {'mass', 'motor_rpm', 'temperature', 'SOC', 'pedal_travel', 'slope', 'env_temperature'};
    
    % 配置静默模式（避免每次子仿真重复打印和绘图）
    config_silent = config;
    config_silent.plot_results = false;
    config_silent.verbose = false;
    
    results = struct();
    results.driving_cycle = driving_cycle;
    results.factor_results = struct();
    
    for i = 1:length(factors)
        factor = factors{i};
        fprintf('  分析因素 (%d/%d): %s\n', i, length(factors), factor);
        try
            fa_result = factor_analysis(factor, driving_cycle, 'optimized', params, config_silent);
            results.factor_results.(factor) = fa_result;
        catch ME
            fprintf('  警告: 分析 %s 时出错: %s\n', factor, ME.message);
        end
    end
    
    n_done = length(fieldnames(results.factor_results));
    fprintf('单因素分析完成，共分析 %d 种因素\n', n_done);
    
end


function save_simulation_results(results, simulation_mode, driving_cycle, config)
% SAVE_SIMULATION_RESULTS 保存仿真结果
    
    % 创建结果目录
    if ~exist(config.output_dir, 'dir')
        mkdir(config.output_dir);
    end
    
    % 生成文件名
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    filename = sprintf('%s/results_%s_%s_%s.mat', ...
        config.output_dir, simulation_mode, driving_cycle, timestamp);
    
    % 保存
    save(filename, 'results');
    fprintf('结果已保存到: %s\n', filename);
    
end


function display_summary(results, simulation_mode)
% DISPLAY_SUMMARY 显示仿真总结
    
    fprintf('\n========================================\n');
    fprintf('仿真总结\n');
    fprintf('========================================\n');
    
    if strcmp(simulation_mode, 'comparison')
        fprintf('基准策略:\n');
        fprintf('  能量回收效率: %.2f%%\n', results.baseline.efficiency_average);
        fprintf('  回收能量: %.4f kWh\n', results.baseline.energy_recovered);
        fprintf('  总制动能量: %.4f kWh\n', results.baseline.energy_total);
        fprintf('\n优化策略:\n');
        fprintf('  能量回收效率: %.2f%%\n', results.optimized.efficiency_average);
        fprintf('  回收能量: %.4f kWh\n', results.optimized.energy_recovered);
        fprintf('  总制动能量: %.4f kWh\n', results.optimized.energy_total);
        fprintf('\n效率提升: %.2f 个百分点\n', results.efficiency_improvement);
    elseif strcmp(simulation_mode, 'factor_analysis')
        n_done = length(fieldnames(results.factor_results));
        fprintf('驾驶循环: %s\n', results.driving_cycle);
        fprintf('已完成单因素分析数量: %d 种\n', n_done);
    else
        fprintf('能量回收效率: %.2f%%\n', results.efficiency_average);
        fprintf('回收能量: %.4f kWh\n', results.energy_recovered);
        fprintf('总制动能量: %.4f kWh\n', results.energy_total);
        fprintf('制动事件数: %d\n', results.num_brake_events);
    end
    
    fprintf('========================================\n\n');
    
end
