function [regen_torque, motor_efficiency, motor_power, rpm] = motor_model(velocity, brake_demand, params)
% MOTOR_MODEL 电机发电模型
%
% 模拟永磁同步电机在再生制动模式下的发电特性
%
% 输入参数:
%   velocity     - 车速 (km/h)
%   brake_demand - 制动需求 (%), 0-100
%   params       - 车辆参数结构体（可选）
%
% 输出参数:
%   regen_torque     - 再生制动扭矩 (Nm)
%   motor_efficiency - 电机发电效率 (%), 0-100
%   motor_power      - 发电功率 (kW)
%   rpm              - 电机转速 (rpm)
%
% 示例:
%   params = vehicle_params();
%   [T, eta, P, n] = motor_model(60, 50, params);

    % 输入验证
    if nargin < 3
        params = vehicle_params();
    end
    
    validateattributes(velocity, {'numeric'}, {'scalar', '>=', 0, '<=', 120}, ...
        'motor_model', 'velocity');
    validateattributes(brake_demand, {'numeric'}, {'scalar', '>=', 0, '<=', 100}, ...
        'motor_model', 'brake_demand');
    
    % 计算电机转速（基于车速和传动比）
    % 假设传动比为10:1，车轮半径0.32m
    wheel_radius = params.vehicle.wheel_radius;  % m
    gear_ratio = 10;  % 传动比
    
    % 车速转换为 m/s
    v_ms = velocity / 3.6;
    
    % 车轮转速 (rad/s)
    wheel_speed = v_ms / wheel_radius;
    
    % 电机转速 (rpm)
    rpm = wheel_speed * gear_ratio * 60 / (2 * pi);
    
    % 限制电机转速范围
    rpm = min(rpm, params.motor.max_speed);
    rpm = max(rpm, 0);
    
    % 根据转速区间确定发电效率
    motor_efficiency = calculate_motor_efficiency(rpm, params);
    
    % 计算再生制动扭矩
    % 扭矩与制动需求成正比，但受最大回馈扭矩限制
    max_regen_torque = params.motor.max_regen_torque;  % 120 Nm
    
    % 制动需求转换为扭矩需求（线性映射）
    torque_demand = (brake_demand / 100) * max_regen_torque;
    
    % 考虑低速时的扭矩限制（低速时发电能力下降）
    if rpm < 1500
        % 低速时扭矩线性衰减
        torque_factor = rpm / 1500;
        torque_demand = torque_demand * torque_factor;
    end
    
    % 应用最大扭矩限制
    regen_torque = min(torque_demand, max_regen_torque);
    regen_torque = max(regen_torque, 0);
    
    % 计算发电功率：P = T * ω / 9550 (kW)
    % 其中 ω 为转速 (rpm)，T 为扭矩 (Nm)
    if rpm > 0
        motor_power = regen_torque * rpm / 9550;
    else
        motor_power = 0;
    end
    
    % 考虑电机效率的实际发电功率
    motor_power = motor_power * (motor_efficiency / 100);
    
end


function efficiency = calculate_motor_efficiency(rpm, params)
% CALCULATE_MOTOR_EFFICIENCY 计算电机发电效率
%
% 根据电机转速确定发电效率
%
% 输入参数:
%   rpm    - 电机转速 (rpm)
%   params - 车辆参数结构体
%
% 输出参数:
%   efficiency - 发电效率 (%)

    speed_ranges = params.motor.speed_ranges;
    efficiency_ranges = params.motor.efficiency_ranges;
    
    % 默认效率
    efficiency = 50;
    
    % 查找转速所在区间
    for i = 1:size(speed_ranges, 1)
        if rpm >= speed_ranges(i, 1) && rpm < speed_ranges(i, 2)
            % 在该区间内，使用区间中值作为效率
            eff_min = efficiency_ranges(i, 1);
            eff_max = efficiency_ranges(i, 2);
            
            % 在区间内线性插值
            range_position = (rpm - speed_ranges(i, 1)) / ...
                           (speed_ranges(i, 2) - speed_ranges(i, 1));
            efficiency = eff_min + range_position * (eff_max - eff_min);
            
            break;
        end
    end
    
    % 处理边界情况
    if rpm >= speed_ranges(end, 2)
        % 超过最高转速区间，使用最后一个区间的平均效率
        efficiency = mean(efficiency_ranges(end, :));
    end
    
end
