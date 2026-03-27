function verify_charts()
% VERIFY_CHARTS 验证图表生成情况
%
% 检查是否正确生成了6张图表窗口

    fprintf('\n=== 图表验证 ===\n');
    
    % 检查图表窗口
    chart_count = 0;
    chart_info = {};
    
    for i = 1:6
        if ishandle(i) && strcmp(get(i, 'Type'), 'figure')
            chart_count = chart_count + 1;
            fig_name = get(i, 'Name');
            chart_info{end+1} = sprintf('图表%d: %s', i, fig_name);
            fprintf('✓ 图表%d存在: %s\n', i, fig_name);
        else
            fprintf('❌ 图表%d不存在\n', i);
        end
    end
    
    fprintf('\n📊 图表统计:\n');
    fprintf('预期图表数量: 6张\n');
    fprintf('实际图表数量: %d张\n', chart_count);
    
    if chart_count == 6
        fprintf('✅ 图表验证通过 - 所有6张图表已正确生成\n');
        
        % 排列图表窗口
        arrange_chart_windows();
        
    else
        fprintf('❌ 图表验证失败 - 缺少 %d 张图表\n', 6 - chart_count);
        fprintf('💡 建议重新运行: run_complete_analysis() 或 generate_all_charts()\n');
    end
    
    fprintf('\n=== 验证完成 ===\n');
    
end


function arrange_chart_windows()
% ARRANGE_CHART_WINDOWS 排列图表窗口
%
% 将6张图表窗口排列成2行3列的布局

    fprintf('\n🎨 正在排列图表窗口...\n');
    
    % 获取屏幕尺寸
    screen_size = get(0, 'ScreenSize');
    screen_width = screen_size(3);
    screen_height = screen_size(4);
    
    % 计算窗口尺寸 (2行3列布局)
    window_width = floor(screen_width / 3) - 20;
    window_height = floor(screen_height / 2) - 100;
    
    % 排列窗口位置
    positions = [
        10, screen_height/2 + 50;                    % 图表1: 左上
        window_width + 20, screen_height/2 + 50;     % 图表2: 中上  
        2*window_width + 30, screen_height/2 + 50;   % 图表3: 右上
        10, 50;                                      % 图表4: 左下
        window_width + 20, 50;                       % 图表5: 中下
        2*window_width + 30, 50;                     % 图表6: 右下
    ];
    
    % 设置每个图表窗口的位置和大小
    for i = 1:6
        if ishandle(i)
            try
                set(i, 'Position', [positions(i, 1), positions(i, 2), window_width, window_height]);
                figure(i); % 确保窗口可见
                drawnow;
            catch
                fprintf('⚠️  无法排列图表%d\n', i);
            end
        end
    end
    
    fprintf('✅ 图表窗口排列完成\n');
    
end