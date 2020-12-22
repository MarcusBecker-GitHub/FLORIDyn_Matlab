function op_pos = applyStep(op_pos, op_U, delta_dw, delta_cw)
% APPLYSTEP adds the movement in the wake coordinate system to the real
% world position
%
% INPUT
% op_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
% op_U        := [n x 2] vec; Uninfluenced wind vector at OP position
% delta_dw    := [n x 1] vec; Step into the downwind direction
% delta_cw    := [n x 2] vec; Step into crosswind direction (can be nx1)
%
% OUTPUT
% op_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)

ang = atan2(op_U(:,2),op_U(:,1));
op_pos(:,1) = op_pos(:,1) - sin(ang).*delta_cw(:,1) + delta_dw(:,1);
op_pos(:,2) = op_pos(:,2) + cos(ang).*delta_cw(:,1) + delta_dw(:,2);
if Dim == 3
    op_pos(:,3) = op_pos(:,3) + delta_cw(:,2);
end
end