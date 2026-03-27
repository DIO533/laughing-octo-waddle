function demo(demo_type)
% DEMO 再生制动仿真系统演示
%
% 提供多种演示模式，展示系统功能
%
% 输入参数:
%   demo_type - 演示类型 (可选):
%               'quick'      - 快速演示 (默认)
%               'baseline'   - 基准策略演示
%               'optimized'  - 优化策略演示
%               'comparison' - 策略对比演示
%               'all'        - 完整演示
%
% 示例:
%   demo()              % 快速演示
%   demo('baseline')    % 基准策略演示
%   demo('comparison')  % 策略对比演示
%   demo('all')         % 完整演示

    if nargin < 1
        demo_type = 'quick';
    end
    
    fprintf('\n=== 再生制动仿真系统演示 ===\n');
    fprintf('演示类型: %s\n', demo_type);
    fprintf('时间: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf('=====================================\n\n');
    
    % 添加路径
    setup_paths();
    
    % 根据演示类型执行
    switch lower(demo_type)
        case 'quick'
            quick_demo();
        case 'baseline'
            baseline_demo();
        case 'optimized'
            optimized_demo();
        case 'comparison'
            comparison_demo();
        case 'all'
            full_demo();
        otherwise
            fprintf('未知的演示类型: %s\n', demo_type);
            fprintf('可用类型: quick, baseline, optimized, comparison, all\n');
            return;
    end
    
    fprintf('\n=== 演示完成 ===\n');
    fprintf('感谢使用再生制动仿真系统！\n\n');
    
end

function setup_paths()
% 设置路径
    addpath(genpath('config'));
    addpath(genpath('models'));
    addpath(genpath('controllers'));
    addpath(genpath('utils'));
    addpath(genpath('visualization'));
end

function quick_demo()
% 快速演示
    fprintf('🚀 快速演示 - 基准策略 NEDC工况\n');
    fprintf('预计时间: 30秒\n\n');
    
    tic;
    results = main('baseline', 'NEDC');
    elapsed = toc;
    
    fprintf('\n📊 演示结果:\n');
    fprintf('  策略类型: %s\n', results.strategy_type);
    fprintf('  工况循环: %s\n', results.driving_cycle);
    fprintf('  能量回收效率: %.2f%%\n', results.efficiency_average);
    fprintf('  制动事件数: %d\n', results.num_brake_events);
    fprintf('  仿真时间: %.1f秒\n', elapsed);
end

function baseline_demo()
% 基准策略演示
    fprintf('📈 基准策略演示\n');
    fprintf('测试NEDC和UDDS两种工况\n\n');
    
    % NEDC工况
    fprintf('1. NEDC工况测试...\n');
    results_nedc = main('baseline', 'NEDC');
    
    % UDDS工况
    fprintf('\n2. UDDS工况测试...\n');
    results_udds = main('baseline', 'UDDS');
    
    % 结果对比
    fprintf('\n📊 基准策略结果对比:\n');
    fprintf('  NEDC工况: %.2f%% 效率\n', results_nedc.efficiency_average);
    fprintf('  UDDS工况: %.2f%% 效率\n', results_udds.efficiency_average);
end

function optimized_demo()
% 优化策略演示
    fprintf('🎯 优化策略演示\n');
    fprintf('测试模糊逻辑控制策略\n\n');
    
    % NEDC工况
    fprintf('1. NEDC工况测试...\n');
    results_nedc = main('optimized', 'NEDC');
    
    % UDDS工况
    fprintf('\n2. UDDS工况测试...\n');
    results_udds = main('optimized', 'UDDS');
    
    % 结果展示
    fprintf('\n📊 优化策略结果:\n');
    fprintf('  NEDC工况: %.2f%% 效率\n', results_nedc.efficiency_average);
    fprintf('  UDDS工况: %.2f%% 效率\n', results_udds.efficiency_average);
end

function comparison_demo()
% 策略对比演示
    fprintf('⚖️  策略对比演示\n');
    fprintf('对比基准策略与优化策略性能\n\n');
    
    % NEDC工况对比
    fprintf('1. NEDC工况策略对比...\n');
    results_nedc = main('comparison', 'NEDC');
    
    % UDDS工况对比
    fprintf('\n2. UDDS工况策略对比...\n');
    results_udds = main('comparison', 'UDDS');
    
    % 综合结果
    fprintf('\n📊 策略对比总结:\n');
    fprintf('NEDC工况:\n');
    fprintf('  基准策略: %.2f%%\n', results_nedc.baseline.efficiency_average);
    fprintf('  优化策略: %.2f%%\n', results_nedc.optimized.efficiency_average);
    fprintf('  效率提升: %.2f个百分点\n', results_nedc.efficiency_improvement);
    
    fprintf('UDDS工况:\n');
    fprintf('  基准策略: %.2f%%\n', results_udds.baseline.efficiency_average);
    fprintf('  优化策略: %.2f%%\n', results_udds.optimized.efficiency_average);
    fprintf('  效率提升: %.2f个百分点\n', results_udds.efficiency_improvement);
end

function full_demo()
% 完整演示
    fprintf('🎪 完整系统演示\n');
    fprintf('展示所有功能模块\n\n');
    
    fprintf('第1部分: 基准策略演示\n');
    fprintf('------------------------\n');
    baseline_demo();
    
    fprintf('\n第2部分: 优化策略演示\n');
    fprintf('------------------------\n');
    optimized_demo();
    
    fprintf('\n第3部分: 策略对比演示\n');
    fprintf('------------------------\n');
    comparison_demo();
    
    fprintf('\n🎉 完整演示结束！\n');
end