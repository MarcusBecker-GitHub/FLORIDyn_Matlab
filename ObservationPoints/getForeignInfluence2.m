function r_f = getForeignInfluence2(op_pos, op_r, op_t_id, startOPs, numT)
% GETFOREIGNINFLUENCE2 interpolates the influence of other wakes on the OP
%   The current solution is to use the entire wake as a 2D function and
%   do a nearest neighbour interpolation for the OPs at the rotor plane.
%   This function is a big bottleneck of the simulation.
% ======================================================================= %
% INPUT
%   op_pos      := [nx3] vec; World coordinates of the Observation Points
%   op_r        := [nx1] vec; Reduction factor of the OP
%   op_t_id     := [nx1] vec; Turbine the OPs belong to
%   startOPs    := [mx1] vec; Indeces of rotor plane OPs
%   numT        := int;       Number of turbines
% ======================================================================= %
% OUTPUT
%   r_f         := [nx1] vec; combined foreign influence
% /////////////////////////// EXCEPTION! //////////////////////////////// %
% => u = r_f*U and NOT u=(1-r_f)*U as expected. This is due to the factors
% being multiplied.
% ======================================================================= %
%%
% Go through all turbines and use their points in scattered interpolant
r_f = ones(size(op_r)); % == prod((1-r)(1-r)...)

% 1 if three dimentions, 0 if only 2
threeDim = mod(size(op_pos,2),2);

for t = 1:numT
    % extract points which belong to the turbine and which are potentially
    % influenced
    t_points = op_t_id == t;
    t_rpOPs  = op_t_id(startOPs) == t;
    
    if threeDim == 1
        F = scatteredInterpolant(...
            op_pos(t_points,1),...
            op_pos(t_points,2),...
            op_pos(t_points,3),...
            op_r(t_points),'nearest','none');
    
        r_f_tmp = F(op_pos(startOPs(~t_rpOPs),1:3));
    else
        error('2D not supported by reduced interaction')
%         F = scatteredInterpolant(...
%             op_pos(t_points,1),...
%             op_pos(t_points,2),...
%             op_r(t_points),'nearest','none');
%     
%         r_f_tmp = F(op_pos(~t_points,1:2));
    end
    
    if isempty(r_f_tmp)
        continue;
    end
    r_f_tmp(isnan(r_f_tmp)) = 0;
    r_f(startOPs(~t_rpOPs)) = r_f(startOPs(~t_rpOPs)).*(1-r_f_tmp);
end
end
%% ===================================================================== %%
% = Reviewed: 2020.09.29 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %