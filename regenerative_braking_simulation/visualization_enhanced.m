function visualization_enhanced(results, plot_type, figure_number)
% VISUALIZATION_ENHANCED 增强版数据可视化
%
% 专门优化制动力分配比例和电池SOC变化图表的显示效果
%
% 输入参数:
%   results       - 仿真结果结构体
%   plot_type     - 图表类型: 'single' | 'comparison'
%   figure_number - 图表编号 (可选，用于生成多个独立窗口)

    % 设置专业图表样式
    setup_professional_style();
    
    % 设置中文字体
    setup_chinese_font_enhanced();
    
    % 确定图表编号
    if nargin < 3
        figure_number = [];
    end
    
    % 根据图表类型绘制
    switch lower(plot_type)
        case {'single', 'baseline', 'optimized'}
            plot_single_strategy_enhanced(results, figure_number);
            
        case 'comparison'
            plot_comparison_enhanced(results, figure_number);
            
        otherwise
            % 自动识别结果类型
            if isfield(results, 'baseline') && isfield(results, 'optimized')
                plot_comparison_enhanced(results, figure_number);
            else
                plot_single_strategy_enhanced(results, figure_number);
            end
    end
    
end


function plot_single_strategy_enhanced(results, figure_number)
% PLOT_SINGLE_STRATEGY_ENHANCED 绘制增强版单个策略结果
    
    % 创建主窗口 - 使用指定的图表编号
    if isempty(figure_number)
        fig = figure('Name', sprintf('再生制动仿真结果 - %s策略 (%s工况)', ...
               results.strategy_type, results.driving_cycle), ...
               'Position', [100, 100, 1400, 900], 'Color', 'white');
    else
        % 计算窗口位置，避免重叠
        pos_x = 50 + (figure_number - 1) * 100;
        pos_y = 50 + (figure_number - 1) * 50;
        
        fig = figure(figure_number);
        set(fig, 'Name', sprintf('图表%d: %s策略 - %s工况', figure_number, ...
                results.strategy_type, results.driving_cycle), ...
                'Position', [pos_x, pos_y, 1400, 900], 'Color', 'white');
    end
    
    % 定义专业配色方案
    colors = get_color_scheme_enhanced();
    
    % 子图1: 车速-时间曲线
    subplot(3, 3, [1, 2]);
    plot(results.time_series, results.velocity_series, 'Color', colors.primary, ...
         'LineWidth', 2.5, 'DisplayName', '车速');
    enhance_subplot('时间 (s)', '车速 (km/h)', '车速-时间曲线');
    
    % 标注制动事件
    if isfield(results, 'brake_events') && ~isempty(results.brake_events)
        hold on;
        for i = 1:min(5, length(results.brake_events))
            event = results.brake_events(i);
            if event.start_idx <= length(results.time_series)
                plot(results.time_series(event.start_idx), ...
                     results.velocity_series(event.start_idx), ...
                     'ro', 'MarkerSize', 6, 'MarkerFaceColor', colors.accent);
            end
        end
        legend('车速', '制动事件', 'Location', 'best');
    end
    
    % 子图2: 能量回收效率-时间曲线
    subplot(3, 3, 3);
    plot(results.time_series, results.efficiency_instant, 'Color', colors.secondary, ...
         'LineWidth', 2, 'DisplayName', '瞬时效率');
    hold on;
    yline(results.efficiency_average, '--', 'Color', colors.accent, 'LineWidth', 2.5, ...
          'DisplayName', sprintf('平均效率 (%.2f%%)', results.efficiency_average));
    enhance_subplot('时间 (s)', '效率 (%)', '能量回收效率');
    legend('Location', 'best');
    
    % 子图3: 制动力分配比例（增强版堆叠面积图）
    subplot(3, 3, [4, 5]);
    create_enhanced_brake_force_chart(results, colors);
    
    % 子图4: 电池SOC变化（增强版）
    subplot(3, 3, 6);
    create_enhanced_soc_chart(results, colors);
    
    % 子图5: 功率曲线对比
    subplot(3, 3, [7, 8]);
    plot(results.time_series, results.motor_power_series, 'Color', colors.primary, ...
         'LineWidth', 2, 'DisplayName', '电机功率');
    hold on;
    plot(results.time_series, results.brake_power_series, 'Color', colors.secondary, ...
         'LineWidth', 2, 'DisplayName', '制动功率');
    enhance_subplot('时间 (s)', '功率 (kW)', '功率曲线对比');
    legend('Location', 'best');
    
    % 子图6: 效率统计饼图
    subplot(3, 3, 9);
    create_efficiency_pie_chart(results, colors);
    
    % 添加专业的标题和信息面板
    add_info_panel_enhanced(fig, results);
    
end

function create_enhanced_brake_force_chart(results, colors)
% CREATE_ENHANCED_BRAKE_FORCE_CHART 创建增强版制动力分配图表
%
% 详细说明制动力分配的含义和变化

    % 找出制动时刻
    brake_indices = find(results.motor_brake_ratio > 0 | results.hydraulic_brake_ratio > 0);
    
    if isempty(brake_indices)
        % 如果没有制动数据，显示说明
        text(0.5, 0.5, '本工况下无制动事件', 'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle', 'FontSize', 14, 'FontWeight', 'bold');
        set(gca, 'XLim', [0, 1], 'YLim', [0, 1]);
        title('制动力分配比例', 'FontSize', 12, 'FontWeight', 'bold');
        return;
    end
    
    % 创建堆叠面积图
    time_brake = results.time_series(brake_indices);
    motor_ratio_brake = results.motor_brake_ratio(brake_indices);
    hydraulic_ratio_brake = results.hydraulic_brake_ratio(brake_indices);
    
    % 绘制堆叠面积图
    area_data = [motor_ratio_brake, hydraulic_ratio_brake];
    h_area = area(time_brake, area_data, 'LineWidth', 1);
    
    % 设置颜色 - 电机制动用绿色（环保），液压制动用橙色
    h_area(1).FaceColor = colors.motor_brake;    % 绿色 - 电机制动（再生制动）
    h_area(1).FaceAlpha = 0.8;
    h_area(2).FaceColor = colors.hydraulic_brake; % 橙色 - 液压制动（摩擦制动）
    h_area(2).FaceAlpha = 0.8;
    
    % 添加平均值线
    hold on;
    avg_motor = mean(motor_ratio_brake);
    avg_hydraulic = mean(hydraulic_ratio_brake);
    
    yline(avg_motor, '--', 'Color', colors.motor_brake, 'LineWidth', 2, ...
          'DisplayName', sprintf('平均电机制动: %.1f%%', avg_motor));
    
    enhance_subplot('时间 (s)', '制动力占比 (%)', '制动力分配比例');
    legend('电机制动 (再生)', '液压制动 (摩擦)', sprintf('平均电机: %.1f%%', avg_motor), ...
           'Location', 'best');
    ylim([0, 100]);
    
    % 添加说明文本
    text(max(time_brake)*0.02, 95, ...
         sprintf('策略说明:\n电机制动 = 再生制动 (回收能量)\n液压制动 = 摩擦制动 (能量损失)\n平均电机占比: %.1f%%', avg_motor), ...
         'FontSize', 9, 'BackgroundColor', 'white', 'EdgeColor', colors.medium_gray);
    
end


function create_enhanced_soc_chart(results, colors)
% CREATE_ENHANCED_SOC_CHART 创建增强版SOC变化图表
%
% 详细说明SOC变化的含义和影响

    % 绘制SOC曲线
    plot(results.time_series, results.SOC_series, 'Color', colors.soc_line, ...
         'LineWidth', 3, 'DisplayName', 'SOC');
    hold on;
    
    % 计算SOC变化量
    soc_initial = results.SOC_series(1);
    soc_final = results.SOC_series(end);
    soc_change = soc_final - soc_initial;
    soc_max = max(results.SOC_series);
    soc_min = min(results.SOC_series);
    
    % 添加关键SOC水平线
    yline(90, '--', 'Color', colors.warning, 'LineWidth', 2, ...
          'DisplayName', '高SOC限制 (90%)');
    yline(20, '--', 'Color', colors.error, 'LineWidth', 2, ...
          'DisplayName', '低SOC警告 (20%)');
    
    % 标注起始和结束SOC
    plot(results.time_series(1), soc_initial, 'o', 'MarkerSize', 10, ...
         'MarkerFaceColor', colors.success, 'MarkerEdgeColor', 'white', 'LineWidth', 2);
    plot(results.time_series(end), soc_final, 's', 'MarkerSize', 10, ...
         'MarkerFaceColor', colors.info, 'MarkerEdgeColor', 'white', 'LineWidth', 2);
    
    enhance_subplot('时间 (s)', 'SOC (%)', '电池SOC变化');
    
    % 设置Y轴范围
    ylim([max(0, soc_min-5), min(100, soc_max+5)]);
    
    % 添加详细说明
    if soc_change > 0
        change_text = sprintf('SOC增加: +%.2f%%', soc_change);
        change_color = colors.success;
    else
        change_text = sprintf('SOC减少: %.2f%%', soc_change);
        change_color = colors.error;
    end
    
    text(max(results.time_series)*0.02, soc_max-2, ...
         sprintf('SOC变化分析:\n初始: %.1f%%\n结束: %.1f%%\n%s\n最大: %.1f%%\n最小: %.1f%%', ...
         soc_initial, soc_final, change_text, soc_max, soc_min), ...
         'FontSize', 9, 'BackgroundColor', 'white', 'EdgeColor', change_color, ...
         'Color', change_color);
    
    legend('SOC曲线', '高SOC限制', '低SOC警告', 'Location', 'best');
    
end


function create_efficiency_pie_chart(results, colors)
% CREATE_EFFICIENCY_PIE_CHART 创建效率统计饼图

    efficiency_val = results.efficiency_average;
    loss_val = 100 - efficiency_val;
    
    % 创建现代化饼图
    pie_data = [efficiency_val, loss_val];
    pie_colors = [colors.success; colors.error];
    h_pie = pie(pie_data);
    
    % 美化饼图
    for i = 1:2:length(h_pie)
        h_pie(i).FaceColor = pie_colors((i+1)/2, :);
        h_pie(i).EdgeColor = 'white';
        h_pie(i).LineWidth = 2;
    end
    
    % 添加正确的百分比标签
    pie_labels = {sprintf('回收\n%.1f%%', efficiency_val), ...
                  sprintf('损失\n%.1f%%', loss_val)};
    for i = 2:2:length(h_pie)
        h_pie(i).FontSize = 11;
        h_pie(i).FontWeight = 'bold';
        h_pie(i).String = pie_labels{i/2};
    end
    
    title('能量回收效率统计', 'FontSize', 12, 'FontWeight', 'bold');
    
end


function colors = get_color_scheme_enhanced()
% GET_COLOR_SCHEME_ENHANCED 获取增强版配色方案

    colors = struct();
    
    % 主色调
    colors.primary = [0.2, 0.4, 0.8];      % 深蓝
    colors.secondary = [0.8, 0.3, 0.3];    % 深红
    colors.accent = [1.0, 0.6, 0.0];       % 橙色
    
    % 功能色
    colors.success = [0.2, 0.7, 0.3];      % 绿色
    colors.warning = [1.0, 0.7, 0.0];      % 黄色
    colors.error = [0.9, 0.2, 0.2];        % 红色
    colors.info = [0.3, 0.7, 0.9];         % 浅蓝
    
    % 专用色彩
    colors.motor_brake = [0.1, 0.8, 0.3];     % 电机制动 - 绿色（环保）
    colors.hydraulic_brake = [1.0, 0.5, 0.1]; % 液压制动 - 橙色（摩擦）
    colors.soc_line = [0.2, 0.6, 0.9];        % SOC曲线 - 蓝色
    
    % 中性色
    colors.text = [0.2, 0.2, 0.2];         % 深灰
    colors.light_gray = [0.9, 0.9, 0.9];   % 浅灰
    colors.medium_gray = [0.6, 0.6, 0.6];  % 中灰
    
end
function plot_comparison_enhanced(results, figure_number)
% PLOT_COMPARISON_ENHANCED 绘制增强版策略对比结果
    
    % 创建主窗口 - 使用指定的图表编号
    if isempty(figure_number)
        fig = figure('Name', sprintf('策略对比分析 - %s工况', results.driving_cycle), ...
               'Position', [100, 100, 1600, 1000], 'Color', 'white');
    else
        % 计算窗口位置，避免重叠
        pos_x = 50 + (figure_number - 1) * 120;
        pos_y = 50 + (figure_number - 1) * 60;
        
        fig = figure(figure_number);
        set(fig, 'Name', sprintf('图表%d: 策略对比 - %s工况', figure_number, results.driving_cycle), ...
                'Position', [pos_x, pos_y, 1600, 1000], 'Color', 'white');
    end
    
    % 定义配色方案
    colors = get_color_scheme_enhanced();
    
    % 主标题
    sgtitle(sprintf('再生制动策略对比分析 - %s工况', results.driving_cycle), ...
            'FontSize', 16, 'FontWeight', 'bold', 'Color', colors.text);
    
    % 子图1: 效率对比柱状图
    subplot(2, 4, 1);
    eff_data = [results.baseline.efficiency_average, results.optimized.efficiency_average];
    
    b = bar(eff_data, 'FaceColor', 'flat', 'EdgeColor', 'white', 'LineWidth', 2);
    b.CData = [colors.primary; colors.secondary];
    
    % 添加数值标注
    for i = 1:length(eff_data)
        text(i, eff_data(i) + 1, sprintf('%.2f%%', eff_data(i)), ...
            'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
    end
    
    % 添加提升箭头和数值
    if results.efficiency_improvement > 0
        annotation('arrow', [0.18, 0.22], [0.75, 0.82], 'Color', colors.success, 'LineWidth', 3);
        text(1.5, max(eff_data)*0.9, sprintf('+%.2f%%', results.efficiency_improvement), ...
             'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold', ...
             'Color', colors.success);
    end
    
    enhance_subplot('', '效率 (%)', '能量回收效率对比');
    set(gca, 'XTickLabel', {'基准策略', '优化策略'});
    ylim([0, max(eff_data)*1.2]);
    
    % 子图2: 车速曲线
    subplot(2, 4, 2);
    plot(results.baseline.time_series, results.baseline.velocity_series, ...
         'Color', colors.primary, 'LineWidth', 2);
    enhance_subplot('时间 (s)', '车速 (km/h)', sprintf('%s工况车速曲线', results.driving_cycle));
    
    % 子图3: 瞬时效率对比
    subplot(2, 4, [3, 4]);
    plot(results.baseline.time_series, results.baseline.efficiency_instant, ...
         'Color', colors.primary, 'LineWidth', 2, 'DisplayName', '基准策略');
    hold on;
    plot(results.optimized.time_series, results.optimized.efficiency_instant, ...
         'Color', colors.secondary, 'LineWidth', 2, 'DisplayName', '优化策略');
    
    % 添加平均线
    yline(results.baseline.efficiency_average, '--', 'Color', colors.primary, 'LineWidth', 1.5);
    yline(results.optimized.efficiency_average, '--', 'Color', colors.secondary, 'LineWidth', 1.5);
    
    enhance_subplot('时间 (s)', '瞬时效率 (%)', '瞬时效率对比');
    legend('Location', 'best');
    
    % 子图4: 制动力分配对比（基准策略）
    subplot(2, 4, 5);
    create_comparison_brake_force_chart(results.baseline, colors, '基准策略制动力分配');
    
    % 子图5: 制动力分配对比（优化策略）
    subplot(2, 4, 6);
    create_comparison_brake_force_chart(results.optimized, colors, '优化策略制动力分配');
    
    % 子图6: 能量对比图表
    subplot(2, 4, 7);
    create_energy_comparison_chart_enhanced(results, colors);
    
    % 子图7: 性能指标对比
    subplot(2, 4, 8);
    create_performance_metrics_chart_enhanced(results, colors);
    
    % 添加专业信息面板
    add_comparison_info_panel_enhanced(fig, results);
    
end


function create_comparison_brake_force_chart(results, colors, title_text)
% CREATE_COMPARISON_BRAKE_FORCE_CHART 创建对比用制动力分配图表

    % 找出制动时刻
    brake_indices = find(results.motor_brake_ratio > 0 | results.hydraulic_brake_ratio > 0);
    
    if isempty(brake_indices)
        text(0.5, 0.5, '无制动事件', 'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle', 'FontSize', 12);
        set(gca, 'XLim', [0, 1], 'YLim', [0, 1]);
        title(title_text, 'FontSize', 10, 'FontWeight', 'bold');
        return;
    end
    
    time_brake = results.time_series(brake_indices);
    motor_ratio_brake = results.motor_brake_ratio(brake_indices);
    hydraulic_ratio_brake = results.hydraulic_brake_ratio(brake_indices);
    
    area_data = [motor_ratio_brake, hydraulic_ratio_brake];
    h_area = area(time_brake, area_data, 'LineWidth', 1);
    
    h_area(1).FaceColor = colors.motor_brake;
    h_area(1).FaceAlpha = 0.8;
    h_area(2).FaceColor = colors.hydraulic_brake;
    h_area(2).FaceAlpha = 0.8;
    
    enhance_subplot('时间 (s)', '制动力占比 (%)', title_text);
    legend('电机制动', '液压制动', 'Location', 'best');
    ylim([0, 100]);
    
    % 添加平均值标注
    avg_motor = mean(motor_ratio_brake);
    text(max(time_brake)*0.05, 90, sprintf('平均电机: %.1f%%', avg_motor), ...
         'FontSize', 9, 'BackgroundColor', 'white');
    
end


function create_energy_comparison_chart_enhanced(results, colors)
% CREATE_ENERGY_COMPARISON_CHART_ENHANCED 创建增强版能量对比图表

    baseline_recovered = results.baseline.energy_recovered;
    baseline_total = results.baseline.energy_total;
    optimized_recovered = results.optimized.energy_recovered;
    optimized_total = results.optimized.energy_total;
    
    energy_data = [
        baseline_recovered, baseline_total - baseline_recovered;
        optimized_recovered, optimized_total - optimized_recovered
    ];
    
    b = bar(energy_data, 'stacked', 'EdgeColor', 'white', 'LineWidth', 1.5);
    b(1).FaceColor = colors.success;
    b(2).FaceColor = colors.light_gray;
    
    % 添加数值标注
    for i = 1:2
        text(i, energy_data(i,1)/2, sprintf('%.3f', energy_data(i,1)), ...
             'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
        text(i, energy_data(i,1) + energy_data(i,2)/2, sprintf('%.3f', energy_data(i,2)), ...
             'HorizontalAlignment', 'center', 'FontSize', 9);
    end
    
    enhance_subplot('', '能量 (kWh)', '能量回收对比');
    set(gca, 'XTickLabel', {'基准策略', '优化策略'});
    legend('回收能量', '损失能量', 'Location', 'best');
    
end


function create_performance_metrics_chart_enhanced(results, colors)
% CREATE_PERFORMANCE_METRICS_CHART_ENHANCED 创建增强版性能指标图表

    metrics = {
        '效率提升', results.efficiency_improvement, '个百分点';
        '相对提升', results.improvement_percentage, '%';
        '制动次数', results.baseline.num_brake_events, '次'
    };
    
    y_pos = [0.8, 0.5, 0.2];
    
    for i = 1:size(metrics, 1)
        text(0.1, y_pos(i), metrics{i,1}, 'FontSize', 11, 'FontWeight', 'bold');
        
        if i <= 2
            color = colors.success;
        else
            color = colors.info;
        end
        
        text(0.6, y_pos(i), sprintf('%.2f %s', metrics{i,2}, metrics{i,3}), ...
             'FontSize', 12, 'FontWeight', 'bold', 'Color', color);
    end
    
    set(gca, 'XLim', [0, 1], 'YLim', [0, 1]);
    set(gca, 'XTick', [], 'YTick', []);
    title('关键性能指标', 'FontSize', 12, 'FontWeight', 'bold');
    
    rectangle('Position', [0.05, 0.05, 0.9, 0.9], 'EdgeColor', colors.medium_gray, 'LineWidth', 1.5);
    
end


function add_info_panel_enhanced(fig, results)
% ADD_INFO_PANEL_ENHANCED 添加增强版信息面板

    colors = get_color_scheme_enhanced();
    
    info_text = sprintf(['工况: %s  |  策略: %s  |  制动次数: %d\n' ...
                        '平均效率: %.2f%%  |  回收能量: %.4f kWh  |  总制动能量: %.4f kWh'], ...
                       results.driving_cycle, results.strategy_type, results.num_brake_events, ...
                       results.efficiency_average, results.energy_recovered, results.energy_total);
    
    annotation(fig, 'textbox', [0.02, 0.95, 0.96, 0.04], ...
        'String', info_text, ...
        'EdgeColor', colors.primary, 'BackgroundColor', [0.95, 0.97, 1.0], ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', colors.text, ...
        'HorizontalAlignment', 'center', 'LineWidth', 1.5);
    
end


function add_comparison_info_panel_enhanced(fig, results)
% ADD_COMPARISON_INFO_PANEL_ENHANCED 添加增强版对比信息面板

    colors = get_color_scheme_enhanced();
    
    info_text = sprintf(['策略对比分析  |  工况: %s  |  效率提升: %.2f个百分点 (%.1f%%)  |  ' ...
                        '基准: %.2f%%  →  优化: %.2f%%'], ...
                       results.driving_cycle, results.efficiency_improvement, ...
                       results.improvement_percentage, results.baseline.efficiency_average, ...
                       results.optimized.efficiency_average);
    
    annotation(fig, 'textbox', [0.02, 0.96, 0.96, 0.03], ...
        'String', info_text, ...
        'EdgeColor', colors.success, 'BackgroundColor', [0.95, 1.0, 0.95], ...
        'FontSize', 12, 'FontWeight', 'bold', 'Color', colors.text, ...
        'HorizontalAlignment', 'center', 'LineWidth', 2);
    
end


% 复用原有的辅助函数
function setup_professional_style()
    set(0, 'DefaultFigureColor', 'white');
    set(0, 'DefaultAxesBox', 'on');
    set(0, 'DefaultAxesGridAlpha', 0.3);
    set(0, 'DefaultAxesLineWidth', 1.2);
    set(0, 'DefaultLineLineWidth', 2);
    set(0, 'DefaultAxesFontSize', 10);
    set(0, 'DefaultTextFontSize', 10);
    set(0, 'DefaultAxesTickDir', 'out');
    set(0, 'DefaultAxesTickLength', [0.01, 0.01]);
end


function setup_chinese_font_enhanced()
    try
        if ispc
            fonts = {'Microsoft YaHei UI', 'Microsoft YaHei', 'SimHei', 'SimSun'};
        elseif ismac
            fonts = {'PingFang SC', 'Hiragino Sans GB', 'STHeiti', 'Arial Unicode MS'};
        else
            fonts = {'Noto Sans CJK SC', 'WenQuanYi Micro Hei', 'DejaVu Sans'};
        end
        
        for i = 1:length(fonts)
            try
                set(0, 'DefaultAxesFontName', fonts{i});
                set(0, 'DefaultTextFontName', fonts{i});
                break;
            catch
                continue;
            end
        end
        
    catch ME
        warning('无法设置中文字体: %s', ME.message);
    end
end


function enhance_subplot(xlabel_text, ylabel_text, title_text)
    colors = get_color_scheme_enhanced();
    
    xlabel(xlabel_text, 'FontSize', 11, 'FontWeight', 'normal');
    ylabel(ylabel_text, 'FontSize', 11, 'FontWeight', 'normal');
    title(title_text, 'FontSize', 12, 'FontWeight', 'bold', 'Color', colors.text);
    
    grid on;
    set(gca, 'GridAlpha', 0.3, 'GridLineStyle', '-');
    set(gca, 'Box', 'on', 'LineWidth', 1.2);
    set(gca, 'FontSize', 10);
    set(gca, 'Color', [0.98, 0.98, 0.98]);
end