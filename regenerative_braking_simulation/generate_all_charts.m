function generate_all_charts()
% GENERATE_ALL_CHARTS 生成所有需要的图表
%
% 生成8张图表：
% 1. NEDC工况 - 基准策略
% 2. NEDC工况 - 优化策略  
% 3. UDDS工况 - 基准策略
% 4. UDDS工况 - 优化策略
% 5. NEDC工况 - 策略对比
% 6. UDDS工况 - 策略对比
% 7. NEDC工况 - 单因素分析综合图
% 8. UDDS工况 - 单因素分析综合图
%
% 注意：推荐使用 run_complete_analysis() 获得更完整的分析

    fprintf('\n=== 快速图表生成 ===\n');
    fprintf('生成8张图表...\n');
    fprintf('提示：使用 run_complete_analysis() 可获得完整分析报告\n\n');
    
    % 添加路径
    addpath(genpath('config'));
    addpath(genpath('models'));
    addpath(genpath('controllers'));
    addpath(genpath('utils'));
    addpath(genpath('visualization'));
    
    try
        % 1. NEDC工况 - 基准策略
        fprintf('1/8 生成 NEDC工况-基准策略 图表...\n');
        results1 = main('baseline', 'NEDC', 'plot', false);
        visualization_enhanced(results1, 'single', 1);
        
        % 2. NEDC工况 - 优化策略
        fprintf('2/8 生成 NEDC工况-优化策略 图表...\n');
        results2 = main('optimized', 'NEDC', 'plot', false);
        visualization_enhanced(results2, 'single', 2);
        
        % 3. UDDS工况 - 基准策略
        fprintf('3/8 生成 UDDS工况-基准策略 图表...\n');
        results3 = main('baseline', 'UDDS', 'plot', false);
        visualization_enhanced(results3, 'single', 3);
        
        % 4. UDDS工况 - 优化策略
        fprintf('4/8 生成 UDDS工况-优化策略 图表...\n');
        results4 = main('optimized', 'UDDS', 'plot', false);
        visualization_enhanced(results4, 'single', 4);
        
        % 5. NEDC工况 - 策略对比
        fprintf('5/8 生成 NEDC工况-策略对比 图表...\n');
        results5 = main('comparison', 'NEDC', 'plot', false);
        visualization_enhanced(results5, 'comparison', 5);
        
        % 6. UDDS工况 - 策略对比
        fprintf('6/8 生成 UDDS工况-策略对比 图表...\n');
        results6 = main('comparison', 'UDDS', 'plot', false);
        visualization_enhanced(results6, 'comparison', 6);
        
        % 7. NEDC工况 - 单因素分析综合图
        fprintf('7/8 生成 NEDC工况-单因素分析 图表...\n');
        results7 = main('factor_analysis', 'NEDC', 'plot', false);
        visualization_enhanced(results7, 'factor_analysis', 7);
        
        % 8. UDDS工况 - 单因素分析综合图
        fprintf('8/8 生成 UDDS工况-单因素分析 图表...\n');
        results8 = main('factor_analysis', 'UDDS', 'plot', false);
        visualization_enhanced(results8, 'factor_analysis', 8);
        
        fprintf('\n✅ 所有8张图表生成完成！\n');
        fprintf('💡 提示：运行 run_complete_analysis() 可获得详细分析报告\n');
        
        % 显示图表窗口信息
        fprintf('\n📊 生成的图表窗口:\n');
        fprintf('图表1: NEDC工况-基准策略\n');
        fprintf('图表2: NEDC工况-优化策略\n');
        fprintf('图表3: UDDS工况-基准策略\n');
        fprintf('图表4: UDDS工况-优化策略\n');
        fprintf('图表5: NEDC工况-策略对比\n');
        fprintf('图表6: UDDS工况-策略对比\n');
        fprintf('图表7: NEDC工况-单因素分析\n');
        fprintf('图表8: UDDS工况-单因素分析\n');
        
        % 确保所有图表窗口都可见
        for i = 1:8
            if ishandle(i)
                figure(i);
                drawnow;
            end
        end
        
        fprintf('\n💡 提示: 所有8张图表窗口已生成，请检查MATLAB图形窗口\n');
        
    catch ME
        fprintf('❌ 生成图表时出错: %s\n', ME.message);
    end
    
end