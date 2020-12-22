function U = getWindVec4(pos, U_meas_abs, U_meas_ang, UF)
%GETWINDVEC3 returns a wind vector related to the desired position
% ======================================================================= %
% INPUTS
%   pos         := [nx3] vec; points to get velocity for
%
%   U_meas_abs  := [1xn] vec; n Measurements of the absolute wind speed
%   U_meas_ang  := [1xn] vec; n Measurements of the wind direction
%
%   UF          := Struct;    Data connected to the (wind) field
%    .lims      := [2x2] mat; Interpolation area
%    .IR        := [mxn] mat; Maps the n measurements to the m grid points
%                             of the interpolated mesh
%    .Res       := [1x2] mat; x and y resolution of the interpolation mesh
%    .pos       := [nx2] mat; Measurement positions
%    .airDen    := double;    AirDensity
%    .alpha_z   := double;    Atmospheric stability (see above)
%    .z_h       := double;    Height of the measurement
% ======================================================================= %
% OUTPUT
%   U           := [nx2] vec; Wind vector at the position
% ======================================================================= %
%% Constants
n_uf    = UF.Res;
lims    = UF.lims;
alpha_z = UF.alpha_z;
z_h     = UF.z_h;
IR      = UF.IR;
%%
% Get the index of the grid matrix the position is matching to
%   Relates to the output of the IR multiplication
i = pos2ind(pos,n_uf,lims);

% Speed reduction due to height
h_red = (pos(:,3)/z_h).^alpha_z; % [1]

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
U(:,1) = cos(Ang_interp(i)).*Abs_interp(i).*h_red;
U(:,2) = sin(Ang_interp(i)).*Abs_interp(i).*h_red;
end
% SOURCES
%   [1] Design and analysis of a spatially heterogeneous wake, Farrell et
%   al.
%% ===================================================================== %%
% = Reviewed: 2020.09.28 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %