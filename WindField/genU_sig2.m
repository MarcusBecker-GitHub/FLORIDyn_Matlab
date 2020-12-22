function [U_abs,U_ang,pos] = genU_sig2(len)
% GENU_SIG creates a vector with wind speed measurements at different
% locations in the field.
%
% INPUT
% len   := int; Number of time steps
%
% OUTPUT
% U_abs := [n x m] vec; n Measurements at m places of the wind velocity 
% U_ang := [n x m] vec; n Measurements at m places of the wind angle 
% pos   := [m x 2] vec; m (x,y) positions of the measurements
%

U_free = 8;
% In Deg
%phi = [90,95,110,105];

meas = [ones(1,76)*15,linspace(15,75,75),ones(1,100)*75]';
phi = [meas,meas,meas,meas];
pos = [0,0;3000,0;0,3000;3000,3000];
%phi = [90,90,90,90,90,90,90,90]*0;
% pos = [...
%     0,0;...
%     800,0;...
%     0,2000;...
%     800,2000;...
%     1100,0;...
%     2000,0;...
%     1100,2000;...
%     2000,2000];

numSensors = size(pos,1);

phi = phi./180*pi;

% Save absolute values and angle
U_abs = ones(len,numSensors).*U_free;
U_ang = zeros(size(U_abs));
u_change = linspace(90,82,3)';
offset = 2;
for i = 1:4
    U_ang(1:100+i*offset,i)=u_change(1);
    U_ang(101+i*offset:101+length(u_change)-1+i*offset,i)=u_change;
    U_ang(101+length(u_change)-1+i*offset:end,i)=u_change(end);
end
%U_ang = U_ang./180.*pi;
%U_ang = repmat(phi,len,1);
U_ang = phi;
end