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


% collect data
for i = 1:num_samples

    %read voltage on A0
    v = readVoltage(a, sensor_pin);
    
    % trsform voltage into temperature
    temp_array(i) = (v - 0.5) / 0.01;
    time_array(i) = i - 1;      % record current time(s)
    
    pause(1); % pause 1s 
end


disp('开始采集温度数据，请不要拔掉线缆...');

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