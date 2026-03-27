function config = simulation_config()
% SIMULATION_CONFIG 仿真配置参数
%
% 返回值:
%   config - 包含所有仿真配置参数的结构体
%
% 配置项:
%   sampling_time    - 采样时间间隔 (秒)
%   simulation_mode  - 仿真模式: 'baseline' | 'optimized' | 'comparison' | 'factor_analysis'
%   driving_cycle    - 驾驶循环: 'NEDC' | 'UDDS'
%   save_results     - 是否保存仿真结果
%   plot_results     - 是否绘制结果图表
%   export_figures   - 是否导出图表文件

    % 基本仿真参数
    config.sampling_time = 0.1;  % 采样时间间隔：0.1秒
    
    % 仿真模式
    % 'baseline'        - 仅运行基准策略
    % 'optimized'       - 仅运行优化策略
    % 'comparison'      - 对比基准策略和优化策略
    % 'factor_analysis' - 单因素影响分析
    config.simulation_mode = 'comparison';
    
    % 驾驶循环工况
    % 'NEDC' - 新欧洲驾驶循环
    % 'UDDS' - 城市道路循环
    config.driving_cycle = 'NEDC';
    
    % 输出选项
    config.save_results = false;     % 默认不保存结果（演示模式）
    config.plot_results = true;      % 绘制结果图表
    config.export_figures = false;   % 默认不导出图表（演示模式）
    
    % 图表输出路径
    config.output_dir = 'results';   % 结果输出目录
    config.figure_format = {'png', 'epsc'};  % 图表格式
    config.figure_resolution = 300;  % 图表分辨率 (DPI)
    
    % 数值计算参数
    config.integration_method = 'trapz';  % 数值积分方法：梯形法则
    config.tolerance = 1e-6;              % 数值计算容差
    
    % 调试选项
    config.verbose = true;           % 显示详细信息
    config.debug_mode = false;       % 调试模式
    config.demo_mode = true;         % 演示模式（简化输出）
    
end
