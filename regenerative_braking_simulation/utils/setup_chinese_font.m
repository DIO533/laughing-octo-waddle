function font_name = setup_chinese_font()
% SETUP_CHINESE_FONT 设置中文字体
%
% 自动检测系统并设置合适的中文字体
%
% 输出参数:
%   font_name - 设置的字体名称
%
% 示例:
%   font_name = setup_chinese_font();

    % 检测操作系统
    if ispc
        % Windows系统
        fonts_to_try = {'Microsoft YaHei', 'SimHei', 'SimSun', 'KaiTi'};
    elseif ismac
        % macOS系统
        fonts_to_try = {'PingFang SC', 'Heiti SC', 'STHeiti', 'Songti SC'};
    else
        % Linux系统
        fonts_to_try = {'WenQuanYi Micro Hei', 'Noto Sans CJK SC', 'AR PL UMing CN'};
    end
    
    % 获取系统可用字体列表
    available_fonts = listfonts();
    
    % 查找第一个可用的中文字体
    font_name = '';
    for i = 1:length(fonts_to_try)
        if any(strcmpi(available_fonts, fonts_to_try{i}))
            font_name = fonts_to_try{i};
            break;
        end
    end
    
    % 如果没有找到中文字体，使用默认字体
    if isempty(font_name)
        warning('setup_chinese_font:NoChineseFont', ...
            '未找到中文字体，使用默认字体。中文可能显示为方框。');
        font_name = get(0, 'DefaultAxesFontName');
    end
    
    % 设置字体
    try
        set(0, 'DefaultAxesFontName', font_name);
        set(0, 'DefaultTextFontName', font_name);
        set(0, 'DefaultUicontrolFontName', font_name);
        
        fprintf('已设置中文字体: %s\n', font_name);
    catch ME
        warning('setup_chinese_font:SetFontFailed', ...
            '设置字体失败: %s', ME.message);
    end
    
end
