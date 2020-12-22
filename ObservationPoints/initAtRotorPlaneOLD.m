function [op_pos, op_dw, op_ayaw] = initAtRotorPlaneOLD(op_pos, op_dw, op_ayaw, op_t_id, chainList, cl_dstr, tl_pos, tl_D, tl_ayaw, tl_U)
%INITATROTORPLANE creates points at the rotor plane and initializes them
%   At the pointer entry, insert the new OPs at the rotor plane of the
%   turbines and set their position, downwind and r values.
% INPUT
% OP Data
%   op_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   op_dw       := [n x 1] vec; downwind position
%   op_ayaw     := [n x 2] vec; axial induction factor and yaw (wake coord.)
%   op_t_id     := [n x 1] vec; Turbine op belongs to
%
% Chain Data
%   chainList   := [n x 1] vec; (see at the end of the function)
%   cl_dstr     := [n x 1] vec; Distribution relative to the wake width
%
% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)
%
% wf            := float >0;    width factor, multiplied with the
%                               wake width.
%
% OUTPUT
% OP Data
%   op_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   op_dw       := [n x 1] vec; downwind position
%   op_ayaw     := [n x 2] vec; axial induction factor and yaw (wake coord.)


%%

Dim = size(op_pos,2);    %<- Switch between dimentions

% Get the number of chains, assumed to be constant
%numChains = sum(chainList(:,4)==1);
%numTurbines   = size(tl_pos,1);

% Get indeces of the starting observation points
ind = chainList(:,1) + chainList(:,2);

% Assign a and yaw values of the turbines, together with coordinates
op_ayaw(ind,1) = tl_ayaw(op_t_id(ind),1);   % a
op_ayaw(ind,2) = getEffectiveYaw(...
    tl_ayaw(op_t_id(ind),2), tl_U(op_t_id(ind),:));

% Set downwind position to 0 (at the rotor plane)
op_dw(ind) = 0;

%%
% Spread points across the rotor plane at wind angle, NOT yaw angle
% -> plane is always perpenducular to the wind dir, yaw is only
% used for the model
ang_U = atan2(tl_U(:,2),tl_U(:,1));

a   = op_ayaw(ind,1);
yaw = op_ayaw(ind,2);
C_T = 4*a.*(1-a.*cos(yaw));
% Potential core at rotor plane
%   Ratio u_r/u_0 [1] Eq.6.4 & 6.7
u_r_0 = (C_T.*cos(yaw))./(...
    2*(1-sqrt(1-C_T.*cos(yaw))).*sqrt(1-C_T));

% x_w = Potential_core_y*(-sin(phi))*distribution_cw_y*wf + t_x_w
op_pos(ind,1) = ...
    -tl_D(op_t_id(ind)).*cos(yaw).*sqrt(u_r_0)...
    .*sin(ang_U(op_t_id(ind))).*cl_dstr(:,1) +...
    tl_pos(op_t_id(ind),1);

% y_w = Potential_core_y*(cos(phi))*distribution_cw_y*wf + t_x_w
op_pos(ind,2) = ...
    tl_D(op_t_id(ind)).*cos(yaw).*sqrt(u_r_0)...
    .*cos(ang_U(op_t_id(ind))).*cl_dstr(:,1) +...
    tl_pos(op_t_id(ind),2);

if Dim == 3
    % z_w = D*distribution_cw_z*wf + t_z
    op_pos(ind,3) = tl_D(op_t_id(ind)).*sqrt(u_r_0)...
        .*cl_dstr(:,2) +...
        tl_pos(op_t_id(ind),3);
end

end

