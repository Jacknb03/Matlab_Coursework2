% Insert name here
    %Jiekai Song
% Insert email address here
    %biyjs43@nottingham.edu.cn

%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]

clear a; % clear possible old connection
a = arduino('COM8', 'Uno'); % connection
disp('Arduino connected！');

disp('testing green light shinning...');
% shinning 5 times， 0.5s on 0.5s off
for i = 1:5
    writeDigitalPin(a, 'D2', 1); % on
    pause(0.5);                  % wait 0.5s
    writeDigitalPin(a, 'D2', 0); % shut down
    pause(0.5);           %keep 0.5s
end
disp('test is done');
%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

%set parameters
duration = 600; % 600s total
num_samples = duration + 1;     % Read (n+1) data (0s,1s...600s)

%initialize time&temp arrays
time_array = zeros(1, num_samples); 
temp_array = zeros(1, num_samples); 

%choose analog pin'A0‘
sensor_pin = 'A0'; 

disp('start recording temperature')

% collect data
for i = 1:num_samples

    %read voltage on A0
    v = readVoltage(a, sensor_pin);
    
    % trsform voltage into temperature
    temp_array(i) = (v - 0.5) / 0.01;
    time_array(i) = i - 1;      % record current time(s)
    
    pause(1); % pause 1s 
end

% max,min&average temperature 
max_temp = max(temp_array);
min_temp = min(temp_array);
avg_temp = mean(temp_array);

%2.Plot
figure; %create a new window
plot(time_array, temp_array);
xlabel('Time (s)');
ylabel('Temperature (^\circC)');
title('Capsule Temperature over 10 Minutes');

% get current date
date_str = datestr(now, 'dd/mm/yyyy'); 

% adjusting character formatting
log_text = sprintf('Data logging initiated - %s\n', date_str);
log_text = sprintf('%sLocation - Nottingham\n\n', log_text); % 追加字符

% read all data
for min_idx = 0:10

    % transfer time unit to index numbers
    array_idx = (min_idx * 60) + 1; 
    
    % minute and temperature
    log_text = sprintf('%sMinute\t\t%d\n', log_text, min_idx);
    log_text = sprintf('%sTemperature\t%.2f C\n\n', log_text, temp_array(array_idx));
end

% max,min & average temperature
log_text = sprintf('%sMax temp\t%.2f C\n', log_text, max_temp);
log_text = sprintf('%sMin temp\t%.2f C\n', log_text, min_temp);
log_text = sprintf('%sAverage temp\t%.2f C\n\n', log_text, avg_temp);
log_text = sprintf('%sData logging terminated\n', log_text);

% display to the screen
disp(log_text);

% write to files
fileID = fopen('capsule_temperature.txt', 'w'); 
fprintf(fileID, '%s', log_text);
fclose(fileID); 

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% 打印函数的文档以供检查 (对应题目要求 l)
doc temp_monitor; 

% using function temp_monitor
temp_monitor(a);
    


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

function temp_prediction(a)
% TEMP_PREDICTION Live temperature prediction and rate warning.
%   This function continuously monitors temperature and uses a 10-second
%   sliding window algorithm to filter out noise and calculate the true 
%   rate of temperature change (derivative).
%   It predicts the temperature 5 minutes (300s) into the future.
%   LED indicators (Constant):
%   - Red: Temperature increasing faster than +4 C/min.
%   - Yellow: Temperature decreasing faster than -4 C/min.
%   - Green: Temperature is stable.
%   Press Ctrl+C to terminate.

    disp('预测算法已启动！正在收集初始数据(约需10秒)，请稍候...');
    
    % 初始化滑动窗口 (用于平滑噪声)
    buffer_size = 10; 
    temp_buffer = []; 
    
    % 阈值转换：题目给定的是 4度/分钟，换算成秒就是 4/60 = 0.0667 度/秒
    threshold_rate_sec = 4.0 / 60.0; 
    
    tStart = tic;
    last_read_time = -1;
    
    while true
        tCurrent = toc(tStart);
        
        % 每隔 1 秒执行一次核心算法
        if tCurrent - last_read_time >= 1.0
            % 1. 读取温度
            v = readVoltage(a, 'A0');
            current_temp = (v - 0.5) / 0.01;
            
            % 2. 存入滑动窗口，保持窗口大小为 10
            temp_buffer = [temp_buffer, current_temp];
            if length(temp_buffer) > buffer_size
                temp_buffer(1) = []; % 删除最老的数据
            end
            
            % 3. 只有当窗口收集满了 10 个数据，才开始计算和预测
            if length(temp_buffer) == buffer_size
                % 计算过去 10 秒的平均变化率 (°C/s)
                rate_per_sec = (temp_buffer(end) - temp_buffer(1)) / (buffer_size - 1);
                rate_per_min = rate_per_sec * 60; % 换算回 °C/min 以便显示
                
                % 预测 5 分钟 (300秒) 后的温度
                predicted_temp = current_temp + (rate_per_sec * 300);
                
                % 打印到屏幕
                fprintf('Current: %.2f C | Rate: %+.2f C/min | Predicted in 5m: %.2f C\n', ...
                        current_temp, rate_per_min, predicted_temp);
                
                % 4. 根据变化率控制 LED (常亮即可，不用闪烁)
                if rate_per_min > 4.0
                    % 升温过快：红灯
                    writeDigitalPin(a, 'D2', 0);
                    writeDigitalPin(a, 'D3', 0);
                    writeDigitalPin(a, 'D4', 1);
                elseif rate_per_min < -4.0
                    % 降温过快：黄灯
                    writeDigitalPin(a, 'D2', 0);
                    writeDigitalPin(a, 'D3', 1);
                    writeDigitalPin(a, 'D4', 0);
                else
                    % 稳定状态：绿灯
                    writeDigitalPin(a, 'D2', 1);
                    writeDigitalPin(a, 'D3', 0);
                    writeDigitalPin(a, 'D4', 0);
                end
            end
            
            last_read_time = floor(tCurrent);
        end
        pause(0.01);
    end
end


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here