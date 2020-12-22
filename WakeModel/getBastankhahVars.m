function [sig_y, sig_z, C_T, Theta, k_y, k_z, x_0] = getBastankhahVars(op_dw, op_ayaw, op_I, op_D)
% getCW returns the crosswind position of an OP based on the dw position
%
%INPUT
% OP Data
%   op_dw       := [n x 1] vec; downwind position
%   op_ayaw     := [n x 2] vec; axial induction factor and yaw (wake coord.)
%   op_t_id     := [n x 1] vec; Turbine op belongs to
%   op_I        := [n x 1] vec; Ambient turbulence intensity
%
% Turbine Data
%   tl_D        := [n x 1] vec; Turbine diameter
%
% SOURCES
% [1] Experimental and theoretical study of wind turbine wakes in yawed
%     conditions - M. Bastankhah and F. Porté-Agel
% [2] Design and analysis of a spatially heterogeneous wake - A. Farrell,
%     J. King et al.

%% Calc C_T
a = op_ayaw(:,1);
yaw = op_ayaw(:,2);

% Could be replaced by look-up-table
% [1] Eq.6.1 
%C_T = 4*a.*sqrt(1-a.*(2*cos(yaw)-a));
% [1] Eq.6.2
C_T = 4*a.*(1-a.*cos(yaw));
%% Calc x_0 (Core length)
alpha = 2.32;
beta = 0.154;
% [1] Eq. 7.3
x_0 = (cos(yaw).*(1+sqrt(1-C_T))./...
    (sqrt(2)*(alpha*op_I+beta*(1-sqrt(1-C_T))))).*op_D;

%% Calc k_z and k_y based on I (I=0 under ideal conditions)
k_a = 0.38371;
k_b = 0.003678;

%[2] Eq.8
k_y = k_a*op_I + k_b;
k_z = k_y;

%% Get field width y
% [1] Eq. 7.2
sig_y = k_y.*(op_dw-x_0)+cos(yaw).*op_D/sqrt(8);

%% Get field width z
% [1] Eq. 7.2
sig_z = k_z.*(op_dw-x_0)+op_D/sqrt(8);

%% Calc Theta
%[1] Eq. 6.12
Theta = 0.3*yaw./cos(yaw).*(1-sqrt(1-C_T.*cos(yaw)));
end