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

    % Initialize figure and arrays
    figure('Name', 'Live Temperature Monitor');
    time_data = [];
    temp_data = [];

    disp('Live monitor started...')
    % start timer
    tStart = tic;   % record start time
    last_read_time = -1; % last temperature-reading time 
    current_temp = 20;   % initialize temperature
    
    % enter infinite loop
    while true
        tCurrent = toc(tStart); % get the run time

        %Read Temp and Update Plot
        if tCurrent - last_read_time >= 1.0

            % Read voltage and calculate temperature
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
            
            %Dynamically extend x axis
            xlim([0, max(10, tCurrent)]); 
            drawnow; % update the figure
            
            last_read_time = floor(tCurrent); % update last temperature reading time
        end
        
        % LED Control
        if current_temp >= 18 && current_temp <= 24
            % Comfort zone:open green_light and close others
            writeDigitalPin(a, 'D2', 1);
            writeDigitalPin(a, 'D3', 0);
            writeDigitalPin(a, 'D4', 0);
            
        elseif current_temp < 18
            % cold:shinning yellow light, close others
            writeDigitalPin(a, 'D2', 0);
            writeDigitalPin(a, 'D4', 0);

            %Utilize the remainder method
            if mod(tCurrent, 1.0) < 0.5 
                writeDigitalPin(a, 'D3', 1);
            else
                writeDigitalPin(a, 'D3', 0);
            end
            
        elseif current_temp > 24
            %hot:shinning red light, close others
            writeDigitalPin(a, 'D2', 0);
            writeDigitalPin(a, 'D3', 0);
            
            % remainder method
            if mod(tCurrent, 0.5) < 0.25 
                writeDigitalPin(a, 'D4', 1);
            else
                writeDigitalPin(a, 'D4', 0);
            end
        end
        
        % very short pause, let time step=0.01
        pause(0.01); 
    end
end