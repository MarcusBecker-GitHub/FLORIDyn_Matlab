function OP = initAtRotorPlane(OP, chain, T)
%INITATROTORPLANE creates points at the rotor plane and initializes them
%   At the chain list pointer entry, inserts the new OPs at the rotor plane 
%   of the turbines and sets or resets their states.
% ======================================================================= %
% INPUT
%   OP          := Struct;    Data related to the state of the OPs
%    .pos       := [nx3] vec; [x,y,z] world coord. (can be nx2)
%    .dw        := [nx1] vec; downwind position (wake coordinates)
%    .r         := [nx1] vec; Reduction factor: u = U*(1-r)
%    .yaw       := [nx1] vec; yaw angle (wake coord.) at the time of creat.
%    .Ct        := [nx1] vec; Ct coefficient at the time of creation
%    .t_id      := [nx1] vec; Turbine OP belongs to
%    .U         := [nx2] vec; Uninfluenced wind vector at OP position
%
%   chain       := Struct;    Data related to the OP management / chains
%    .NumChains := int;       Number of Chains per turbine
%    .Length    := int/[nx1]; Length of the Chains - either uniform for all
%                             chains or individually set for every chain.
%    .List      := [nx5] vec; [Offset, start_id, length, t_id, relArea]
%    .dstr      := [nx2] vec; Relative y,z distribution of the chain in the
%                             wake, factor multiplied with the width, +-0.5
%
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines
%    .Ct        := [nx1] vec; Current Ct of the n turbines
%    .Cp        := [nx1] vec; Current Cp of the n turbines
%    .U         := [nx2] vec; Wind vector for the n turbines
%    .u         := [nx1] vec; Effective wind speed at the rotor plane
% ======================================================================= %
% OUTPUT
%   OP          := Struct;    Data related to the state of the OPs
%    .pos       := [nx3] vec; [x,y,z] world coord. (can be nx2)
%    .dw        := [nx1] vec; downwind position (wake coordinates)
%    .r         := [nx1] vec; Reduction factor: u = U*(1-r)
%    .yaw       := [nx1] vec; yaw angle (wake coord.) at the time of creat.
%    .Ct        := [nx1] vec; Ct coefficient at the time of creation
%    .t_id      := [nx1] vec; Turbine OP belongs to
%    .U         := [nx2] vec; Uninfluenced wind vector at OP position
% ======================================================================= %
%%
% Code used to be built to support 2 dimentions as well as 3
Dim = 3;

% Get indeces of the starting observation points
ind = chain.List(:,1) + chain.List(:,2);

% Assign a and yaw values of the turbines, together with coordinates
OP.Ct(ind) = T.Ct(OP.t_id(ind),1);   % a
OP.yaw(ind) = getEffectiveYaw(...
    T.yaw(OP.t_id(ind)), T.U(OP.t_id(ind),:));
OP.I_f(ind) = T.I_f(OP.t_id(ind));  % Foreign added turbulence (I^+)

% Set downwind position to 0 (at the rotor plane)
OP.dw(ind) = 0;

%%
% Spread points across the rotor plane at wind angle, NOT yaw angle
% -> plane is always perpenducular to the wind dir, yaw is only
% used for the model
ang_U = atan2(T.U(:,2),T.U(:,1));

yaw = OP.yaw(ind);
C_T = OP.Ct(ind);
% Potential core at rotor plane
%   Ratio u_r/u_0 [1] Eq.6.4 & 6.7
% u_r_0 = (C_T.*cos(yaw))./(...
%     2*(1-sqrt(1-C_T.*cos(yaw))).*sqrt(1-C_T));
% Disabeled to spawn OPs at the rotor area
u_r_0 = 1;

% x_w = Potential_core_y*(-sin(phi))*distribution_cw_y*wf + t_x_w
OP.pos(ind,1) = ...
    -T.D(OP.t_id(ind)).*cos(yaw).*sqrt(u_r_0)...
    .*sin(ang_U(OP.t_id(ind))).*chain.dstr(:,1) +...
    T.pos(OP.t_id(ind),1);

% y_w = Potential_core_y*(cos(phi))*distribution_cw_y*wf + t_x_w
OP.pos(ind,2) = ...
    T.D(OP.t_id(ind)).*cos(yaw).*sqrt(u_r_0)...
    .*cos(ang_U(OP.t_id(ind))).*chain.dstr(:,1) +...
    T.pos(OP.t_id(ind),2);

if Dim == 3
    % z_w = D*distribution_cw_z*wf + t_z
    OP.pos(ind,3) = T.D(OP.t_id(ind)).*sqrt(u_r_0)...
        .*chain.dstr(:,2) +...
        T.pos(OP.t_id(ind),3);
end

end
%% ===================================================================== %%
% = Reviewed: 2020.09.29 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %
