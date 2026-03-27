function [energy_stored, battery_efficiency, SOC_new, power_limited] = battery_model(power_in, SOC, temperature, time_step, params)
% BATTERY_MODEL 电池充放电模型
%
% 模拟锂离子电池在充电过程中的行为特性
%
% 输入参数:
%   power_in    - 输入功率 (kW), 正值为充电
%   SOC         - 当前荷电状态 (%), 0-100
%   temperature - 电池温度 (℃)
%   time_step   - 时间步长 (s)
%   params      - 车辆参数结构体（可选）
%
% 输出参数:
%   energy_stored      - 实际存储能量 (kWh)
%   battery_efficiency - 充放电效率 (%), 0-100
%   SOC_new            - 更新后的SOC (%)
%   power_limited      - 实际充电功率（考虑限制后）(kW)
%
% 示例:
%   params = vehicle_params();
%   [E, eta, SOC_new, P] = battery_model(10, 60, 25, 0.1, params);

    % 输入验证
    if nargin < 5
        params = vehicle_params();
    end
    if nargin < 4
        time_step = 0.1;  % 默认时间步长
    end
    
    validateattributes(power_in, {'numeric'}, {'scalar'}, 'battery_model', 'power_in');
    validateattributes(SOC, {'numeric'}, {'scalar', '>=', 0, '<=', 100}, ...
        'battery_model', 'SOC');
    validateattributes(temperature, {'numeric'}, {'scalar', '>=', -40, '<=', 60}, ...
        'battery_model', 'temperature');
    
    % 转换SOC为小数形式
    SOC_decimal = SOC / 100;
    
    % 计算温度相关的充放电效率
    battery_efficiency = calculate_battery_efficiency(temperature, SOC_decimal, params);
    
    % 计算温度相关的电池内阻
    battery_resistance = calculate_battery_resistance(temperature, params);
    
    % 应用SOC限制
    % 当SOC > 90%时，限制充电功率
    if SOC_decimal > params.battery.SOC_high_limit
        % 线性降低充电功率
        power_limit_factor = (params.battery.SOC_max - SOC_decimal) / ...
                            (params.battery.SOC_max - params.battery.SOC_high_limit);
        power_limit_factor = max(0, min(1, power_limit_factor));
    else
        power_limit_factor = 1.0;
    end
    
    % 应用最大充电功率限制
    max_charge_power = params.battery.max_charge_power * power_limit_factor;
    power_limited = min(power_in, max_charge_power);
    power_limited = max(power_limited, 0);  % 只考虑充电
    
    % 计算实际存储能量（考虑效率）
    % E = P * Δt * η
    energy_input = power_limited * (time_step / 3600);  % kWh
    energy_stored = energy_input * (battery_efficiency / 100);
    
    % 更新SOC
    % ΔSOC = E_stored / Capacity
    capacity = params.battery.capacity;  % kWh
    delta_SOC = energy_stored / capacity;
    SOC_new_decimal = SOC_decimal + delta_SOC;
    
    % 限制SOC范围
    SOC_new_decimal = min(SOC_new_decimal, params.battery.SOC_max);
    SOC_new_decimal = max(SOC_new_decimal, params.battery.SOC_min);
    
    % 转换回百分比
    SOC_new = SOC_new_decimal * 100;
    
end


function efficiency = calculate_battery_efficiency(temperature, SOC, params)
% CALCULATE_BATTERY_EFFICIENCY 计算电池充放电效率
%
% 根据温度和SOC计算电池效率
%
% 输入参数:
%   temperature - 电池温度 (℃)
%   SOC         - 荷电状态 (小数形式, 0-1)
%   params      - 车辆参数结构体
%
% 输出参数:
%   efficiency - 充放电效率 (%)

    % 温度效率映射点
    temp_points = [-10, 25, 45];
    eff_points = [
        params.battery.efficiency_m10C * 100,  % -10℃: 80%
        params.battery.efficiency_25C * 100,   % 25℃: 95%
        params.battery.efficiency_45C * 100    % 45℃: 90%
    ];
    
    % 温度插值
    if temperature <= temp_points(1)
        efficiency = eff_points(1);
    elseif temperature >= temp_points(end)
        efficiency = eff_points(end);
    else
        % 线性插值
        efficiency = interp1(temp_points, eff_points, temperature, 'linear');
    end
    
    % SOC影响：高SOC时效率略微下降
    if SOC > params.battery.SOC_high_limit
        % SOC > 90%时，效率线性下降
        soc_factor = 1 - 0.05 * (SOC - params.battery.SOC_high_limit) / ...
                     (params.battery.SOC_max - params.battery.SOC_high_limit);
        efficiency = efficiency * soc_factor;
    end
    
    % 确保效率在合理范围内
    efficiency = max(50, min(100, efficiency));
    
end


function resistance = calculate_battery_resistance(temperature, params)
% CALCULATE_BATTERY_RESISTANCE 计算电池内阻
%
% 根据温度计算电池内阻
%
% 输入参数:
%   temperature - 电池温度 (℃)
%   params      - 车辆参数结构体
%
% 输出参数:
%   resistance - 电池内阻 (Ω)

    % 温度-内阻映射点
    temp_points = [-10, 25, 45];
    res_points = [
        params.battery.resistance_m10C,   % -10℃: 0.030 Ω
        params.battery.resistance_25C,    % 25℃: 0.012 Ω
        params.battery.resistance_45C     % 45℃: 0.015 Ω
    ];
    
    % 温度插值
    if temperature <= temp_points(1)
        resistance = res_points(1);
    elseif temperature >= temp_points(end)
        resistance = res_points(end);
    else
        % 线性插值
        resistance = interp1(temp_points, res_points, temperature, 'linear');
    end
    
end
