function visualization(results, plot_type)
% VISUALIZATION 数据可视化
%
% 绘制仿真结果图表，提供专业的可视化效果
%
% 输入参数:
%   results   - 仿真结果结构体
%   plot_type - 图表类型: 'single' | 'comparison' | 'factor_analysis'
%
% 示例:
%   visualization(results, 'single');
%   visualization(results, 'comparison');

    % 设置专业图表样式
    setup_professional_style();
    
    % 设置中文字体
    setup_chinese_font_enhanced();
    
    % 根据图表类型绘制
    switch lower(plot_type)
        case {'single', 'baseline', 'optimized'}
            plot_single_strategy(results);
            
        case 'comparison'
            plot_comparison(results);
            
        case 'factor_analysis'
            plot_factor_analysis(results);
            
        otherwise
            % 尝试自动识别结果类型
            if isfield(results, 'baseline') && isfield(results, 'optimized')
                plot_comparison(results);
            elseif isfield(results, 'factor_name')
                plot_factor_analysis(results);
            else
                plot_single_strategy(results);
            end
    end
    
end


function plot_single_strategy(results)
% PLOT_SINGLE_STRATEGY 绘制单个策略的结果
    
    % 创建主窗口
    fig = figure('Name', sprintf('再生制动仿真结果 - %s策略', results.strategy_type), ...
           'Position', [100, 100, 1400, 900], 'Color', 'white');
    
    % 定义专业配色方案
    colors = get_color_scheme();
    
    % 子图1: 车速-时间曲线
    subplot(3, 3, [1, 2]);
    plot(results.time_series, results.velocity_series, 'Color', colors.primary, ...
         'LineWidth', 2.5, 'DisplayName', '车速');
    enhance_subplot('时间 (s)', '车速 (km/h)', '车速-时间曲线');
    
    % 标注制动事件
    if isfield(results, 'brake_events') && ~isempty(results.brake_events)
        hold on;
        for i = 1:min(5, length(results.brake_events))  % 只标注前5个制动事件
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
    
    % 子图3: 制动力分配比例（堆叠面积图）
    subplot(3, 3, [4, 5]);
    area_data = [results.motor_brake_ratio, results.hydraulic_brake_ratio];
    h_area = area(results.time_series, area_data, 'LineWidth', 1);
    h_area(1).FaceColor = colors.primary;
    h_area(1).FaceAlpha = 0.7;
    h_area(2).FaceColor = colors.secondary;
    h_area(2).FaceAlpha = 0.7;
    enhance_subplot('时间 (s)', '制动力占比 (%)', '制动力分配比例');
    legend('电机制动', '液压制动', 'Location', 'best');
    ylim([0, 100]);
    
    % 子图4: 电池SOC变化
    subplot(3, 3, 6);
    plot(results.time_series, results.SOC_series, 'Color', colors.success, ...
         'LineWidth', 2.5, 'DisplayName', 'SOC');
    enhance_subplot('时间 (s)', 'SOC (%)', '电池SOC变化');
    
    % 添加SOC范围标识
    hold on;
    yline(90, '--', 'Color', colors.warning, 'LineWidth', 1.5, 'Alpha', 0.7);
    text(max(results.time_series)*0.8, 92, '高SOC限制', 'FontSize', 9, 'Color', colors.warning);
    
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
    
    % 添加专业的标题和信息面板
    add_info_panel(fig, results);
    
end


function plot_comparison(results)
% PLOT_COMPARISON 绘制策略对比结果
    
    % 创建主窗口
    fig = figure('Name', '策略对比分析', 'Position', [100, 100, 1600, 1000], 'Color', 'white');
    
    % 定义配色方案
    colors = get_color_scheme();
    
    % 主标题
    sgtitle(sprintf('再生制动策略对比分析 - %s工况', results.driving_cycle), ...
            'FontSize', 16, 'FontWeight', 'bold', 'Color', colors.text);
    
    % 子图1: 效率对比柱状图（增强版）
    subplot(2, 4, 1);
    eff_data = [results.baseline.efficiency_average, results.optimized.efficiency_average];
    
    % 创建渐变柱状图
    b = bar(eff_data, 'FaceColor', 'flat', 'EdgeColor', 'white', 'LineWidth', 2);
    b.CData = [colors.primary; colors.secondary];
    
    % 添加数值标注
    for i = 1:length(eff_data)
        text(i, eff_data(i) + 1, sprintf('%.2f%%', eff_data(i)), ...
            'HorizontalAlignment', 'center', 'FontSize', 11, 'FontWeight', 'bold');
    end
    
    % 添加提升箭头
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
    yline(results.baseline.efficiency_average, '--', 'Color', colors.primary, ...
          'LineWidth', 1.5, 'Alpha', 0.7);
    yline(results.optimized.efficiency_average, '--', 'Color', colors.secondary, ...
          'LineWidth', 1.5, 'Alpha', 0.7);
    
    enhance_subplot('时间 (s)', '瞬时效率 (%)', '瞬时效率对比');
    legend('Location', 'best');
    
    % 子图4: 制动力分配对比（基准策略）
    subplot(2, 4, 5);
    create_stacked_area(results.baseline.time_series, ...
                       results.baseline.motor_brake_ratio, ...
                       results.baseline.hydraulic_brake_ratio, ...
                       colors, '基准策略制动力分配');
    
    % 子图5: 制动力分配对比（优化策略）
    subplot(2, 4, 6);
    create_stacked_area(results.optimized.time_series, ...
                       results.optimized.motor_brake_ratio, ...
                       results.optimized.hydraulic_brake_ratio, ...
                       colors, '优化策略制动力分配');
    
    % 子图6: 能量对比雷达图
    subplot(2, 4, 7);
    create_energy_comparison_chart(results, colors);
    
    % 子图7: 性能指标对比
    subplot(2, 4, 8);
    create_performance_metrics_chart(results, colors);
    
    % 添加专业信息面板
    add_comparison_info_panel(fig, results);
    
end


function plot_factor_analysis(results)
% PLOT_FACTOR_ANALYSIS 绘制单因素分析结果
    
    % 创建专业化窗口
    fig = figure('Name', sprintf('单因素分析 - %s', results.factor_name), ...
           'Position', [100, 100, 1200, 700], 'Color', 'white');
    
    % 设置专业样式
    colors = get_color_scheme();
    
    % 主标题
    sgtitle(sprintf('单因素分析：%s对能量回收效率的影响', results.factor_name), ...
            'FontSize', 16, 'FontWeight', 'bold', 'Color', colors.text);
    
    % 子图1: 因素-效率关系曲线（增强版）
    subplot(2, 3, [1, 2]);
    
    % 绘制主曲线
    plot(results.factor_values, results.efficiency_values, 'Color', colors.primary, ...
        'LineWidth', 3, 'MarkerSize', 10, 'Marker', 'o', 'MarkerFaceColor', colors.primary, ...
        'MarkerEdgeColor', 'white', 'LineWidth', 2);
    hold on;
    
    % 标注基准点
    baseline_idx = find(abs(results.factor_values - results.baseline_value) < 1e-6, 1);
    if ~isempty(baseline_idx)
        plot(results.factor_values(baseline_idx), results.efficiency_values(baseline_idx), ...
            'Marker', 's', 'MarkerSize', 15, 'MarkerFaceColor', colors.accent, ...
            'MarkerEdgeColor', 'white', 'LineWidth', 3);
    end
    
    % 添加趋势线（如果数据点足够）
    if length(results.factor_values) >= 3
        p = polyfit(results.factor_values, results.efficiency_values, 1);
        trend_y = polyval(p, results.factor_values);
        h_trend = plot(results.factor_values, trend_y, '--', 'Color', colors.medium_gray, ...
             'LineWidth', 2);
        % 设置透明度（兼容性处理）
        try
            h_trend.Color(4) = 0.7;  % 设置alpha值
        catch
            % 如果不支持alpha，忽略
        end
    end
    
    enhance_subplot(sprintf('%s (%s)', results.factor_name, results.factor_unit), ...
                   '能量回收效率 (%)', sprintf('%s影响曲线', results.factor_name));
    legend('效率曲线', '基准点', '趋势线', 'Location', 'best');
    
    % 添加数值标注
    for i = 1:length(results.factor_values)
        text(results.factor_values(i), results.efficiency_values(i) + 1, ...
            sprintf('%.1f%%', results.efficiency_values(i)), ...
            'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', ...
            'FontSize', 9, 'FontWeight', 'bold', 'Color', colors.text);
    end
    
    % 子图2: 效率变化柱状图（增强版）
    subplot(2, 3, 3);
    efficiency_change = results.efficiency_values - results.baseline_efficiency;
    
    % 创建渐变色柱状图
    bar_colors = zeros(length(efficiency_change), 3);
    for i = 1:length(efficiency_change)
        if efficiency_change(i) >= 0
            bar_colors(i, :) = colors.success;
        else
            bar_colors(i, :) = colors.error;
        end
    end
    
    b = bar(efficiency_change, 'FaceColor', 'flat', 'EdgeColor', 'white', 'LineWidth', 1.5);
    b.CData = bar_colors;
    
    % 添加数值标注
    for i = 1:length(efficiency_change)
        if efficiency_change(i) >= 0
            va = 'bottom';
            offset = 0.2;
        else
            va = 'top';
            offset = -0.2;
        end
        text(i, efficiency_change(i) + offset, sprintf('%.1f', efficiency_change(i)), ...
             'HorizontalAlignment', 'center', 'VerticalAlignment', va, ...
             'FontSize', 9, 'FontWeight', 'bold');
    end
    
    enhance_subplot('测试点编号', '效率变化 (百分点)', '相对基准值的效率变化');
    h_line = yline(0, 'k--', 'LineWidth', 2);
    % 设置透明度（兼容性处理）
    try
        h_line.Color(4) = 0.8;
    catch
        % 如果不支持alpha，忽略
    end
    
    % 设置X轴标签
    xticks(1:length(results.factor_values));
    xticklabels(arrayfun(@(x) sprintf('%.1f', x), results.factor_values, 'UniformOutput', false));
    
    % 子图3: 统计信息表格
    subplot(2, 3, [4, 5]);
    
    % 计算统计数据
    max_eff = max(results.efficiency_values);
    min_eff = min(results.efficiency_values);
    range_eff = max_eff - min_eff;
    [~, max_idx] = max(results.efficiency_values);
    [~, min_idx] = min(results.efficiency_values);
    
    % 创建统计表格
    stats_data = {
        '基准效率', sprintf('%.2f%%', results.baseline_efficiency);
        '最高效率', sprintf('%.2f%% (%.1f %s)', max_eff, results.factor_values(max_idx), results.factor_unit);
        '最低效率', sprintf('%.2f%% (%.1f %s)', min_eff, results.factor_values(min_idx), results.factor_unit);
        '效率范围', sprintf('%.2f个百分点', range_eff);
        '测试点数', sprintf('%d个', length(results.factor_values));
        '工况循环', results.driving_cycle;
        '控制策略', results.strategy_type
    };
    
    % 绘制表格
    y_positions = linspace(0.9, 0.1, size(stats_data, 1));
    for i = 1:size(stats_data, 1)
        % 标签
        text(0.05, y_positions(i), stats_data{i,1}, 'FontSize', 11, 'FontWeight', 'bold');
        % 数值
        text(0.55, y_positions(i), stats_data{i,2}, 'FontSize', 11, 'Color', colors.primary);
    end
    
    set(gca, 'XLim', [0, 1], 'YLim', [0, 1]);
    set(gca, 'XTick', [], 'YTick', []);
    title('分析统计', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 添加边框
    rectangle('Position', [0.02, 0.02, 0.96, 0.96], 'EdgeColor', colors.primary, 'LineWidth', 2);
    
    % 子图4: 敏感性分析
    subplot(2, 3, 6);
    
    % 计算敏感性（效率变化率）
    if length(results.factor_values) > 1
        factor_range = max(results.factor_values) - min(results.factor_values);
        sensitivity = range_eff / factor_range;
        
        % 创建敏感性指示器
        sensitivity_level = {'低', '中', '高'};
        if sensitivity < 0.5
            level = 1; color = colors.success;
        elseif sensitivity < 2.0
            level = 2; color = colors.warning;
        else
            level = 3; color = colors.error;
        end
        
        % 绘制敏感性指示
        rectangle('Position', [0.2, 0.3, 0.6, 0.4], 'FaceColor', color, ...
                 'EdgeColor', 'white', 'LineWidth', 3, 'Curvature', 0.3);
        
        text(0.5, 0.5, sensitivity_level{level}, 'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'middle', 'FontSize', 20, 'FontWeight', 'bold', ...
             'Color', 'white');
        
        text(0.5, 0.2, sprintf('敏感性: %.2f%%/单位', sensitivity), ...
             'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
    end
    
    set(gca, 'XLim', [0, 1], 'YLim', [0, 1]);
    set(gca, 'XTick', [], 'YTick', []);
    title('敏感性评估', 'FontSize', 12, 'FontWeight', 'bold');
    
    % 添加总体信息面板
    info_text = sprintf('工况: %s | 策略: %s | 因素: %s | 基准值: %.2f %s (效率: %.2f%%)', ...
        results.driving_cycle, results.strategy_type, results.factor_name, ...
        results.baseline_value, results.factor_unit, results.baseline_efficiency);
    
    annotation(fig, 'textbox', [0.02, 0.02, 0.96, 0.04], ...
        'String', info_text, ...
        'EdgeColor', colors.info, 'BackgroundColor', [0.95, 0.98, 1.0], ...
        'FontSize', 11, 'FontWeight', 'bold', 'Color', colors.text, ...
        'HorizontalAlignment', 'center', 'LineWidth', 1.5);
    
end


function setup_professional_style()
% SETUP_PROFESSIONAL_STYLE 设置专业图表样式
    
    % 设置默认图表属性
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
% SETUP_CHINESE_FONT_ENHANCED 增强的中文字体设置
    
    try
        if ispc
            % Windows系统字体优先级
            fonts = {'Microsoft YaHei UI', 'Microsoft YaHei', 'SimHei', 'SimSun'};
        elseif ismac
            % macOS系统字体
            fonts = {'PingFang SC', 'Hiragino Sans GB', 'STHeiti', 'Arial Unicode MS'};
        else
            % Linux系统字体
            fonts = {'Noto Sans CJK SC', 'WenQuanYi Micro Hei', 'DejaVu Sans'};
        end
        
        % 尝试设置字体
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
        fprintf('使用默认字体。中文可能显示为方框。\n');
    end
    
end


function colors = get_color_scheme()
% GET_COLOR_SCHEME 获取专业配色方案
    
    colors = struct();
    
    % 主色调 - 现代蓝色系
    colors.primary = [0.2, 0.4, 0.8];      % 深蓝
    colors.secondary = [0.8, 0.3, 0.3];    % 深红
    colors.accent = [1.0, 0.6, 0.0];       % 橙色
    
    % 功能色
    colors.success = [0.2, 0.7, 0.3];      % 绿色
    colors.warning = [1.0, 0.7, 0.0];      % 黄色
    colors.error = [0.9, 0.2, 0.2];        % 红色
    colors.info = [0.3, 0.7, 0.9];         % 浅蓝
    
    % 中性色
    colors.text = [0.2, 0.2, 0.2];         % 深灰
    colors.light_gray = [0.9, 0.9, 0.9];   % 浅灰
    colors.medium_gray = [0.6, 0.6, 0.6];  % 中灰
    
    % 渐变色
    colors.gradient_blue = [0.1, 0.3, 0.7; 0.3, 0.5, 0.9];
    colors.gradient_red = [0.7, 0.2, 0.2; 0.9, 0.4, 0.4];
    
end


function enhance_subplot(xlabel_text, ylabel_text, title_text)
% ENHANCE_SUBPLOT 增强子图样式
    
    colors = get_color_scheme();
    
    % 设置标签和标题
    xlabel(xlabel_text, 'FontSize', 11, 'FontWeight', 'normal');
    ylabel(ylabel_text, 'FontSize', 11, 'FontWeight', 'normal');
    title(title_text, 'FontSize', 12, 'FontWeight', 'bold', 'Color', colors.text);
    
    % 设置网格
    grid on;
    set(gca, 'GridAlpha', 0.3, 'GridLineStyle', '-');
    
    % 设置坐标轴
    set(gca, 'Box', 'on', 'LineWidth', 1.2);
    set(gca, 'FontSize', 10);
    
    % 设置背景
    set(gca, 'Color', [0.98, 0.98, 0.98]);
    
end


function add_info_panel(fig, results)
% ADD_INFO_PANEL 添加信息面板
    
    colors = get_color_scheme();
    
    % 创建信息面板 - 修复数据显示
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


function create_stacked_area(time_data, motor_data, hydraulic_data, colors, title_text)
% CREATE_STACKED_AREA 创建堆叠面积图
    
    area_data = [motor_data, hydraulic_data];
    h_area = area(time_data, area_data, 'LineWidth', 1);
    
    % 设置颜色和透明度
    h_area(1).FaceColor = colors.primary;
    h_area(1).FaceAlpha = 0.8;
    h_area(2).FaceColor = colors.secondary;
    h_area(2).FaceAlpha = 0.8;
    
    enhance_subplot('时间 (s)', '制动力占比 (%)', title_text);
    legend('电机制动', '液压制动', 'Location', 'best');
    ylim([0, 100]);
    
end


function create_energy_comparison_chart(results, colors)
% CREATE_ENERGY_COMPARISON_CHART 创建能量对比图表
    
    % 准备数据
    baseline_recovered = results.baseline.energy_recovered;
    baseline_total = results.baseline.energy_total;
    optimized_recovered = results.optimized.energy_recovered;
    optimized_total = results.optimized.energy_total;
    
    % 创建堆叠柱状图
    energy_data = [
        baseline_recovered, baseline_total - baseline_recovered;
        optimized_recovered, optimized_total - optimized_recovered
    ];
    
    b = bar(energy_data, 'stacked', 'EdgeColor', 'white', 'LineWidth', 1.5);
    b(1).FaceColor = colors.success;
    b(2).FaceColor = colors.light_gray;
    
    % 添加数值标注
    for i = 1:2
        % 回收能量标注
        text(i, energy_data(i,1)/2, sprintf('%.3f', energy_data(i,1)), ...
             'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
        % 总能量标注
        text(i, energy_data(i,1) + energy_data(i,2)/2, sprintf('%.3f', energy_data(i,2)), ...
             'HorizontalAlignment', 'center', 'FontSize', 9);
    end
    
    enhance_subplot('', '能量 (kWh)', '能量回收对比');
    set(gca, 'XTickLabel', {'基准策略', '优化策略'});
    legend('回收能量', '损失能量', 'Location', 'best');
    
end


function create_performance_metrics_chart(results, colors)
% CREATE_PERFORMANCE_METRICS_CHART 创建性能指标图表
    
    % 性能指标 - 修复数据引用
    metrics = {
        '效率提升', results.efficiency_improvement, '个百分点';
        '相对提升', results.improvement_percentage, '%';
        '制动次数', results.baseline.num_brake_events, '次'
    };
    
    % 创建表格样式的显示
    y_pos = [0.8, 0.5, 0.2];
    
    for i = 1:size(metrics, 1)
        % 指标名称
        text(0.1, y_pos(i), metrics{i,1}, 'FontSize', 11, 'FontWeight', 'bold');
        
        % 数值
        if i <= 2  % 效率相关指标
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
    
    % 添加边框
    rectangle('Position', [0.05, 0.05, 0.9, 0.9], 'EdgeColor', colors.medium_gray, 'LineWidth', 1.5);
    
end


function add_comparison_info_panel(fig, results)
% ADD_COMPARISON_INFO_PANEL 添加对比信息面板
    
    colors = get_color_scheme();
    
    % 创建信息面板
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