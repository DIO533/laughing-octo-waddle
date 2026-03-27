%% 安装验证脚本
% 验证再生制动仿真系统是否正确安装并可以运行
%
% 使用方法:
%   1. 在MATLAB中打开此文件
%   2. 点击"运行"按钮或按F5
%   3. 查看输出结果

clear; clc; close all;

fprintf('\n');
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║     再生制动仿真系统 - 安装验证                           ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');

% 显示MATLAB版本信息
fprintf('MATLAB版本: %s\n', version);
fprintf('运行日期: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
fprintf('\n');

%% 步骤1: 检查文件结构
fprintf('【步骤1/6】检查文件结构...\n');
fprintf('─────────────────────────────────────────────────────────\n');

required_files = {
    'config/simulation_config.m', '配置文件';
    'config/vehicle_params.m', '车辆参数';
    'models/vehicle_model.m', '车辆模型';
    'models/motor_model.m', '电机模型';
    'models/battery_model.m', '电池模型';
    'controllers/baseline_strategy.m', '基准策略';
    'controllers/optimized_strategy.m', '优化策略';
    'utils/driving_cycle_data.m', '工况数据';
    'utils/efficiency_calculator.m', '效率计算';
    'utils/factor_analysis.m', '因素分析';
    'visualization/visualization.m', '可视化';
    'main.m', '主程序';
    'example_usage.m', '使用示例'
};

all_files_exist = true;
for i = 1:size(required_files, 1)
    if exist(required_files{i, 1}, 'file')
        fprintf('  ✓ %s (%s)\n', required_files{i, 2}, required_files{i, 1});
    else
        fprintf('  ✗ 缺少: %s (%s)\n', required_files{i, 2}, required_files{i, 1});
        all_files_exist = false;
    end
end

if all_files_exist
    fprintf('  结果: 所有必需文件都存在 ✓\n');
else
    fprintf('  结果: 有文件缺失 ✗\n');
    fprintf('  请确保所有文件都已正确放置\n');
    return;
end
fprintf('\n');

%% 步骤2: 添加路径
fprintf('【步骤2/6】添加路径到MATLAB搜索路径...\n');
fprintf('─────────────────────────────────────────────────────────\n');

try
    addpath(genpath('config'));
    addpath(genpath('models'));
    addpath(genpath('controllers'));
    addpath(genpath('utils'));
    addpath(genpath('visualization'));
    fprintf('  ✓ 路径添加成功\n');
catch ME
    fprintf('  ✗ 路径添加失败: %s\n', ME.message);
    return;
end
fprintf('\n');

%% 步骤3: 加载配置
fprintf('【步骤3/6】加载配置文件...\n');
fprintf('─────────────────────────────────────────────────────────\n');

try
    config = simulation_config();
    fprintf('  ✓ 仿真配置加载成功\n');
    fprintf('    - 采样时间: %.2f 秒\n', config.sampling_time);
    fprintf('    - 默认工况: %s\n', config.driving_cycle);
catch ME
    fprintf('  ✗ 配置加载失败: %s\n', ME.message);
    return;
end

try
    params = vehicle_params();
    fprintf('  ✓ 车辆参数加载成功\n');
    fprintf('    - 车辆质量: %.0f kg\n', params.vehicle.mass_default);
    fprintf('    - 电池容量: %.1f kWh\n', params.battery.capacity);
    fprintf('    - 电机功率: %.0f kW\n', params.motor.rated_power);
catch ME
    fprintf('  ✗ 参数加载失败: %s\n', ME.message);
    return;
end
fprintf('\n');

%% 步骤4: 测试核心功能
fprintf('【步骤4/6】测试核心功能模块...\n');
fprintf('─────────────────────────────────────────────────────────\n');

% 测试工况数据
try
    [time, velocity, brake_events] = driving_cycle_data('NEDC');
    fprintf('  ✓ NEDC工况数据生成成功 (%d秒, %d个制动事件)\n', ...
        length(time), length(brake_events));
catch ME
    fprintf('  ✗ 工况数据生成失败: %s\n', ME.message);
    return;
end

% 测试车辆模型
try
    [F, E, a] = vehicle_model(60, 1500, 0, params);
    fprintf('  ✓ 车辆模型运行正常\n');
catch ME
    fprintf('  ✗ 车辆模型失败: %s\n', ME.message);
    return;
end

% 测试电机模型
try
    [T, eta, P, rpm] = motor_model(60, 50, params);
    fprintf('  ✓ 电机模型运行正常\n');
catch ME
    fprintf('  ✗ 电机模型失败: %s\n', ME.message);
    return;
end

% 测试电池模型
try
    [E, eta, SOC_new, P] = battery_model(10, 60, 25, 0.1, params);
    fprintf('  ✓ 电池模型运行正常\n');
catch ME
    fprintf('  ✗ 电池模型失败: %s\n', ME.message);
    return;
end

% 测试控制策略
try
    [r_m, r_h, F_m, F_h] = baseline_strategy(50, 60, 5000, params);
    fprintf('  ✓ 基准策略运行正常\n');
catch ME
    fprintf('  ✗ 基准策略失败: %s\n', ME.message);
    return;
end

try
    [r_m, r_h, F_m, F_h] = optimized_strategy(50, 60, 70, 5000, params);
    fprintf('  ✓ 优化策略运行正常\n');
catch ME
    fprintf('  ✗ 优化策略失败: %s\n', ME.message);
    return;
end

fprintf('\n');

%% 步骤5: 运行快速仿真测试
fprintf('【步骤5/6】运行快速仿真测试...\n');
fprintf('─────────────────────────────────────────────────────────\n');
fprintf('  正在运行基准策略NEDC工况仿真...\n');

try
    % 修改配置以加快测试
    config_test = config;
    config_test.plot_results = false;
    config_test.save_results = false;
    config_test.verbose = false;
    
    tic;
    results = main('baseline', 'NEDC');
    elapsed_time = toc;
    
    fprintf('  ✓ 仿真运行成功\n');
    fprintf('    - 运行时间: %.2f 秒\n', elapsed_time);
    fprintf('    - 能量回收效率: %.2f%%\n', results.efficiency_average);
    fprintf('    - 回收能量: %.4f kWh\n', results.energy_recovered);
    fprintf('    - 总制动能量: %.4f kWh\n', results.energy_total);
    fprintf('    - 制动事件: %d 次\n', results.num_brake_events);
    
    % 验证结果合理性
    if results.efficiency_average > 0 && results.efficiency_average < 100
        fprintf('  ✓ 仿真结果在合理范围内\n');
    else
        fprintf('  ⚠ 警告: 效率值可能不合理 (%.2f%%)\n', results.efficiency_average);
    end
    
    close all; % 关闭所有图表
    
catch ME
    fprintf('  ✗ 仿真失败: %s\n', ME.message);
    if ~isempty(ME.stack)
        fprintf('  错误位置: %s (行 %d)\n', ME.stack(1).name, ME.stack(1).line);
    end
    return;
end

fprintf('\n');

%% 步骤6: 测试可视化
fprintf('【步骤6/6】测试可视化功能...\n');
fprintf('─────────────────────────────────────────────────────────\n');

try
    % 测试中文字体
    if exist('setup_chinese_font', 'file')
        font_name = setup_chinese_font();
        fprintf('  ✓ 中文字体设置成功: %s\n', font_name);
    else
        fprintf('  ⚠ setup_chinese_font.m 不存在，使用默认字体\n');
    end
    
    % 创建测试图表
    figure('Visible', 'off', 'Name', '测试图表');
    plot([1 2 3], [1 4 9]);
    title('测试标题 - Test Title');
    xlabel('横轴');
    ylabel('纵轴');
    close all;
    
    fprintf('  ✓ 可视化功能正常\n');
catch ME
    fprintf('  ⚠ 可视化测试警告: %s\n', ME.message);
    fprintf('  提示: 图表功能可能受限，但不影响仿真计算\n');
end

fprintf('\n');

%% 总结
fprintf('╔════════════════════════════════════════════════════════════╗\n');
fprintf('║     验证完成                                               ║\n');
fprintf('╚════════════════════════════════════════════════════════════╝\n');
fprintf('\n');
fprintf('✓ 所有核心功能测试通过！\n');
fprintf('\n');
fprintf('系统已准备就绪，您可以:\n');
fprintf('  1. 运行 example_usage.m 查看完整示例\n');
fprintf('  2. 运行 main(''comparison'', ''NEDC'') 进行策略对比\n');
fprintf('  3. 查看 README.md 了解详细使用说明\n');
fprintf('  4. 查看 QUICKSTART.md 快速入门\n');
fprintf('\n');
fprintf('推荐的第一步:\n');
fprintf('  >> results = main(''comparison'', ''NEDC'');\n');
fprintf('\n');
fprintf('祝您使用愉快！\n');
fprintf('\n');
