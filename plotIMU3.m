function plotIMU2
clear
clc
%User Defined Properties 
s = serial('COM5', 'Baudrate', 115200);          % define the Arduino Communication port
s.Terminator = 'CR';
get(s,{'InputBufferSize','BytesAvailable'});

try
    fopen(s);
catch err
    fclose(instrfind);
    error('Make sure you select the correct COM Port where the Arduino is connected.');
end

phidot = [];
time = [];

figure;
s1 = subplot(2,2,1);
h = animatedline(s1);
dur = 10;
xlim([0,dur])

s2 = subplot(2,2,2);
h_m1_speed = animatedline(s2);
xlim([0,dur])

s3 = subplot(2,2,3);
h_volt = animatedline(s3,'Color','k');
h_P = animatedline(s3,'Color','r');
h_I = animatedline(s3,'Color','b');
h_D = animatedline(s3,'Color','g');
xlim([0,dur])

tic
while ishandle(h)
    readData=fscanf(s);
    data = str2num(readData);
    if length(data) >= 7
        if toc > dur
            tic
            clearpoints(h)
            clearpoints(h_volt)
            clearpoints(h_P)
            clearpoints(h_I)
            clearpoints(h_D)
            clearpoints(h_m1_speed);
        end
        get(s,{'InputBufferSize','BytesAvailable'});
        theta = data(1);
        voltage = data(2);
        P = data(3);
        I = data(4);
        D = data(5);
        m1_speed = data(6);
        m2_speed = data(7);
        addpoints(h,toc,theta);
        addpoints(h_m1_speed,toc,m1_speed);
        addpoints(h_volt,toc,voltage);
        addpoints(h_P,toc,P);
        addpoints(h_I,toc,I);
        addpoints(h_D,toc,D);
        drawnow;
    end
end

fclose(s);
delete(s);
clear s;




