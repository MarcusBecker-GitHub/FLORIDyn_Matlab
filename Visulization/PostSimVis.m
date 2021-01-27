%% Post-Sim Visulization
%   Contour Plot of the wind field
%% Interpolate the values of the grid in the wakes
try
    u_grid_z = NaN(size(u_grid_x(:)));
catch
    % Intialize needed variables
    OnlineVis_Start;
    u_grid_z = NaN(size(u_grid_x(:)));
    %OP_pos_old = OP.pos;
end
narc_height = true(size(OP.t_id));

if size(OP_pos_old,2)==3
    narc_height = OP_pos_old(:,3)<mean(T.pos(:,3))*1.3;
    narc_height = and(OP_pos_old(:,3)>mean(T.pos(:,3))*0.7,narc_height);
end
%narc_height = true(size(OP.t_id));
for wakes = 1:length(T.D)
    % Use wake of turbine "wakes" to triangulate
    F = scatteredInterpolant(...
        OP_pos_old(and(OP.t_id==wakes,narc_height),1),...
        OP_pos_old(and(OP.t_id==wakes,narc_height),2),...
    sqrt(sum(OP.u(and(OP.t_id==wakes,narc_height),:).^2,2)),'nearest','none');

    % Get grid values within the wake, outside nan
    u_grid_z_tmp = F(u_grid_x(:),u_grid_y(:));
    
    u_grid_z = min([u_grid_z, u_grid_z_tmp],[],2);
end

%% Fill up the values outside of the wakes with free windspeed measurements
nan_z = isnan(u_grid_z);
u_grid_z_tmp2 = getWindVec3(...
    [u_grid_x(nan_z),u_grid_y(nan_z)],...
    UF.IR, U_abs, U_ang, UF.Res, UF.lims);
u_grid_z(nan_z) = sqrt(sum(u_grid_z_tmp2.^2,2));
u_grid_z = reshape(u_grid_z,size(u_grid_x));

%% Plot contour
figure
contourf(u_grid_x,u_grid_y,u_grid_z,30,'LineColor','none');
hold on
for i_T = 1:length(T.D)
    % Get start and end of the turbine rotor
    rot_pos = ...
        [cos(T.yaw(i_T)), -sin(T.yaw(i_T));...
        sin(T.yaw(i_T)), cos(T.yaw(i_T))] * ...
        [0,0;T.D(i_T)/2,-T.D(i_T)/2];
    rot_pos = rot_pos + T.pos(i_T,1:2)';
    plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',3);
end
title('Approximated flow field at hub height')
axis equal
c = colorbar;
c.Label.String ='Wind speed [m/s]';
if isfield(Vis,'CRange')
    c.Limits = Vis.CRange;
    caxis(Vis.CRange);
end
xlabel('West-East [m]')
ylabel('South-North [m]')
colormap jet
hold off

%% ===================================================================== %%
% = Reviewed: 2020.12.23 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker@tudelft.nl                                  = %
% ======================================================================= %