function results = factor_analysis(factor_type, driving_cycle, strategy_type, params, config)
% FACTOR_ANALYSIS 单因素影响分析（优化版）
%
% 分析不同因素对能量回收效率的影响
%
% 输入参数:
%   factor_type   - 因素类型: 'mass' | 'motor_rpm' | 'temperature' | 
%                   'SOC' | 'pedal_travel' | 'slope' | 'env_temperature'
%   driving_cycle - 驾驶循环: 'NEDC' | 'UDDS'
%   strategy_type - 策略类型: 'baseline' | 'optimized'
%   params        - 车辆参数结构体
%   config        - 仿真配置结构体
%
% 输出参数:
%   results - 分析结果结构体
%
% 示例:
%   params = vehicle_params();
%   config = simulation_config();
%   results = factor_analysis('mass', 'NEDC', 'optimized', params, config);

    fprintf('\n执行单因素分析: %s\n', factor_type);
    fprintf('========================================\n');
    
    % 获取因素配置（使用查找表优化）
    factor_config = get_factor_config(factor_type, params);
    
    % 初始化结果数组
    n_values = length(factor_config.values);
    efficiency_values = zeros(n_values, 1);
    energy_recovered_values = zeros(n_values, 1);
    energy_total_values = zeros(n_values, 1);
    
    % 预加载工况数据（避免重复加载）
    [time, velocity, ~] = driving_cycle_data(driving_cycle);
    
    % 配置静默模式
    config_temp = config;
    config_temp.verbose = false;
    config_temp.plot_results = false;
    
    % 对每个因素值运行仿真
    for i = 1:n_values
        value = factor_config.values(i);
        fprintf('测试 %s = %.2f %s ... ', factor_config.name, value, factor_config.unit);
        
        % 设置仿真参数
        sim_params = get_simulation_params(factor_type, value, params);
        
        % 运行仿真
        sim_results = run_single_strategy_silent(strategy_type, time, velocity, ...
            sim_params.mass, sim_params.temperature, sim_params.slope, ...
            sim_params.initial_SOC, params, config_temp);
        
        % 记录结果
        efficiency_values(i) = sim_results.efficiency_average;
        energy_recovered_values(i) = sim_results.energy_recovered;
        energy_total_values(i) = sim_results.energy_total;
        
        fprintf('效率 = %.2f%%\n', efficiency_values(i));
    end
    
    % 查找基准值对应的效率
    [~, baseline_idx] = min(abs(factor_config.values - factor_config.baseline));
    baseline_efficiency = efficiency_values(baseline_idx);
    
    % 组装结果
    results = struct();
    results.factor_name = factor_config.name;
    results.factor_unit = factor_config.unit;
    results.factor_values = factor_config.values;
    results.efficiency_values = efficiency_values;
    results.energy_recovered_values = energy_recovered_values;
    results.energy_total_values = energy_total_values;
    results.baseline_value = factor_config.baseline;
    results.baseline_efficiency = baseline_efficiency;
    results.strategy_type = strategy_type;
    results.driving_cycle = driving_cycle;
    
    % 显示总结
    display_factor_summary(results);
    
end


function factor_config = get_factor_config(factor_type, params)
% GET_FACTOR_CONFIG 获取因素配置（查找表方式）
    
    % 因素配置查找表
    configs = struct(...
        'mass', struct('name', '车辆质量', 'unit', 'kg', ...
                      'values', params.factor_analysis.mass_values, ...
                      'baseline', params.vehicle.mass_default), ...
        'motor_rpm', struct('name', '电机转速', 'unit', 'rpm', ...
                           'values', params.factor_analysis.motor_rpm_values, ...
                           'baseline', 4000), ...
        'temperature', struct('name', '电池温度', 'unit', '℃', ...
                             'values', params.factor_analysis.temperature_values, ...
                             'baseline', 25), ...
        'soc', struct('name', '电池SOC', 'unit', '%', ...
                     'values', params.factor_analysis.SOC_values * 100, ...
                     'baseline', 60), ...
        'pedal_travel', struct('name', '制动踏板行程', 'unit', '%', ...
                              'values', params.factor_analysis.pedal_travel_values, ...
                              'baseline', 50), ...
        'slope', struct('name', '道路坡度', 'unit', '%', ...
                       'values', params.factor_analysis.slope_values, ...
                       'baseline', 0), ...
        'env_temperature', struct('name', '环境温度', 'unit', '℃', ...
                                 'values', params.factor_analysis.env_temperature_values, ...
                                 'baseline', 25) ...
    );
    
    if isfield(configs, lower(factor_type))
        factor_config = configs.(lower(factor_type));
    else
        error('factor_analysis:InvalidFactor', '不支持的因素类型: %s', factor_type);
    end
end


function sim_params = get_simulation_params(factor_type, value, params)
% GET_SIMULATION_PARAMS 根据因素类型设置仿真参数
    
    % 默认参数
    sim_params.mass = params.vehicle.mass_default;
    sim_params.temperature = params.environment.temperature_default;
    sim_params.slope = params.environment.slope_default;
    sim_params.initial_SOC = params.battery.SOC_default * 100;
    
    % 根据因素类型修改相应参数
    switch lower(factor_type)
        case 'mass'
            sim_params.mass = value;
        case {'temperature', 'env_temperature'}
            sim_params.temperature = value;
        case 'soc'
            sim_params.initial_SOC = value;
        case 'slope'
            sim_params.slope = value;
    end
end


function display_factor_summary(results)
% DISPLAY_FACTOR_SUMMARY 显示因素分析总结
    
    fprintf('\n分析总结:\n');
    fprintf('  因素: %s\n', results.factor_name);
    fprintf('  基准值: %.2f %s, 效率: %.2f%%\n', ...
        results.baseline_value, results.factor_unit, results.baseline_efficiency);
    
    [max_eff, max_idx] = max(results.efficiency_values);
    [min_eff, min_idx] = min(results.efficiency_values);
    
    fprintf('  最高效率: %.2f%% (在 %.2f %s)\n', ...
        max_eff, results.factor_values(max_idx), results.factor_unit);
    fprintf('  最低效率: %.2f%% (在 %.2f %s)\n', ...
        min_eff, results.factor_values(min_idx), results.factor_unit);
    fprintf('  效率变化范围: %.2f%%\n', max_eff - min_eff);
    fprintf('========================================\n\n');
end


function results = run_single_strategy_silent(strategy_type, time, velocity, ...
    mass, temperature, slope, initial_SOC, params, config)
% RUN_SINGLE_STRATEGY_SILENT 静默运行单个策略（优化版）
    
    n = length(time);
    
    % 初始化结果数组
    motor_power_series = zeros(n, 1);
    brake_power_series = zeros(n, 1);
    SOC_series = zeros(n, 1);
    SOC_series(1) = initial_SOC;
    
    % 预计算制动判断
    velocity_diff = [0; diff(velocity)];
    is_braking_series = (velocity_diff < -0.5) & (velocity > 1);
    v_ms_series = velocity / 3.6;
    
    % 仿真循环
    for i = 1:n
        if ~is_braking_series(i)
            if i < n
                SOC_series(i+1) = SOC_series(i);
            end
            continue;
        end
        
        v = velocity(i);
        SOC = SOC_series(i);
        
        % 简化的制动力计算
        dv = velocity(i-1) - velocity(i);
        brake_demand = min(100, dv * 10);
        brake_force_req = mass * (dv / 3.6) / (time(i) - time(i-1));
        
        % 策略选择
        if strcmp(strategy_type, 'baseline')
            [motor_ratio, ~, ~, ~] = baseline_strategy(brake_demand, v, brake_force_req, params);
        else
            [motor_ratio, ~, ~, ~] = optimized_strategy(brake_demand, v, SOC, brake_force_req, params);
        end
        
        % 功率计算
        [~, ~, motor_power, ~] = motor_model(v, brake_demand, params);
        motor_power_series(i) = motor_power * (motor_ratio / 100);
        brake_power_series(i) = brake_force_req * v_ms_series(i) / 1000;
        
        % 电池更新
        [~, ~, SOC_new, ~] = battery_model(motor_power_series(i), SOC, ...
            temperature, config.sampling_time, params);
        
        if i < n
            SOC_series(i+1) = SOC_new;
        end
    end
    
    % 计算效率
    [efficiency, energy_recovered, energy_total, ~] = ...
        efficiency_calculator(motor_power_series, brake_power_series, time, config);
    
    results = struct();
    results.efficiency_average = efficiency;
    results.energy_recovered = energy_recovered;
    results.energy_total = energy_total;
    
end
