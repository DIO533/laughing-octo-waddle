function [time, velocity, brake_events] = driving_cycle_data(cycle_type)
% DRIVING_CYCLE_DATA 驾驶循环工况数据
%
% 提供标准驾驶循环的速度-时间数据
%
% 输入参数:
%   cycle_type - 工况类型: 'NEDC' | 'UDDS'
%
% 输出参数:
%   time         - 时间序列 (s)
%   velocity     - 速度序列 (km/h)
%   brake_events - 制动事件结构体数组
%                  .start_idx - 制动开始索引
%                  .end_idx   - 制动结束索引
%                  .duration  - 制动持续时间 (s)
%
% 示例:
%   [t, v, events] = driving_cycle_data('NEDC');

    % 输入验证
    validatestring(cycle_type, {'NEDC', 'UDDS'}, 'driving_cycle_data', 'cycle_type');
    
    % 根据工况类型生成数据
    switch upper(cycle_type)
        case 'NEDC'
            [time, velocity] = generate_NEDC_cycle();
        case 'UDDS'
            [time, velocity] = generate_UDDS_cycle();
        otherwise
            error('driving_cycle_data:InvalidCycle', ...
                  '不支持的工况类型: %s', cycle_type);
    end
    
    % 识别制动事件
    brake_events = identify_brake_events(time, velocity);
    
end


function [time, velocity] = generate_NEDC_cycle()
% GENERATE_NEDC_CYCLE 生成NEDC工况数据
%
% NEDC (New European Driving Cycle) 新欧洲驾驶循环
% 总时长: 1180秒
% 最高速度: 120 km/h

    % 时间步长
    dt = 1;  % 1秒
    
    % 预分配数组
    total_time = 1180;
    time = (0:dt:total_time)';  % 列向量
    velocity = zeros(length(time), 1);  % 列向量
    
    % ECE-15 城市循环（重复4次）
    % 每个循环195秒
    for cycle = 1:4
        offset = (cycle - 1) * 195;
        
        % 第一段：怠速
        velocity(offset+1:offset+11) = 0;
        
        % 加速到15 km/h
        velocity(offset+12:offset+15) = linspace(0, 15, 4);
        
        % 匀速15 km/h
        velocity(offset+16:offset+23) = 15;
        
        % 减速到0
        velocity(offset+24:offset+26) = linspace(15, 0, 3);
        
        % 怠速
        velocity(offset+27:offset+47) = 0;
        
        % 加速到32 km/h
        velocity(offset+48:offset+52) = linspace(0, 32, 5);
        
        % 匀速32 km/h
        velocity(offset+53:offset+76) = 32;
        
        % 减速到0
        velocity(offset+77:offset+81) = linspace(32, 0, 5);
        
        % 怠速
        velocity(offset+82:offset+102) = 0;
        
        % 加速到50 km/h
        velocity(offset+103:offset+110) = linspace(0, 50, 8);
        
        % 匀速50 km/h
        velocity(offset+111:offset+122) = 50;
        
        % 减速到35 km/h
        velocity(offset+123:offset+130) = linspace(50, 35, 8);
        
        % 匀速35 km/h
        velocity(offset+131:offset+143) = 35;
        
        % 减速到0
        velocity(offset+144:offset+151) = linspace(35, 0, 8);
        
        % 怠速
        if cycle < 4
            velocity(offset+152:offset+195) = 0;
        end
    end
    
    % EUDC 郊区循环（从780秒开始）
    eudc_start = 780;
    
    % 怠速
    velocity(eudc_start+1:eudc_start+20) = 0;
    
    % 加速到70 km/h
    velocity(eudc_start+21:eudc_start+40) = linspace(0, 70, 20);
    
    % 匀速70 km/h
    velocity(eudc_start+41:eudc_start+90) = 70;
    
    % 减速到50 km/h
    velocity(eudc_start+91:eudc_start+100) = linspace(70, 50, 10);
    
    % 匀速50 km/h
    velocity(eudc_start+101:eudc_start+169) = 50;
    
    % 加速到70 km/h
    velocity(eudc_start+170:eudc_start+179) = linspace(50, 70, 10);
    
    % 匀速70 km/h
    velocity(eudc_start+180:eudc_start+229) = 70;
    
    % 加速到100 km/h
    velocity(eudc_start+230:eudc_start+249) = linspace(70, 100, 20);
    
    % 匀速100 km/h
    velocity(eudc_start+250:eudc_start+279) = 100;
    
    % 加速到120 km/h
    velocity(eudc_start+280:eudc_start+289) = linspace(100, 120, 10);
    
    % 匀速120 km/h
    velocity(eudc_start+290:eudc_start+299) = 120;
    
    % 减速到0
    velocity(eudc_start+300:eudc_start+329) = linspace(120, 0, 30);
    
    % 怠速到结束
    velocity(eudc_start+330:end) = 0;
    
end


function [time, velocity] = generate_UDDS_cycle()
% GENERATE_UDDS_CYCLE 生成UDDS工况数据
%
% UDDS (Urban Dynamometer Driving Schedule) 城市道路循环
% 总时长: 1369秒
% 最高速度: 91.2 km/h

    dt = 1;  % 1秒
    time = (0:dt:1369)';  % 列向量
    
    % UDDS工况的简化版本（实际工况更复杂）
    % 这里生成一个近似的城市驾驶循环
    velocity = zeros(length(time), 1);  % 列向量
    
    % 分段生成速度曲线
    segments = [
        0, 50, 0, 32;      % 0-50s: 加速到32 km/h
        50, 100, 32, 0;    % 50-100s: 减速到0
        100, 150, 0, 0;    % 100-150s: 怠速
        150, 200, 0, 48;   % 150-200s: 加速到48 km/h
        200, 280, 48, 48;  % 200-280s: 匀速48 km/h
        280, 320, 48, 0;   % 280-320s: 减速到0
        320, 370, 0, 0;    % 320-370s: 怠速
        370, 430, 0, 64;   % 370-430s: 加速到64 km/h
        430, 500, 64, 64;  % 430-500s: 匀速64 km/h
        500, 540, 64, 32;  % 500-540s: 减速到32 km/h
        540, 600, 32, 32;  % 540-600s: 匀速32 km/h
        600, 640, 32, 0;   % 600-640s: 减速到0
        640, 700, 0, 0;    % 640-700s: 怠速
        700, 770, 0, 80;   % 700-770s: 加速到80 km/h
        770, 850, 80, 80;  % 770-850s: 匀速80 km/h
        850, 900, 80, 40;  % 850-900s: 减速到40 km/h
        900, 970, 40, 40;  % 900-970s: 匀速40 km/h
        970, 1020, 40, 0;  % 970-1020s: 减速到0
        1020, 1080, 0, 0;  % 1020-1080s: 怠速
        1080, 1150, 0, 90; % 1080-1150s: 加速到90 km/h
        1150, 1230, 90, 90;% 1150-1230s: 匀速90 km/h
        1230, 1300, 90, 0; % 1230-1300s: 减速到0
        1300, 1369, 0, 0   % 1300-1369s: 怠速
    ];
    
    for i = 1:size(segments, 1)
        t_start = segments(i, 1) + 1;
        t_end = segments(i, 2);
        v_start = segments(i, 3);
        v_end = segments(i, 4);
        
        if t_end <= length(time)
            velocity(t_start:t_end) = linspace(v_start, v_end, t_end - t_start + 1);
        end
    end
    
end


function brake_events = identify_brake_events(time, velocity)
% IDENTIFY_BRAKE_EVENTS 识别制动事件
%
% 识别速度下降段作为制动事件
%
% 输入参数:
%   time     - 时间序列 (s)
%   velocity - 速度序列 (km/h)
%
% 输出参数:
%   brake_events - 制动事件结构体数组

    brake_events = struct('start_idx', {}, 'end_idx', {}, 'duration', {});
    
    % 计算速度变化率
    dv = [0; diff(velocity(:))];
    
    % 识别制动（速度下降）
    % 阈值：速度下降超过0.5 km/h
    is_braking = dv < -0.5;
    
    % 查找连续制动段
    event_count = 0;
    in_brake_event = false;
    start_idx = 0;
    
    for i = 1:length(is_braking)
        if is_braking(i) && ~in_brake_event
            % 制动开始
            in_brake_event = true;
            start_idx = i;
        elseif ~is_braking(i) && in_brake_event
            % 制动结束
            in_brake_event = false;
            event_count = event_count + 1;
            brake_events(event_count).start_idx = start_idx;
            brake_events(event_count).end_idx = i - 1;
            brake_events(event_count).duration = time(i-1) - time(start_idx);
        end
    end
    
    % 处理最后一个事件
    if in_brake_event
        event_count = event_count + 1;
        brake_events(event_count).start_idx = start_idx;
        brake_events(event_count).end_idx = length(time);
        brake_events(event_count).duration = time(end) - time(start_idx);
    end
    
end
