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

% duration=600; %acquisition time(s)
% 
% while duration >0
%     A0_voltage= read_voltage(a,'A0')
%     pause(1)
%     duration=duration-1;
    


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

% Insert answers here


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here