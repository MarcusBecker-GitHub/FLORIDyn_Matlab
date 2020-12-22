function [IR, n_uf] = createIRMatrix(meas_xy,goal_xy,interpMethod,extrapMethod)
%createIRMatrix creates a static matrix relation between values and
%interpolated values
%
% INPUT
% meas_xy       := [n x 2] vec; Location of the measurements
% goal_xy       := [m x 2] vec; Location of the interpolated data
% interpMethod  := string     ; String describing the interpolation method
% extrapMethod  := string     ; String describing the extrapolation method
%
% OUTPUT
% IR            := [m x n] Mat; Matrix which takes n measurements and
%                               returns m interpolated values: x2=IR*x1;
switch nargin
    case 2
        interpMethod = 'linear';
        extrapMethod = 'linear';
    case 3
        extrapMethod = 'linear';
end

n = size(meas_xy,1);
m = size(goal_xy,1);
IR = zeros(m,n);

v = zeros(n,1);
v(1) = 1;

F = scatteredInterpolant(meas_xy(:,1),meas_xy(:,2),v,...
    interpMethod,extrapMethod);
IR(:,1) = F(goal_xy);

for i = 2:n
    v(i-1:i) = [0;1];
    F.Values = v;
    IR(:,i) = F(goal_xy);
end
end
%% TODOs
% - Test if extrapolation is sufficient
% - potentially replace by neq algorithm
%% ===================================================================== %%
% = Reviewed: 2020.10.06 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %