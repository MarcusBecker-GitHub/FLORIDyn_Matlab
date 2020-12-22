function [sig_y, sig_z, C_T, x_0, delta, pc_y, pc_z] = getBastankhahVars3(OP, D)
% GETBASTANKHAHVARS calculates the field width, the potential core data and
% the deflection. These values are needed for the wake shape and speed 
% reduction. The values are based of the state of every individual OP.
% ======================================================================= %
% INPUT
%   OP          := Struct;    Data related to the state of the OPs
%    .pos       := [nx3] vec; [x,y,z] world coord. (can be nx2)
%    .dw        := [nx1] vec; downwind position (wake coordinates)
%    .yaw       := [nx1] vec; yaw angle (wake coord.) at the time of creat.
%    .Ct        := [nx1] vec; Ct coefficient at the time of creation
%    .t_id      := [nx1] vec; Turbine OP belongs to
%    .U         := [nx2] vec; Uninfluenced wind vector at OP position
%    .u         := [nx2] vec; Effective wind vector at OP position
%
%   D           := [nx1] vec; Turbine diameter.
% ======================================================================= %
% OUTPUT
%   sig_y       := [nx1] vec; Gaussian variance in y direction (sqrt of)
%   sig_z       := [nx1] vec; Gaussian variance in z direction (sqrt of)
%   C_T         := [nx1] vec; Thrust coefficient, same as OP.Ct
%   x_0         := [nx1] vec; Potential core length
%   delta       := [nx1] vec; Deflection
%   pc_y        := [nx1] vec; Potential core boundary in y dir
%   pc_z        := [nx1] vec; Potential core boundary in z dir
% ======================================================================= %
% SOURCES
% [1] Experimental and theoretical study of wind turbine wakes in yawed
%     conditions - M. Bastankhah and F. Porté-Agel
% [2] Design and analysis of a spatially heterogeneous wake - A. Farrell,
%     J. King et al.
% ======================================================================= %
%% Calc C_T
%a = OP.ayaw(:,1);
yaw = OP.yaw;
C_T = OP.Ct;
OP_I = sqrt(OP.I_f.^2+OP.I_0.^2);
%% Calc x_0 (Core length)
alpha = 2.32;
beta = 0.154;
% [1] Eq. 7.3
x_0 = (cos(yaw).*(1+sqrt(1-C_T))./...
    (sqrt(2)*(alpha*OP_I+beta*(1-sqrt(1-C_T))))).*D;

%% Calc k_z and k_y based on I
k_a = 0.38371;
k_b = 0.003678;

%[2] Eq.8
k_y = k_a*OP_I + k_b;
k_z = k_y;

%% Get field width y
% [1] Eq. 7.2
% To fit the field width, the value linearly increases from 0 to max for dw
% positions before x_0
zs = zeros(size(OP.dw));
sig_y = ...
    max([OP.dw-x_0,zs],[],2)   .* k_y +...
    min([OP.dw./x_0,zs+1],[],2).* cos(yaw) .* D/sqrt(8);

%% Get field width z
% [1] Eq. 7.2
sig_z = ...
    max([OP.dw-x_0,zs],[],2)    .* k_z +...
    min([OP.dw./x_0,zs+1],[],2) .* D/sqrt(8);

%% Calc Theta
%[1] Eq. 6.12
Theta = 0.3*yaw./cos(yaw).*(1-sqrt(1-C_T.*cos(yaw)));

%% Calc Delta / Deflection
%[1] Eq. 7.4 (multiplied with D and the second part disabled for dw<x_0)
%   Part 1 covering the linear near field and constant for the far field
delta_nfw  = Theta.*min([OP.dw,x_0],[],2);

%   Part 2, smooth angle for the far field, disabled for the near field.
delta_fw_1 = Theta/14.7.*sqrt(cos(yaw)./(k_y.*k_z.*C_T)).*(2.9+1.3*sqrt(1-C_T)-C_T);
delta_fw_2 = log(...
    (1.6+sqrt(C_T)).*...
    (1.6.*sqrt((8*sig_y.*sig_z)./(D.^2.*cos(yaw)))-sqrt(C_T))./(...
    (1.6-sqrt(C_T)).*...
    (1.6.*sqrt((8*sig_y.*sig_z)./(D.^2.*cos(yaw)))+sqrt(C_T))...
    ));

% Combine deflection parts
delta = delta_nfw + ...
    (sign(OP.dw-x_0)/2+0.5).*...
    delta_fw_1.*delta_fw_2.*D;

%% Potential core
% Potential core at rotor plane
%   Ratio u_r/u_0 [1] Eq.6.4 & 6.7
u_r_0 = (C_T.*cos(yaw))./(...
    2*(1-sqrt(1-C_T.*cos(yaw))).*sqrt(1-C_T));

%   Ellypitcal boundaries [1] P.530, L.7f
pc_y = D.*cos(yaw).*sqrt(u_r_0).*max([1-OP.dw./x_0,zs],[],2);
pc_z = D.*sqrt(u_r_0).*max([1-OP.dw./x_0,zs],[],2);

%   For OPs at the rotor plane (rp) fit to rotor plane rater than PC to get
%   effective wind speed right
rp  = OP.dw==0;
pc_y(rp) = D(rp).*cos(yaw(rp));
pc_z(rp) = D(rp);
end
%% ===================================================================== %%
% = Reviewed: 2020.11.23 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %