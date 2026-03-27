function [efficiency, energy_recovered, energy_total, efficiency_series] = ...
    efficiency_calculator(motor_power_series, brake_power_series, time_series, config)
% EFFICIENCY_CALCULATOR 能量回收效率计算
%
% 计算再生制动能量回收效率
% η = (E_recovered / E_brake_total) × 100%
%
% 输入参数:
%   motor_power_series - 电机功率时间序列 (kW)
%   brake_power_series - 总制动功率时间序列 (kW)
%   time_series        - 时间序列 (s)
%   config             - 仿真配置结构体（可选）
%
% 输出参数:
%   efficiency         - 平均能量回收效率 (%)
%   energy_recovered   - 累计回收能量 (kWh)
%   energy_total       - 累计总制动能量 (kWh)
%   efficiency_series  - 瞬时效率时间序列 (%)
%
% 示例:
%   config = simulation_config();
%   [eta, E_rec, E_tot, eta_t] = efficiency_calculator(P_motor, P_brake, t, config);

    % 输入验证
    if nargin < 4
        config = simulation_config();
    end
    
    % 确保输入为列向量
    motor_power_series = motor_power_series(:);
    brake_power_series = brake_power_series(:);
    time_series = time_series(:);
    
    % 验证数据长度一致
    n = length(time_series);
    if length(motor_power_series) ~= n || length(brake_power_series) ~= n
        error('efficiency_calculator:DimensionMismatch', ...
              '输入序列长度必须一致');
    end
    
    % 计算时间步长
    if n > 1
        dt = diff(time_series);
        dt = [dt(1); dt];  % 第一个时间步使用第二个的值
    else
        dt = config.sampling_time;
    end
    
    % 计算瞬时效率（向量化）
    efficiency_series = zeros(n, 1);
    valid_brake = brake_power_series > 1e-6;
    efficiency_series(valid_brake) = (motor_power_series(valid_brake) ./ brake_power_series(valid_brake)) * 100;
    efficiency_series = max(0, min(100, efficiency_series));  % 限制范围
    
    % 使用梯形法则进行数值积分
    % E = ∫ P dt
    energy_recovered = trapz_integration(motor_power_series, dt) / 3600;  % 转换为 kWh
    energy_total = trapz_integration(brake_power_series, dt) / 3600;      % 转换为 kWh
    
    % 计算平均效率
    if energy_total > 1e-9  % 避免除零
        efficiency = (energy_recovered / energy_total) * 100;
    else
        efficiency = 0;
    end
    
    % 限制效率范围
    efficiency = max(0, min(100, efficiency));
    
end


function integral = trapz_integration(y, dt)
% TRAPZ_INTEGRATION 梯形法则数值积分（优化版）
%
% 输入参数:
%   y  - 被积函数值序列
%   dt - 时间步长序列或标量
%
% 输出参数:
%   integral - 积分结果

    if isscalar(dt)
        % 均匀时间步长 - 使用MATLAB内置trapz函数（更快）
        integral = trapz(y) * dt;
    else
        % 非均匀时间步长 - 向量化计算
        integral = sum(0.5 * (y(1:end-1) + y(2:end)) .* dt(1:end-1));
    end
    
end
