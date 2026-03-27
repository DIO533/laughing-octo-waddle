function params = vehicle_params()
% VEHICLE_PARAMS 车辆参数定义
%
% 返回值:
%   params - 包含所有车辆参数的结构体
%
% 参数类别:
%   - 车辆基本参数（质量、轴距等）
%   - 电机参数（功率、扭矩、效率等）
%   - 电池参数（容量、电压、效率等）
%   - 制动系统参数

    %% 车辆基本参数
    params.vehicle.mass_empty = 1500;      % 空载质量 (kg)
    params.vehicle.mass_half = 1800;       % 半载质量 (kg)
    params.vehicle.mass_full = 2100;       % 满载质量 (kg)
    params.vehicle.mass_default = 1500;    % 默认质量 (kg)
    params.vehicle.wheelbase = 2.670;      % 轴距 (m)
    params.vehicle.frontal_area = 2.5;     % 迎风面积 (m²)
    params.vehicle.drag_coefficient = 0.28; % 风阻系数
    params.vehicle.rolling_resistance = 0.015; % 滚动阻力系数
    params.vehicle.wheel_radius = 0.32;    % 车轮半径 (m)
    params.vehicle.gravity = 9.81;         % 重力加速度 (m/s²)
    
    %% 电机参数
    params.motor.rated_power = 160;        % 额定功率 (kW)
    params.motor.peak_torque = 300;        % 峰值扭矩 (N·m)
    params.motor.max_regen_torque = 120;   % 最大回馈扭矩 (N·m)
    params.motor.max_speed = 12000;        % 最大转速 (rpm)
    params.motor.winding_resistance = 0.02; % 绕组电阻 (Ω)
    params.motor.inductance = 0.5e-3;      % 电感 (H)
    params.motor.flux_linkage = 0.12;      % 永磁体磁链 (Wb)
    
    % 电机效率映射（转速区间 -> 效率范围）
    % 转速区间定义 (rpm)
    params.motor.speed_ranges = [
        0,    1500;   % 极低速区间
        1500, 3000;   % 低速区间
        3000, 5000;   % 中速区间（高效区）
        5000, 8000;   % 高速区间（高效区）
        8000, 12000   % 极高速区间
    ];
    
    % 对应的发电效率范围 (%)
    params.motor.efficiency_ranges = [
        20,  40;      % 极低速：20%-40%
        40,  70;      % 低速：40%-70%
        85,  92;      % 中速：85%-92%（高效区）
        85,  92;      % 高速：85%-92%（高效区）
        70,  85       % 极高速：70%-85%
    ];
    
    %% 电池参数
    params.battery.capacity = 60.2;        % 电池容量 (kWh)
    params.battery.voltage_min = 320;      % 最低工作电压 (V)
    params.battery.voltage_max = 420;      % 最高工作电压 (V)
    params.battery.voltage_nominal = 370;  % 额定电压 (V)
    
    % 电池内阻（温度相关）
    params.battery.resistance_25C = 0.012; % 25℃时的内阻 (Ω)
    params.battery.resistance_m10C = 0.030; % -10℃时的内阻 (Ω)
    params.battery.resistance_45C = 0.015; % 45℃时的内阻 (Ω)
    
    % 电池充放电效率（温度相关）
    params.battery.efficiency_25C = 0.95;  % 25℃时的充放电效率
    params.battery.efficiency_m10C = 0.80; % -10℃时的充放电效率
    params.battery.efficiency_45C = 0.90;  % 45℃时的充放电效率
    
    % SOC限制
    params.battery.SOC_min = 0.20;         % 最低SOC (20%)
    params.battery.SOC_max = 0.95;         % 最高SOC (95%)
    params.battery.SOC_high_limit = 0.90;  % 高SOC限制阈值 (90%)
    params.battery.SOC_default = 0.60;     % 默认初始SOC (60%)
    
    % 充电功率限制
    params.battery.max_charge_power = 50;  % 最大充电功率 (kW)
    params.battery.max_discharge_power = 160; % 最大放电功率 (kW)
    
    %% 制动系统参数
    params.brake.max_deceleration = 0.8;   % 最大减速度 (g)
    params.brake.comfort_deceleration = 0.3; % 舒适减速度阈值 (g)
    params.brake.emergency_deceleration = 0.7; % 紧急制动减速度 (g)
    
    % 制动力分配（基准策略）
    params.brake.baseline_front_ratio = 0.6; % 前轴制动力比例
    params.brake.baseline_rear_ratio = 0.4;  % 后轴制动力比例
    
    % 制动踏板行程映射
    params.brake.pedal_min = 0;            % 最小踏板行程 (%)
    params.brake.pedal_max = 100;          % 最大踏板行程 (%)
    
    %% 环境参数
    params.environment.temperature_default = 25;  % 默认环境温度 (℃)
    params.environment.temperature_min = -40;     % 最低环境温度 (℃)
    params.environment.temperature_max = 60;      % 最高环境温度 (℃)
    params.environment.slope_default = 0;         % 默认道路坡度 (%)
    params.environment.slope_min = -20;           % 最小坡度 (%)
    params.environment.slope_max = 20;            % 最大坡度 (%)
    
    %% 单因素分析参数
    % 车辆质量测试点
    params.factor_analysis.mass_values = [1500, 1800, 2100]; % kg
    
    % 电机转速区间测试点（中心值）
    params.factor_analysis.motor_rpm_values = [2000, 4000, 6000]; % rpm
    
    % 电池温度测试点
    params.factor_analysis.temperature_values = [-10, 25, 45]; % ℃
    
    % 电池SOC测试点
    params.factor_analysis.SOC_values = [0.20, 0.50, 0.80]; % 20%, 50%, 80%
    
    % 制动踏板行程测试点
    params.factor_analysis.pedal_travel_values = [20, 40, 60, 80]; % %
    
    % 道路坡度测试点
    params.factor_analysis.slope_values = [-10, 0, 10]; % %
    
    % 环境温度测试点（完整范围）
    params.factor_analysis.env_temperature_values = -20:10:50; % ℃
    
end
