function yaw_t = getEffectiveYaw(t_orientation, U)
% GETEFFECTIVEYAW returns the effective yaw angle between the wind
% direction and the turbine orientation.
%
% INPUT
% t_orientation := [n x 1] Angle of the turbine in world coordinates
%                   looking WITH the wind (backwards)
% U             := [n x 2] Wind vector [ux,uy] at the location of the
%                           turbine in world coordinates
%
% OUTPUT
% yaw_t         := [n x 1] vector with the effective yaw angles [-pi,+pi]

% ========================= TODO ========================= 
% Vec to angle
%
% get effective angle
ang_wind = atan2(U(:,2),U(:,1));
yaw_t = mod((ang_wind-t_orientation) + pi/2,pi)-pi/2;
% Eq. based on
% https://stackoverflow.com/questions/1878907/the-smallest-difference-between-2-angles
end