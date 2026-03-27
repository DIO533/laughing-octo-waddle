function run_complete_analysis()
% RUN_COMPLETE_ANALYSIS 运行完整的再生制动仿真分析
%
% 生成完整图表集并验证数据准确性
% 1-4: 不同工况下的不同策略结果
% 5-6: 不同工况下的策略对比
% 7:   单因素分析综合结果（NEDC工况）
% 8:   单因素分析综合结果（UDDS工况）
%
% 输出:
%   - 8张专业图表
%   - 完整数据验证报告
%   - 性能对比分析

    fprintf('\n========================================\n');
    fprintf('再生制动仿真系统 - 完整分析\n');
    fprintf('========================================\n');
    fprintf('开始时间: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
    fprintf('========================================\n\n');
    
    % 添加路径
    setup_paths();
    
    % 数据存储结构
    analysis_results = struct();
    
    try
        % === 第一阶段：生成单策略图表 ===
        fprintf('📊 第一阶段：生成单策略分析图表\n');
        fprintf('----------------------------------------\n');
        
        % 图表1: NEDC工况 - 基准策略
        fprintf('1/8 生成 NEDC工况-基准策略 图表...\n');
        results_nedc_baseline = main('baseline', 'NEDC', 'plot', false);
        analysis_results.nedc_baseline = results_nedc_baseline;
        visualization_enhanced(results_nedc_baseline, 'single', 1);
        fprintf('    ✓ 效率: %.2f%%, 回收能量: %.4f kWh\n', ...
                results_nedc_baseline.efficiency_average, results_nedc_baseline.energy_recovered);
        
        % 图表2: NEDC工况 - 优化策略
        fprintf('2/8 生成 NEDC工况-优化策略 图表...\n');
        results_nedc_optimized = main('optimized', 'NEDC', 'plot', false);
        analysis_results.nedc_optimized = results_nedc_optimized;
        visualization_enhanced(results_nedc_optimized, 'single', 2);
        fprintf('    ✓ 效率: %.2f%%, 回收能量: %.4f kWh\n', ...
                results_nedc_optimized.efficiency_average, results_nedc_optimized.energy_recovered);
        
        % 图表3: UDDS工况 - 基准策略
        fprintf('3/8 生成 UDDS工况-基准策略 图表...\n');
        results_udds_baseline = main('baseline', 'UDDS', 'plot', false);
        analysis_results.udds_baseline = results_udds_baseline;
        visualization_enhanced(results_udds_baseline, 'single', 3);
        fprintf('    ✓ 效率: %.2f%%, 回收能量: %.4f kWh\n', ...
                results_udds_baseline.efficiency_average, results_udds_baseline.energy_recovered);
        
        % 图表4: UDDS工况 - 优化策略
        fprintf('4/8 生成 UDDS工况-优化策略 图表...\n');
        results_udds_optimized = main('optimized', 'UDDS', 'plot', false);
        analysis_results.udds_optimized = results_udds_optimized;
        visualization_enhanced(results_udds_optimized, 'single', 4);
        fprintf('    ✓ 效率: %.2f%%, 回收能量: %.4f kWh\n', ...
                results_udds_optimized.efficiency_average, results_udds_optimized.energy_recovered);
        
        % === 第二阶段：生成策略对比图表 ===
        fprintf('\n📈 第二阶段：生成策略对比分析图表\n');
        fprintf('----------------------------------------\n');
        
        % 图表5: NEDC工况 - 策略对比
        fprintf('5/8 生成 NEDC工况-策略对比 图表...\n');
        results_nedc_comparison = main('comparison', 'NEDC', 'plot', false);
        analysis_results.nedc_comparison = results_nedc_comparison;
        visualization_enhanced(results_nedc_comparison, 'comparison', 5);
        fprintf('    ✓ 效率提升: %.2f个百分点 (%.1f%%相对提升)\n', ...
                results_nedc_comparison.efficiency_improvement, ...
                results_nedc_comparison.improvement_percentage);
        
        % 图表6: UDDS工况 - 策略对比
        fprintf('6/8 生成 UDDS工况-策略对比 图表...\n');
        results_udds_comparison = main('comparison', 'UDDS', 'plot', false);
        analysis_results.udds_comparison = results_udds_comparison;
        visualization_enhanced(results_udds_comparison, 'comparison', 6);
        fprintf('    ✓ 效率提升: %.2f个百分点 (%.1f%%相对提升)\n', ...
                results_udds_comparison.efficiency_improvement, ...
                results_udds_comparison.improvement_percentage);
        
        % === 第三阶段：单因素分析图表 ===
        fprintf('\n🔬 第三阶段：生成单因素变量法分析图表\n');
        fprintf('----------------------------------------\n');
        
        % 图表7: NEDC工况 - 单因素分析综合图
        fprintf('7/8 生成 NEDC工况-单因素分析 图表...\n');
        results_factor_nedc = main('factor_analysis', 'NEDC', 'plot', false);
        analysis_results.factor_nedc = results_factor_nedc;
        visualization_enhanced(results_factor_nedc, 'factor_analysis', 7);
        fprintf('    ✓ 共分析 %d 个因素\n', length(results_factor_nedc.factors));
        
        % 图表8: UDDS工况 - 单因素分析综合图
        fprintf('8/8 生成 UDDS工况-单因素分析 图表...\n');
        results_factor_udds = main('factor_analysis', 'UDDS', 'plot', false);
        analysis_results.factor_udds = results_factor_udds;
        visualization_enhanced(results_factor_udds, 'factor_analysis', 8);
        fprintf('    ✓ 共分析 %d 个因素\n', length(results_factor_udds.factors));
        
        % === 第四阶段：数据验证和分析报告 ===
        fprintf('\n🔍 第四阶段：数据验证和分析报告\n');
        fprintf('----------------------------------------\n');
        
        % 验证数据一致性
        validate_data_consistency(analysis_results);
        
        % 生成完整分析报告
        generate_analysis_report(analysis_results);
        
        fprintf('\n✅ 完整分析成功完成！\n');
        fprintf('生成图表数量: 8张\n');
        fprintf('完成时间: %s\n', datestr(now, 'yyyy-mm-dd HH:MM:SS'));
        
        % 显示图表窗口信息
        fprintf('\n📊 图表窗口信息:\n');
        fprintf('图表1: NEDC工况-基准策略 (效率: %.2f%%)\n', results_nedc_baseline.efficiency_average);
        fprintf('图表2: NEDC工况-优化策略 (效率: %.2f%%)\n', results_nedc_optimized.efficiency_average);
        fprintf('图表3: UDDS工况-基准策略 (效率: %.2f%%)\n', results_udds_baseline.efficiency_average);
        fprintf('图表4: UDDS工况-优化策略 (效率: %.2f%%)\n', results_udds_optimized.efficiency_average);
        fprintf('图表5: NEDC工况-策略对比 (提升: %.2f个百分点)\n', results_nedc_comparison.efficiency_improvement);
        fprintf('图表6: UDDS工况-策略对比 (提升: %.2f个百分点)\n', results_udds_comparison.efficiency_improvement);
        fprintf('图表7: NEDC工况-单因素分析 (共%d个因素)\n', length(results_factor_nedc.factors));
        fprintf('图表8: UDDS工况-单因素分析 (共%d个因素)\n', length(results_factor_udds.factors));
        
        % 确保所有图表窗口都可见
        for i = 1:8
            if ishandle(i)
                figure(i);
                drawnow;
            end
        end
        
        fprintf('\n💡 提示: 所有8张图表窗口已生成，请检查MATLAB图形窗口\n');
        
    catch ME
        fprintf('\n❌ 分析过程中出现错误:\n');
        fprintf('错误信息: %s\n', ME.message);
        fprintf('错误位置: %s (第%d行)\n', ME.stack(1).name, ME.stack(1).line);
    end
    
end


function setup_paths()
% SETUP_PATHS 设置所有必要的路径
    addpath(genpath('config'));
    addpath(genpath('models'));
    addpath(genpath('controllers'));
    addpath(genpath('utils'));
    addpath(genpath('visualization'));
end


function validate_data_consistency(results)
% VALIDATE_DATA_CONSISTENCY 验证数据一致性
    
    fprintf('验证数据一致性...\n');
    
    % 验证对比结果与单独运行结果的一致性
    tolerance = 0.01; % 1%容差
    
    % NEDC工况验证
    nedc_baseline_diff = abs(results.nedc_comparison.baseline.efficiency_average - ...
                            results.nedc_baseline.efficiency_average);
    nedc_optimized_diff = abs(results.nedc_comparison.optimized.efficiency_average - ...
                             results.nedc_optimized.efficiency_average);
    
    % UDDS工况验证
    udds_baseline_diff = abs(results.udds_comparison.baseline.efficiency_average - ...
                            results.udds_baseline.efficiency_average);
    udds_optimized_diff = abs(results.udds_comparison.optimized.efficiency_average - ...
                             results.udds_optimized.efficiency_average);
    
    % 检查一致性
    if nedc_baseline_diff < tolerance && nedc_optimized_diff < tolerance && ...
       udds_baseline_diff < tolerance && udds_optimized_diff < tolerance
        fprintf('    ✓ 数据一致性验证通过\n');
    else
        fprintf('    ⚠️  数据一致性验证发现差异:\n');
        fprintf('       NEDC基准差异: %.4f%%\n', nedc_baseline_diff);
        fprintf('       NEDC优化差异: %.4f%%\n', nedc_optimized_diff);
        fprintf('       UDDS基准差异: %.4f%%\n', udds_baseline_diff);
        fprintf('       UDDS优化差异: %.4f%%\n', udds_optimized_diff);
    end
    
end
function generate_analysis_report(results)
% GENERATE_ANALYSIS_REPORT 生成完整分析报告
    
    fprintf('生成分析报告...\n');
    
    % 创建报告表格
    fprintf('\n========================================\n');
    fprintf('完整性能分析报告\n');
    fprintf('========================================\n');
    
    % NEDC工况分析
    fprintf('\n📊 NEDC工况分析结果:\n');
    fprintf('----------------------------------------\n');
    fprintf('基准策略:\n');
    fprintf('  能量回收效率: %.2f%%\n', results.nedc_baseline.efficiency_average);
    fprintf('  回收能量: %.4f kWh\n', results.nedc_baseline.energy_recovered);
    fprintf('  总制动能量: %.4f kWh\n', results.nedc_baseline.energy_total);
    fprintf('  制动事件数: %d次\n', results.nedc_baseline.num_brake_events);
    fprintf('  SOC变化: %.2f%% → %.2f%%\n', ...
            results.nedc_baseline.SOC_series(1), results.nedc_baseline.SOC_series(end));
    
    fprintf('\n优化策略:\n');
    fprintf('  能量回收效率: %.2f%%\n', results.nedc_optimized.efficiency_average);
    fprintf('  回收能量: %.4f kWh\n', results.nedc_optimized.energy_recovered);
    fprintf('  总制动能量: %.4f kWh\n', results.nedc_optimized.energy_total);
    fprintf('  制动事件数: %d次\n', results.nedc_optimized.num_brake_events);
    fprintf('  SOC变化: %.2f%% → %.2f%%\n', ...
            results.nedc_optimized.SOC_series(1), results.nedc_optimized.SOC_series(end));
    
    fprintf('\n策略对比:\n');
    fprintf('  效率提升: %.2f个百分点\n', results.nedc_comparison.efficiency_improvement);
    fprintf('  相对提升: %.1f%%\n', results.nedc_comparison.improvement_percentage);
    fprintf('  能量增益: %.4f kWh\n', ...
            results.nedc_optimized.energy_recovered - results.nedc_baseline.energy_recovered);
    
    % UDDS工况分析
    fprintf('\n📊 UDDS工况分析结果:\n');
    fprintf('----------------------------------------\n');
    fprintf('基准策略:\n');
    fprintf('  能量回收效率: %.2f%%\n', results.udds_baseline.efficiency_average);
    fprintf('  回收能量: %.4f kWh\n', results.udds_baseline.energy_recovered);
    fprintf('  总制动能量: %.4f kWh\n', results.udds_baseline.energy_total);
    fprintf('  制动事件数: %d次\n', results.udds_baseline.num_brake_events);
    fprintf('  SOC变化: %.2f%% → %.2f%%\n', ...
            results.udds_baseline.SOC_series(1), results.udds_baseline.SOC_series(end));
    
    fprintf('\n优化策略:\n');
    fprintf('  能量回收效率: %.2f%%\n', results.udds_optimized.efficiency_average);
    fprintf('  回收能量: %.4f kWh\n', results.udds_optimized.energy_recovered);
    fprintf('  总制动能量: %.4f kWh\n', results.udds_optimized.energy_total);
    fprintf('  制动事件数: %d次\n', results.udds_optimized.num_brake_events);
    fprintf('  SOC变化: %.2f%% → %.2f%%\n', ...
            results.udds_optimized.SOC_series(1), results.udds_optimized.SOC_series(end));
    
    fprintf('\n策略对比:\n');
    fprintf('  效率提升: %.2f个百分点\n', results.udds_comparison.efficiency_improvement);
    fprintf('  相对提升: %.1f%%\n', results.udds_comparison.improvement_percentage);
    fprintf('  能量增益: %.4f kWh\n', ...
            results.udds_optimized.energy_recovered - results.udds_baseline.energy_recovered);
    
    % 综合分析
    fprintf('\n🎯 综合分析结论:\n');
    fprintf('----------------------------------------\n');
    
    % 计算平均提升
    avg_absolute_improvement = (results.nedc_comparison.efficiency_improvement + ...
                               results.udds_comparison.efficiency_improvement) / 2;
    avg_relative_improvement = (results.nedc_comparison.improvement_percentage + ...
                               results.udds_comparison.improvement_percentage) / 2;
    
    fprintf('平均效率提升: %.2f个百分点\n', avg_absolute_improvement);
    fprintf('平均相对提升: %.1f%%\n', avg_relative_improvement);
    
    % 工况特性分析
    if results.udds_comparison.improvement_percentage > results.nedc_comparison.improvement_percentage
        fprintf('优化策略在UDDS工况下效果更显著\n');
    else
        fprintf('优化策略在NEDC工况下效果更显著\n');
    end
    
    % 制动特性对比
    fprintf('\n制动特性对比:\n');
    fprintf('  NEDC工况制动频率更高 (%d次 vs %d次)\n', ...
            results.nedc_baseline.num_brake_events, results.udds_baseline.num_brake_events);
    fprintf('  UDDS工况制动强度更大 (%.4f kWh vs %.4f kWh总制动能量)\n', ...
            results.udds_baseline.energy_total, results.nedc_baseline.energy_total);
    
    fprintf('\n========================================\n');
    
end