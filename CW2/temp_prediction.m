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


    disp('The prediction has been launched! please wait for 10s...');

    % Initialize sliding window buffer to smooth out signal noise
    buffer_size = 10; 
    temp_buffer = []; 

    % Convert threshold: 4 C/min is equivalent to 0.0667 C/s
    threshold_rate_sec = 4.0 / 60.0; 

    tStart = tic;
    last_read_time = -1;

    while true
        tCurrent = toc(tStart);

        % Execute the core algorithm every 1 second exactly
        if tCurrent - last_read_time >= 1.0
            
            % read temperature
            v = readVoltage(a, 'A0');
            current_temp = (v - 0.5) / 0.01;

            % Push new temperature data into the sliding window
            temp_buffer = [temp_buffer, current_temp];
            if length(temp_buffer) > buffer_size
                temp_buffer(1) = [];  %If buffer exceeds maximum size, remove the oldest data point
            end

            % If buffer exceeds maximum size, remove the oldest data point
            if length(temp_buffer) == buffer_size

                % calculate the average rate of change over the last 10 seconds
                rate_per_sec = (temp_buffer(end) - temp_buffer(1)) / (buffer_size - 1);
                rate_per_min = rate_per_sec * 60; % Convert back to C/min for displaying

                % Linear equation to predict temp in 5 minutes (300s)
                predicted_temp = current_temp + (rate_per_sec * 300);

                % Output formatted data
                fprintf('Current: %.2f C | Rate: %+.2f C/min | Predicted in 5m: %.2f C\n', ...
                        current_temp, rate_per_min, predicted_temp);

                % 4. Control LEDs based on the calculated rate of change
                if rate_per_min > 4.0
                    % Heating up rapidly: Constant Red
                    writeDigitalPin(a, 'D2', 0);
                    writeDigitalPin(a, 'D3', 0);
                    writeDigitalPin(a, 'D4', 1);
                elseif rate_per_min < -4.0
                    % Cooling down rapidly: Constant Yellow
                    writeDigitalPin(a, 'D2', 0);
                    writeDigitalPin(a, 'D3', 1);
                    writeDigitalPin(a, 'D4', 0);
                else
                    % Temperature is stable: Constant Green
                    writeDigitalPin(a, 'D2', 1);
                    writeDigitalPin(a, 'D3', 0);
                    writeDigitalPin(a, 'D4', 0);
                end
            end

            last_read_time = floor(tCurrent);
        end
        %Brief pause
        pause(0.01);
    end
end

