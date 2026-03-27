%% 再生制动仿真系统使用示例
% 
% 本脚本展示如何使用再生制动仿真系统进行各种分析
% 
% 作者: 再生制动仿真系统开发团队
% 日期: 2026年3月

%% 清理环境
clear; clc; close all;

fprintf('=== 再生制动仿真系统使用示例 ===\n\n');

%% 示例1: 快速开始 - 基准策略
fprintf('示例1: 基准策略 NEDC工况仿真\n');
fprintf('--------------------------------\n');

% 运行基准策略
results1 = main('baseline', 'NEDC');

fprintf('✓ 基准策略仿真完成\n');
fprintf('  能量回收效率: %.2f%%\n', results1.efficiency_average);
fprintf('  制动事件数: %d\n\n', results1.num_brake_events);

%% 示例2: 优化策略演示
fprintf('示例2: 优化策略 NEDC工况仿真\n');
fprintf('--------------------------------\n');

% 运行优化策略
results2 = main('optimized', 'NEDC');

fprintf('✓ 优化策略仿真完成\n');
fprintf('  能量回收效率: %.2f%%\n', results2.efficiency_average);
fprintf('  制动事件数: %d\n\n', results2.num_brake_events);

%% 示例3: 策略对比
fprintf('示例3: 策略对比分析\n');
fprintf('--------------------\n');

% 对比两种策略
results3 = main('comparison', 'NEDC');

fprintf('✓ 策略对比完成\n');
fprintf('  基准策略效率: %.2f%%\n', results3.baseline.efficiency_average);
fprintf('  优化策略效率: %.2f%%\n', results3.optimized.efficiency_average);
fprintf('  效率提升: %.2f个百分点\n\n', results3.efficiency_improvement);

%% 示例4: 不同工况测试
fprintf('示例4: UDDS工况测试\n');
fprintf('-------------------\n');

% 测试UDDS工况
results4 = main('comparison', 'UDDS');

fprintf('✓ UDDS工况对比完成\n');
fprintf('  基准策略效率: %.2f%%\n', results4.baseline.efficiency_average);
fprintf('  优化策略效率: %.2f%%\n', results4.optimized.efficiency_average);
fprintf('  效率提升: %.2f个百分点\n\n', results4.efficiency_improvement);

%% 示例5: 自定义参数
fprintf('示例5: 自定义参数仿真\n');
fprintf('---------------------\n');

% 使用自定义参数
results5 = main('baseline', 'NEDC', 'mass', 1800, 'temperature', 0);

fprintf('✓ 自定义参数仿真完成\n');
fprintf('  车辆质量: 1800kg\n');
fprintf('  环境温度: 0℃\n');
fprintf('  能量回收效率: %.2f%%\n\n', results5.efficiency_average);

%% 总结
fprintf('=== 示例演示完成 ===\n');
fprintf('所有功能模块运行正常！\n');
fprintf('\n更多功能:\n');
fprintf('  - 运行 demo() 查看演示\n');
fprintf('  - 运行 clean_results() 清理结果\n');
fprintf('  - 查看 README.md 了解详细信息\n\n');