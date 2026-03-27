function [brake_force_required, kinetic_energy, deceleration] = vehicle_model(velocity, mass, slope, params)
% VEHICLE_MODEL 车辆动力学模型
%
% 计算车辆制动过程中的动力学特性，包括所需制动力、动能和减速度
%
% 输入参数:
%   velocity - 车速 (km/h)
%   mass     - 车辆质量 (kg)
%   slope    - 道路坡度 (%), 正值为上坡，负值为下坡
%   params   - 车辆参数结构体（可选）
%
% 输出参数:
%   brake_force_required - 所需制动力 (N)
%   kinetic_energy       - 车辆动能 (J)
%   deceleration         - 减速度 (m/s²)
%
% 示例:
%   params = vehicle_params();
%   [F_brake, E_k, a] = vehicle_model(60, 1500, 0, params);

    % 输入验证
    if nargin < 3
        slope = 0;
    end
    if nargin < 4
        params = vehicle_params();
    end
    
    % 参数验证
    validateattributes(velocity, {'numeric'}, {'scalar', '>=', 0, '<=', 120}, ...
        'vehicle_model', 'velocity');
    validateattributes(mass, {'numeric'}, {'scalar', '>', 0}, ...
        'vehicle_model', 'mass');
    validateattributes(slope, {'numeric'}, {'scalar', '>=', -20, '<=', 20}, ...
        'vehicle_model', 'slope');
    
    % 物理常数
    g = params.vehicle.gravity;  % 重力加速度 (m/s²)
    
    % 速度单位转换：km/h -> m/s
    v_ms = velocity / 3.6;
    
    % 计算动能：E = 0.5 * m * v²
    kinetic_energy = 0.5 * mass * v_ms^2;
    
    % 计算坡度角（弧度）
    slope_rad = atan(slope / 100);
    
    % 计算重力分量（沿坡度方向）
    % 上坡为正（需要额外制动力），下坡为负（减少制动力需求）
    gravity_component = mass * g * sin(slope_rad);
    
    % 计算滚动阻力
    rolling_resistance = params.vehicle.rolling_resistance * mass * g * cos(slope_rad);
    
    % 计算空气阻力：F_air = 0.5 * ρ * Cd * A * v²
    % 空气密度 ρ ≈ 1.225 kg/m³
    air_density = 1.225;
    air_resistance = 0.5 * air_density * params.vehicle.drag_coefficient * ...
                     params.vehicle.frontal_area * v_ms^2;
    
    % 计算所需制动力
    % 制动力需要克服车辆惯性，同时考虑坡度、滚动阻力和空气阻力
    % 假设目标减速度为舒适减速度
    target_deceleration = params.brake.comfort_deceleration * g;  % m/s²
    
    % 所需制动力 = 惯性力 - 重力分量 - 滚动阻力 - 空气阻力
    % 注意：下坡时重力分量为负，会增加制动力需求
    brake_force_required = mass * target_deceleration - gravity_component;
    
    % 确保制动力为正值
    brake_force_required = max(0, brake_force_required);
    
    % 计算实际减速度
    if mass > 0
        deceleration = brake_force_required / mass;
    else
        deceleration = 0;
    end
    
end
