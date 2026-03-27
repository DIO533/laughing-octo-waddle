function [motor_brake_ratio, hydraulic_brake_ratio, motor_brake_force, hydraulic_brake_force] = ...
    baseline_strategy(brake_demand, velocity, total_brake_force, params)
% BASELINE_STRATEGY 基准制动力分配策略
%
% 实现固定比例（6:4）的前后轴制动力分配策略
% 制动强度 < 0.3g 时优先使用再生制动
%
% 输入参数:
%   brake_demand       - 制动踏板开度 (%), 0-100
%   velocity           - 车速 (km/h)
%   total_brake_force  - 总制动力需求 (N)
%   params             - 车辆参数结构体（可选）
%
% 输出参数:
%   motor_brake_ratio     - 电机制动力占比 (%), 0-100
%   hydraulic_brake_ratio - 液压制动力占比 (%), 0-100
%   motor_brake_force     - 电机制动力 (N)
%   hydraulic_brake_force - 液压制动力 (N)
%
% 示例:
%   params = vehicle_params();
%   [r_m, r_h, F_m, F_h] = baseline_strategy(50, 60, 5000, params);

    % 输入验证
    if nargin < 4
        params = vehicle_params();
    end
    
    validateattributes(brake_demand, {'numeric'}, {'scalar', '>=', 0, '<=', 100}, ...
        'baseline_strategy', 'brake_demand');
    validateattributes(velocity, {'numeric'}, {'scalar', '>=', 0, '<=', 120}, ...
        'baseline_strategy', 'velocity');
    validateattributes(total_brake_force, {'numeric'}, {'scalar', '>=', 0}, ...
        'baseline_strategy', 'total_brake_force');
    
    % 固定前后轴制动力分配比例
    front_ratio = params.brake.baseline_front_ratio;  % 0.6
    rear_ratio = params.brake.baseline_rear_ratio;    % 0.4
    
    % 计算制动强度（单位：g）
    mass = params.vehicle.mass_default;
    g = params.vehicle.gravity;
    brake_intensity = total_brake_force / (mass * g);
    
    % 计算电机最大可提供的制动力
    % 基于电机最大回馈扭矩和车速
    max_motor_torque = params.motor.max_regen_torque;  % 120 Nm
    wheel_radius = params.vehicle.wheel_radius;
    gear_ratio = 10;  % 传动比
    
    % 电机制动力 = 扭矩 * 传动比 / 车轮半径
    max_motor_brake_force = max_motor_torque * gear_ratio / wheel_radius;
    
    % 低速时电机制动力衰减
    v_ms = velocity / 3.6;
    wheel_speed = v_ms / wheel_radius;
    rpm = wheel_speed * gear_ratio * 60 / (2 * pi);
    
    if rpm < 1500
        % 低速时线性衰减
        speed_factor = rpm / 1500;
        max_motor_brake_force = max_motor_brake_force * speed_factor;
    end
    
    % 策略逻辑：固定6:4比例分配
    % 前轴60%，后轴40%
    % 假设电机在前轴，液压制动在前后轴都有
    
    % 电机制动力 = 总制动力 × 前轴比例
    desired_motor_force = total_brake_force * front_ratio;
    
    % 但不能超过电机最大制动力
    motor_brake_force = min(desired_motor_force, max_motor_brake_force);
    motor_brake_force = max(0, motor_brake_force);
    
    % 液压制动力补充剩余
    hydraulic_brake_force = total_brake_force - motor_brake_force;
    hydraulic_brake_force = max(0, hydraulic_brake_force);
    
    % 计算制动力占比
    if total_brake_force > 0
        motor_brake_ratio = (motor_brake_force / total_brake_force) * 100;
        hydraulic_brake_ratio = (hydraulic_brake_force / total_brake_force) * 100;
    else
        motor_brake_ratio = 0;
        hydraulic_brake_ratio = 0;
    end
    
    % 确保比例和为100%
    total_ratio = motor_brake_ratio + hydraulic_brake_ratio;
    if total_ratio > 0
        motor_brake_ratio = motor_brake_ratio / total_ratio * 100;
        hydraulic_brake_ratio = hydraulic_brake_ratio / total_ratio * 100;
    end
    
end
