function temp_monitor(a)
% TEMP_MONITOR Live temperature tracking and LED warning system.
%   temp_monitor(a) takes an active Arduino object 'a' as input.
%   It indefinitely monitors temperature reading from A0 at 1s intervals
%   and dynamically updates a live plot.
%   LEDs blink based on comfort range (18-24 C):
%   - Green (D2): Constant light if in range.
%   - Yellow (D3): Blinks at 0.5s intervals if Temp < 18 C.
%   - Red (D4): Blinks at 0.25s intervals if Temp > 24 C.
%   Press Ctrl+C in Command Window to stop execution.

    % 1. initialize
    figure('Name', 'Live Temperature Monitor');
    time_data = [];
    temp_data = [];

    
    % time record
    tStart = tic; % 记录起点时间
    last_read_time = -1; % 上一次读取温度的时间
    current_temp = 20;   % 给个初始默认温度
    
    % 3. 开始无限循环
    while true
        tCurrent = toc(tStart); % 获取从启动到现在经过了多少秒
        

        if tCurrent - last_read_time >= 1.0

            % transform voltage into temperature
            v = readVoltage(a, 'A0');
            current_temp = (v - 0.5) / 0.01;
            
            % record data
            time_data = [time_data, tCurrent];
            temp_data = [temp_data, current_temp];
            
            % plot
            plot(time_data, temp_data);
            xlabel('Time (s)');
            ylabel('Temperature (^\circC)');
            title(sprintf('Live Temp: %.2f ^\\circC', current_temp));
            grid on;
            
            % 让 X 轴动态延伸 (最少显示10秒，多了就跟着时间走)
            xlim([0, max(10, tCurrent)]); 
            drawnow; % update the graph
            
            last_read_time = floor(tCurrent); % 更新上一次读取的时间
        end
        

        if current_temp >= 18 && current_temp <= 24
            % 正常范围：绿灯常亮，其他全灭
            writeDigitalPin(a, 'D2', 1);
            writeDigitalPin(a, 'D3', 0);
            writeDigitalPin(a, 'D4', 0);
            
        elseif current_temp < 18
            % 偏冷：关绿红，黄灯以0.5秒间隔闪烁 (周期为1秒)
            writeDigitalPin(a, 'D2', 0);
            writeDigitalPin(a, 'D4', 0);
            % 神奇的求余法：每1秒的前0.5秒亮，后0.5秒灭
            if mod(tCurrent, 1.0) < 0.5 
                writeDigitalPin(a, 'D3', 1);
            else
                writeDigitalPin(a, 'D3', 0);
            end
            
        elseif current_temp > 24
            % 偏热：关绿黄，红灯以0.25秒间隔闪烁 (周期为0.5秒)
            writeDigitalPin(a, 'D2', 0);
            writeDigitalPin(a, 'D3', 0);
            % 每0.5秒的前0.25秒亮，后0.25秒灭
            if mod(tCurrent, 0.5) < 0.25 
                writeDigitalPin(a, 'D4', 1);
            else
                writeDigitalPin(a, 'D4', 0);
            end
        end
        
        % 极短暂的暂停，让 MATLAB 喘口气，防止电脑死机
        pause(0.01); 
    end
end