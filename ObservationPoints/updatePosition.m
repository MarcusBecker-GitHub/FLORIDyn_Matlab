function op_pos = updatePosition(op_pos, op_U, cw_y, cw_z, cw_y_old, cw_z_old, delta, delta_old)
%UPDATEPOSITION transforms the down wind step of the OPs from the wake
% coordinates to the world coordinates
% ======================================================================= %
% INPUT
%(_old refers to variables before the down wind step)
%   op_pos      := [nx3] vec; OP world coordinate position
%   op_U        := [nx2] vec; Wind vector at the position of the OPs
%   cw_y        := [nx1] vec; Cross wind position y (wake coord)
%   cw_z        := [nx1] vec; Cross wind position z (wake coord)
%   cw_y_old    := [nx1] vec; Cross wind position y (wake coord)
%   cw_z_old    := [nx1] vec; Cross wind position z (wake coord)
%   delta       := [nx1] vec; Deflection
%   delta_old   := [nx1] vec; Deflection 
% ======================================================================= %
% OUTPUT
%   op_pos      := [nx3] vec; Updated OP world coordinate position
% ======================================================================= %
%%
% Get wind angle 
ang = atan2(op_U(:,2),op_U(:,1));

% Now also add the deflection offset
diff_cw_y = cw_y + delta - cw_y_old - delta_old;

% Apply y-crosswind step relative to the wind angle
op_pos(:,1) = op_pos(:,1) - sin(ang).*diff_cw_y;
op_pos(:,2) = op_pos(:,2) + cos(ang).*diff_cw_y;

if mod(size(op_pos,2),2)
    diff_cw_z = cw_z - cw_z_old;
    % OPs which would move into the ground are now kept above ground.
    aboveGround = op_pos(:,3) + diff_cw_z>0;
    op_pos(aboveGround,3) = op_pos(aboveGround,3) + diff_cw_z(aboveGround);
    op_pos(~aboveGround,3) = 0;
end
%% ===================================================================== %%
% = Reviewed: 2020.10.07 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %