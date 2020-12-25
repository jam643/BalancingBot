function plotIMU
clear
clc
%User Defined Properties 
s = serial('COM5', 'Baudrate', 9600);          % define the Arduino Communication port
get(s,{'InputBufferSize','BytesAvailable'})

try
    fopen(s);
catch err
    fclose(instrfind);
    error('Make sure you select the correct COM Port where the Arduino is connected.');
end

figure()
h1 = fill3(0,0,0,[0.3,0.3,0.3]);
hold on;
h2 = fill3(0,0,0,[0.1,0.1,0.1]);
axis equal 
axis([-2 2 -2 2 -2 2]);
xlabel('X')
ylabel('Y')
zlabel('Z')
grid on
L = 1; W = 1; H = 0.05;
f1 = [-L,L,L,-L;...
    -W,-W,W,W;...
    H,H,H,H];
f2 = [-L,L,L,-L;...
    -W,-W,W,W;...
    -H,-H,-H,-H];
while ishandle(h1)
    readData=fscanf(s);
    data = str2num(readData);
    if length(data) == 8
        get(s,{'InputBufferSize','BytesAvailable'})
        phi = data(7);
        theta = data(8);
        f1_rot = R(phi,theta,f1);
        f2_rot = R(phi,theta,f2);
        set(h1,'XData',f1_rot(1,:),'YData',f1_rot(2,:),'ZData',f1_rot(3,:))
        set(h2,'XData',f2_rot(1,:),'YData',f2_rot(2,:),'ZData',f2_rot(3,:))
        drawnow
    end
end
get(s,{'InputBufferSize','BytesAvailable'})
fclose(s);
delete(s);
clear s;

function rot_face = R(phi,theta,face)
    Rotx = [1,    0,  0;...
    0, cosd(phi), -sind(phi);...
    0, sind(phi), cosd(phi)];

    Roty = [cosd(theta), 0, sind(theta);...
            0, 1, 0;...
            -sind(theta), 0, cosd(theta)];
    Rot = Roty*Rotx;
    for k = 1:size(face,2)
        rot_face(:,k) = Rot*face(:,k);
    end




