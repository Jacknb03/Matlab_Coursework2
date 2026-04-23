% Insert name here
    %Jiekai Song
% Insert email address here
    %biyjs43@nottingham.edu.cn

%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]

clear a; % clear possible old connection
a = arduino(); % connection
disp('Arduino connected！');

disp('testing green light shinning...');
% shinning 5 times， 0.5s open 0.5s close
for i = 1:5
    writeDigitalPin(a, 'D2', 1); % light
    pause(0.5);                  % wait 0.5秒
    writeDigitalPin(a, 'D2', 0); % 0 shut down
    pause(0.5);
end
disp('test is done');
%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

% Insert answers here

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% Insert answers here


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

% Insert answers here


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here