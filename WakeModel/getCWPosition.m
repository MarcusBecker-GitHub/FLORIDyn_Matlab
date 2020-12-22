function [nw, cw_y, cw_z, core, phi_cw]=getCWPosition(op_dw, w, cl_dstr, op_c, sig_y, sig_z, pc_y, pc_z, x_0)
% GETCWPOSITION 
% ======================================================================= %
% INPUT
%   op_dw       := [nx1] vec; Down wind position in the wake of the OPs
%   w           := [nx1] vec; Width factor for the wake
%   cl_dstr     := [nx2] vec; Relative y,z distribution of the chain in the
%                             wake, factor multiplied with the width, +-0.5
%   op_c        := [nx1] vec; Index which chain the OPs belong to
%   sig_y       := [nx1] vec; Gaussian variance in y direction (sqrt of)
%   sig_z       := [nx1] vec; Gaussian variance in z direction (sqrt of)
%   pc_y        := [nx1] vec; Potential core boundary in y dir
%   pc_z        := [nx1] vec; Potential core boundary in z dir
%   x_0         := [nx1] vec; Potential core length
% ======================================================================= %
% OUTPUT
%   nw          := [nx1] vec; (logical) Part of the near wake (true/false)
%   cw_y        := [nx1] vec; Cross wind position y (wake coord)
%   cw_z        := [nx1] vec; Cross wind position z (wake coord)
%   core        := [nx1] vec; (logical) Part of the pot. core (true/false)
%   phi_cw      := [nx1] vec; Polar coordinates angle of the OP 
% ======================================================================= %
%% Sigma of Gauss functions + Potential core
%   both values are already adapted to near/far field
width_y = w*sig_y + pc_y;
width_z = w*sig_z + pc_z;

%% Get the distribution of the OPs
cw_y = width_y.*cl_dstr(op_c,1);
threeDim = size(cl_dstr,2)-1;

if threeDim
    cw_z= width_z.*cl_dstr(op_c,2);
else
    cw_z = zeros(size(cw_y));
end

% create an radius value of the core and cw values and figure out if the
% OPs are in the core or not
phi_cw  = atan2(cw_z,cw_y);
r_cw    = sqrt(cw_y.^2+cw_z.^2);
core    = or(...
    r_cw < abs(cos(phi_cw)).*pc_y*0.5 + abs(sin(phi_cw)).*pc_z*0.5,...
    op_dw==0);

nw = op_dw<x_0;

end
%% ===================================================================== %%
% = Reviewed: 2020.09.29 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %