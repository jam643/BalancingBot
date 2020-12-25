function motorSysId()
clear
clc
%User Defined Properties 
s = serial('COM5', 'Baudrate', 115200);          % define the Arduino Communication port
s.Terminator = 'CR';
get(s,{'InputBufferSize','BytesAvailable'});

fopen(s);

dist = [];
time = [];

while isempty(time) || time(end) < 50000
    readData=fscanf(s);
    data = str2num(readData);
    if length(data) >= 2
        dist(end+1) = data(1);
        time(end+1) = data(2);
    end
end

figure();
plot(time,dist);

% vel = movmean(diff(dist)./diff(time),80);
vel = filtfilt(ones(1,50)/50,1,diff(dist)./diff(time));
% vel = smoothdata(diff(dist)./diff(time));
% vel = savitzkyGolayFilt(dist,5,1,99);
% [vel, t_vel] = velQuad(dist,time);
% vel = movmean(vel,50);
figure;
plot(time(1:end-1), vel);

fclose(s);
delete(s);
clear s;

function [vel, t_vel] = velQuad(x,t)
prev_time = t(1);
t_vel = [];
vel = [];
for k = 2:length(x)
    if x(k) ~= x(k-1)
        vel(end+1) = (x(k) - x(k-1))/(t(k) - prev_time);
        t_vel(end+1) = mean([t(k),prev_time]);
        prev_time = t(k);        
    end
    
end