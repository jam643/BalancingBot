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

h1 = figure('units','normalized','outerposition',[0.1 0.1 0.8 0.8]);
line_gyro = line(0,0,'Color',[0,0,0],'linewidth',20);
line_accel = line(0,0,'Color',[0.3,0.3,0.3],'linewidth',20);
line_comp = line(0,0,'Color',[0.5,0.5,0.5],'linewidth',20);
wheel = line(0,0,'Color',[0,0,0],'linewidth',10);
wheelrot = line(0,0,'Color',[0,0,0],'linewidth',2);
hold on;
axis equal;
xlim([-4,4]);
ylim([-4,1]);
pause(0.1);

tic
while ishandle(h1)
    readData=fscanf(s);
    data = str2num(readData);
    if length(data) >= 5
        get(s,{'InputBufferSize','BytesAvailable'});
        theta_gyro = data(1);
        theta_accel = data(2);
        theta = data(3);
        phi = data(4)*2*pi;
        if toc > 3
            tic
            phidot = [];
            time = [];
        end
        phidot = [phidot,data(5)/2];
        time = [time,mod(toc,3)];
        set(line_gyro,'XData',[sind(theta_gyro),-sind(theta_gyro)]-3,'YData',[cosd(theta_gyro),-cosd(theta_gyro)]);
        set(line_accel,'XData',[sind(theta_accel),-sind(theta_accel)],'YData',[cosd(theta_accel),-cosd(theta_accel)]);
        set(line_comp,'XData',[sind(theta),-sind(theta)]+3,'YData',[cosd(theta),-cosd(theta)]);
        set(wheel,'XData',[-cos(phi),cos(phi)]-3,'YData',[-sin(phi),sin(phi)]-3);
        set(wheelrot,'XData',time,'YData',phidot-3);
        
        drawnow;
    end
end

fclose(s);
delete(s);
clear s;




