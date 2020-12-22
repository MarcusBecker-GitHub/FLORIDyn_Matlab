function U = getWindVec(pos,timeStep,U_sig)
% GETWINDVEC returns a free wind vector (== speed and direction) for the
% position(s) given as a [x,y] vector
%
% INPUT
% pos   := [n x 3] Vector with postions [x,y,z]// World coordinates
% pos   := [n x 2] Vector with postions [x,y]  // World coordinates
% timeStep := int Index of the current entry in U_sig
% U_sig := [n x 2] Vector which lasts the entire simulation and provides a
%                   wind vector
%
% OUTPUT
% U  	:= [n x 2] vector with the [Ux, Uy] velocities

% ========================= TODO ========================= 
% ///////////////////////// LINK Wind Dir  //////////

persistent F
%windspeed = @(x) [x(1) 0;0 x(2)]*x;
%U = windspeed(pos');

% off = [0,-10,-15,-30];
% x = [0, 1000, 0, 1000];
% y = [0, 0, 2000, 2000];

off = [0,0,0];
x = [0, 1000, 0];
y = [0, 2000,2000];
R =@(p) [cos(p), -sin(p);sin(p),cos(p)];


k = off+timeStep;
k(k<2) = 2;         % Starts at 2 because the old value is used as well

U_meas = PT1(k,U_sig);

% if k>0
%     U_meas = U_meas.*(0.5*cos(k(1)/(2*pi)*2)+0.8);
% end

if isempty(F)
    F = scatteredInterpolant(x',y',U_meas(:,1),'linear','linear');
    % 'nearest'
else
    F.Values = U_meas(:,1);
end

U = zeros(size(pos,1),2);
U(:,1) = F(pos(:,1:2));

% Change values and interpolate for the same positions
F.Values = U_meas(:,2);
U(:,2) = F(pos(:,1:2));

end

function U = PT1(timeStep,U_sig)
persistent U_old
if isempty(U_old)
    U_old = zeros(size(U_sig(timeStep,:)));
end
deltaT  = 1;     % Hard coded fix
T       = 1;
K       = 1;

U = 1/(T/deltaT + 1)*(K*U_sig(timeStep,:) + T/deltaT*U_old);
U_old = U;
end