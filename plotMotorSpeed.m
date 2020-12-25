function plotMotorSpeed()
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

h1 = figure('units','normalized','outerposition',[0.1 0.1 0.8 0.8]);
speedline = line(0,0,'Color',[0,0,0],'linewidth',2);
hold on;
grid on;
xlim([0,10]);
ylim([-3.5,3.5]);
pause(0.1);

tic
while ishandle(h1)
    readData=fscanf(s);
    data = str2num(readData);
    if length(data) >= 5
        get(s,{'InputBufferSize','BytesAvailable'});
        if toc > 10
            tic
            phidot = [];
            time = [];
        end
        phidot = [phidot,data(5)];
        time = [time,mod(toc,10)];
        set(speedline,'XData',time,'YData',phidot);
        
        drawnow;
    end
end

fclose(s);
delete(s);
clear s;
