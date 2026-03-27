function [motor_brake_ratio, hydraulic_brake_ratio, motor_brake_force, hydraulic_brake_force] = ...
    optimized_strategy(brake_demand, velocity, SOC, total_brake_force, params)
% OPTIMIZED_STRATEGY 优化制动力分配策略（模糊逻辑控制）
%
% 基于模糊逻辑的动态制动力分配策略
% 输入：制动踏板开度、车速、电池SOC
% 输出：电机制动力占比
%
% 输入参数:
%   brake_demand       - 制动踏板开度 (%), 0-100
%   velocity           - 车速 (km/h), 0-120
%   SOC                - 电池荷电状态 (%), 0-100
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
%   [r_m, r_h, F_m, F_h] = optimized_strategy(50, 60, 70, 5000, params);

    % 输入验证
    if nargin < 5
        params = vehicle_params();
    end
    
    validateattributes(brake_demand, {'numeric'}, {'scalar', '>=', 0, '<=', 100}, ...
        'optimized_strategy', 'brake_demand');
    validateattributes(velocity, {'numeric'}, {'scalar', '>=', 0, '<=', 120}, ...
        'optimized_strategy', 'velocity');
    validateattributes(SOC, {'numeric'}, {'scalar', '>=', 0, '<=', 100}, ...
        'optimized_strategy', 'SOC');
    validateattributes(total_brake_force, {'numeric'}, {'scalar', '>=', 0}, ...
        'optimized_strategy', 'total_brake_force');
    
    % 使用简化的模糊逻辑规则（不依赖Fuzzy Logic Toolbox）
    % 基于规则的模糊推理
    motor_ratio_fuzzy = fuzzy_inference(brake_demand, velocity, SOC);
    
    % SOC高值约束：SOC > 90% 时降低再生制动占比
    if SOC > 90
        % 线性降低再生制动占比
        soc_factor = (95 - SOC) / (95 - 90);
        soc_factor = max(0, min(1, soc_factor));
        motor_ratio_fuzzy = motor_ratio_fuzzy * soc_factor;
    end
    
    % 计算电机最大可提供的制动力
    max_motor_torque = params.motor.max_regen_torque;  % 120 Nm
    wheel_radius = params.vehicle.wheel_radius;
    gear_ratio = 10;
    
    max_motor_brake_force = max_motor_torque * gear_ratio / wheel_radius;
    
    % 低速时电机制动力衰减
    v_ms = velocity / 3.6;
    wheel_speed = v_ms / wheel_radius;
    rpm = wheel_speed * gear_ratio * 60 / (2 * pi);
    
    if rpm < 1500
        speed_factor = rpm / 1500;
        max_motor_brake_force = max_motor_brake_force * speed_factor;
    end
    
    % 根据模糊推理结果分配制动力
    desired_motor_force = total_brake_force * (motor_ratio_fuzzy / 100);
    motor_brake_force = min(desired_motor_force, max_motor_brake_force);
    motor_brake_force = max(0, motor_brake_force);
    
    hydraulic_brake_force = max(0, total_brake_force - motor_brake_force);
    
    % 计算实际占比
    if total_brake_force > 0
        motor_brake_ratio = (motor_brake_force / total_brake_force) * 100;
        hydraulic_brake_ratio = (hydraulic_brake_force / total_brake_force) * 100;
    else
        motor_brake_ratio = 0;
        hydraulic_brake_ratio = 0;
    end
    
end


function motor_ratio = fuzzy_inference(brake_demand, velocity, SOC)
% FUZZY_INFERENCE 简化的模糊推理
%
% 基于49条模糊规则的简化实现
%
% 输入参数:
%   brake_demand - 制动踏板开度 (%)
%   velocity     - 车速 (km/h)
%   SOC          - 电池荷电状态 (%)
%
% 输出参数:
%   motor_ratio - 电机制动力占比 (%)

    % 定义模糊集合的隶属度函数（三角形）
    
    % 制动踏板开度：低(L)、中(M)、高(H)
    pedal_L = trimf(brake_demand, [0, 0, 50]);
    pedal_M = trimf(brake_demand, [0, 50, 100]);
    pedal_H = trimf(brake_demand, [50, 100, 100]);
    
    % 车速：低(L)、中(M)、高(H)
    speed_L = trimf(velocity, [0, 0, 40]);
    speed_M = trimf(velocity, [20, 60, 100]);
    speed_H = trimf(velocity, [80, 120, 120]);
    
    % SOC：低(L)、中(M)、高(H)
    soc_L = trimf(SOC, [0, 0, 40]);
    soc_M = trimf(SOC, [30, 60, 90]);
    soc_H = trimf(SOC, [80, 100, 100]);
    
    % 输出模糊集合：很低(VL)、低(L)、中(M)、高(H)、很高(VH)
    output_VL = 30;  % 很低：30%
    output_L = 50;   % 低：50%
    output_M = 70;   % 中：70%
    output_H = 85;   % 高：85%
    output_VH = 95;  % 很高：95%
    
    % 模糊规则（49条规则的简化版本）
    % 规则格式：IF (pedal AND speed AND soc) THEN output
    
    rules = [];
    weights = [];
    
    % 规则1-9：低踏板开度
    rules = [rules; output_VH]; weights = [weights; pedal_L * speed_L * soc_L];
    rules = [rules; output_VH]; weights = [weights; pedal_L * speed_L * soc_M];
    rules = [rules; output_H];  weights = [weights; pedal_L * speed_L * soc_H];
    rules = [rules; output_VH]; weights = [weights; pedal_L * speed_M * soc_L];
    rules = [rules; output_VH]; weights = [weights; pedal_L * speed_M * soc_M];
    rules = [rules; output_H];  weights = [weights; pedal_L * speed_M * soc_H];
    rules = [rules; output_H];  weights = [weights; pedal_L * speed_H * soc_L];
    rules = [rules; output_H];  weights = [weights; pedal_L * speed_H * soc_M];
    rules = [rules; output_M];  weights = [weights; pedal_L * speed_H * soc_H];
    
    % 规则10-18：中踏板开度
    rules = [rules; output_H];  weights = [weights; pedal_M * speed_L * soc_L];
    rules = [rules; output_H];  weights = [weights; pedal_M * speed_L * soc_M];
    rules = [rules; output_M];  weights = [weights; pedal_M * speed_L * soc_H];
    rules = [rules; output_H];  weights = [weights; pedal_M * speed_M * soc_L];
    rules = [rules; output_M];  weights = [weights; pedal_M * speed_M * soc_M];
    rules = [rules; output_M];  weights = [weights; pedal_M * speed_M * soc_H];
    rules = [rules; output_M];  weights = [weights; pedal_M * speed_H * soc_L];
    rules = [rules; output_M];  weights = [weights; pedal_M * speed_H * soc_M];
    rules = [rules; output_L];  weights = [weights; pedal_M * speed_H * soc_H];
    
    % 规则19-27：高踏板开度
    rules = [rules; output_M];  weights = [weights; pedal_H * speed_L * soc_L];
    rules = [rules; output_M];  weights = [weights; pedal_H * speed_L * soc_M];
    rules = [rules; output_L];  weights = [weights; pedal_H * speed_L * soc_H];
    rules = [rules; output_M];  weights = [weights; pedal_H * speed_M * soc_L];
    rules = [rules; output_L];  weights = [weights; pedal_H * speed_M * soc_M];
    rules = [rules; output_L];  weights = [weights; pedal_H * speed_M * soc_H];
    rules = [rules; output_L];  weights = [weights; pedal_H * speed_H * soc_L];
    rules = [rules; output_L];  weights = [weights; pedal_H * speed_H * soc_M];
    rules = [rules; output_VL]; weights = [weights; pedal_H * speed_H * soc_H];
    
    % 重心法解模糊
    total_weight = sum(weights);
    if total_weight > 0
        motor_ratio = sum(rules .* weights) / total_weight;
    else
        motor_ratio = 50;  % 默认值
    end
    
    % 限制输出范围
    motor_ratio = max(0, min(100, motor_ratio));
    
end


function y = trimf(x, params)
% TRIMF 三角形隶属度函数
%
% 输入参数:
%   x      - 输入值
%   params - [a, b, c]，其中 a <= b <= c
%
% 输出参数:
%   y - 隶属度值 (0-1)

    a = params(1);
    b = params(2);
    c = params(3);
    
    if x <= a || x >= c
        y = 0;
    elseif x == b
        y = 1;
    elseif x > a && x < b
        y = (x - a) / (b - a);
    else  % x > b && x < c
        y = (c - x) / (c - b);
    end
    
end
