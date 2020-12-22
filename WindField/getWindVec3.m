function U = getWindVec3(pos,IR, U_meas_abs, U_meas_ang, n_uf, lims)
%GETWINDVEC3 returns a wind vector related to the desired position
%
% INPUTS
% pos       := [n x 2] vec; points to get velocity for
% IR        := [m x n] Mat; Matrix which takes n measurements and
%                     returns m interpolated values: x2=IR*x1;
% U_meas_abs:= [1 x n] vec; n Measurements of the absolute wind speed
% U_meas_ang:= [1 x n] vec; n Measurements of the wind direction
% n_uf      := [1 x 2] vec; Number of points in x and y direction
% lims      := [2 x 2] mat; [delta x, delta y; (x,y) bottom left]
%
% OUTPUT
% U         := [n x 2] vec; Wind vector at the position
%
%%
% Get the index of the grid matrix the position is matching to
%   Relates to the output of the IR multiplication
i = pos2ind(pos,n_uf,lims);

nx = n_uf(1);
ny = n_uf(2);

U = zeros(size(pos(:,1:2)));

%% Interpolate
% Interpolate absolute value
Abs_interp = reshape(IR*U_meas_abs',[nx,ny]);

% Interpolate angle
%   get angles relative to first one as offset
tmp_ang = mod((U_meas_ang-U_meas_ang(1))+pi/2,pi)-pi/2;
%   Interpolate the differences
Ang_interp = reshape(IR*tmp_ang',[nx,ny]);
%   Add offset again and match to range [0,2pi]
Ang_interp = mod(U_meas_ang(1)+Ang_interp,2*pi);

% Polar coordinates to cartesian coordinatess
U(:,1) = cos(Ang_interp(i)).*Abs_interp(i);
U(:,2) = sin(Ang_interp(i)).*Abs_interp(i);
end

%% getWindVec4
% also includes a shear model for different wind speeds at different
% heights by the Eq.7 from [1]: U = (z/z_h)^alpha * U_measurement
% z_h := hub height, but should be measurement height..?
% Shear coeff.: 0<=alpha, <0.2 unstable atmosphere; >0.2 stable atmosphere

% SOURCES
%   [1] Design and analysis of a spatially heterogeneous wake, Farrell et
%   al.