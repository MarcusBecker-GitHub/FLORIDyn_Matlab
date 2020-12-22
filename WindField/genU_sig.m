function [U_x,U_y,pos] = genU_sig(len)
% GENU_SIG creates a vector with wind speed measurements at different
% locations in the field.
%
% INPUT
% len   := int; Number of time steps
%
% OUTPUT
% U_x   := [n x m] vec; n Measurements at m places of the x wind velocity 
% U_y   := [n x m] vec; n Measurements at m places of the y wind velocity 
% pos   := [m x 2] vec; m (x,y) positions of the measurements
%
% =========================== Potential Issue =========================== %
% Since the interpolation happens across the given values (U_x, U_y) they
% are treated seperately, which can result in an unwanted decrease of the
% magnitude. Alternatively, magnitude and phase can be used for
% interpolation to overcome the issue. Then the code needs to be modified
% to be able to interpolate between 350° and 10° over the short route
% instead of the long one.
% ======================================================================= %

U_free = 13;
% In Deg
phi = [110,105,85,105];
pos = [...
    -100,100;...
    1000,100;...
    -100,2000;...
    1000,2000];

numSensors = size(pos,1);



phi = phi./180*pi;
U_x = ones(len,numSensors).*U_free;
U_y = zeros(len,numSensors);

R =@(p) [cos(p), -sin(p);sin(p),cos(p)];

for i = 1:numSensors
    tmpU = R(phi(i))*[U_x(:,i),U_y(:,i)]';
    U_x(:,i) = tmpU(1,:)';
    U_y(:,i) = tmpU(2,:)';
end
end

