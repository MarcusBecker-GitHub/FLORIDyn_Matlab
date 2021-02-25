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

clear narc_height F u_grid_z_tmp wakes
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

% Choose colormap
if isfield(Vis,'Colormap')
    switch Vis.Colormap
        case "jet"
            colormap jet
        case "viridis"
            % blue, green, yellow colormap - often used in python and R
            cmp = viridis(1000);
            colormap(cmp)
        otherwise
            colormap(Vis.Colormap)
    end
end
hold off

%% Write vtk
% In case the field should be stored, save the figure and the generate &
% save the vtk file
if isfield(Vis,'Store')
    if Vis.Store
        savefig('FlowFieldAtHH.fig')
        t=delaunayn([u_grid_x(:),u_grid_y(:)]);
        writeVTK('FlowFieldAtHH',t,[u_grid_x(:),u_grid_y(:)],u_grid_z(:));
    end
end

%% Create Streamwise slice through Field

% Test Settings
% Vis.StreamSlice.end     = [5000,5000];
% Vis.StreamSlice.start   = [0,0];
% Vis.StreamSlize.Height  = 1000;

if isfield(Vis,'StreamSlice')
    % Get vector start to end, angle, resolution and start & end in slice
    % coordinate system
    sliceVec   = Vis.StreamSlice.end - Vis.StreamSlice.start;
    sliceAng   = atan2(sliceVec(2),sliceVec(1));
    sliceRes   = max(size(u_grid_x));
    sliceStart = cos(sliceAng)*Vis.StreamSlice.start(1) +...
        sin(sliceAng)*Vis.StreamSlice.start(2);
    sliceEnd   = cos(sliceAng)*Vis.StreamSlice.end(1) +...
        sin(sliceAng)*Vis.StreamSlice.end(2);
    sliceResH  = round(sliceRes*Vis.StreamSlize.Height/abs(sliceEnd-sliceStart));
    
    % Create meshgrid & empty speed vector
    [SLx,SLz] = meshgrid(linspace(sliceStart,sliceEnd,sliceRes),...
        linspace(0,Vis.StreamSlize.Height,sliceResH));
    SLu     = nan(size(SLx(:)));
    
    % Threshold copied from HH plot
    th = 0.3*mean(T.pos(:,3));
    
    % Find OPs within threshold distance
    within = and(...
        (-sin(sliceAng)*(OP_pos_old(:,1)-Vis.StreamSlice.start(1))+...
        cos(sliceAng)*(OP_pos_old(:,2)-Vis.StreamSlice.start(2))) < th,...
        (-sin(sliceAng)*(OP_pos_old(:,1)-Vis.StreamSlice.start(1))+ ...
        cos(sliceAng)*(OP_pos_old(:,2)-Vis.StreamSlice.start(2))) > -th);
    within = and(within,OP_pos_old(:,3)>0);
    for wakes = 1:length(T.D)
        % Use wake of turbine "wakes" to triangulate
        F = scatteredInterpolant(...
            cos(sliceAng)*OP_pos_old(and(OP.t_id==wakes,within),1) + sin(sliceAng)*OP_pos_old(and(OP.t_id==wakes,within),2),...
            OP_pos_old(and(OP.t_id==wakes,within),3),...
            sqrt(sum(OP.u(and(OP.t_id==wakes,within),:).^2,2)),'nearest','none');
        
        % Get grid values within the wake, outside nan
        SLu_tmp = F(SLx(:),SLz(:));
        
        SLu = min([SLu, SLu_tmp],[],2);
    end
    clear SLu_tmp
    
    % Fill holes
    nan_u = isnan(SLu);
    SLu_tmp2 = getWindVec4([...
        cos(sliceAng)*SLx(nan_u) - sin(sliceAng)*zeros(size(SLx(nan_u))),...
        sin(sliceAng)*SLx(nan_u) + cos(sliceAng)*zeros(size(SLx(nan_u))),...
        SLz(nan_u)],...
        U_abs, U_ang, UF);
    SLu(nan_u) = sqrt(sum(SLu_tmp2.^2,2));
    SLu = reshape(SLu,size(SLx));
    
    % Plot
    figure
    contourf(SLx,SLz,SLu,30,'LineColor','none');
    hold on
    title('Approximated streamwise flow field')
    axis equal
    c = colorbar;
    c.Label.String ='Wind speed [m/s]';
    if isfield(Vis,'CRange')
        c.Limits = Vis.CRange;
        caxis(Vis.CRange);
    end
    xlabel('Distance [m]')
    ylabel('Height [m]')
    
    % Choose colormap
    if isfield(Vis,'Colormap')
        switch Vis.Colormap
            case "jet"
                colormap jet
            case "viridis"
                % blue, green, yellow colormap - often used in python and R
                cmp = viridis(1000);
                colormap(cmp)
            otherwise
                colormap(Vis.Colormap)
        end
    end
    hold off
    % vtk & fig
    % In case the field should be stored, save the figure and the generate &
    % save the vtk file
    if isfield(Vis,'Store')
        if Vis.Store
            savefig('FlowFieldStreamwise.fig')
            t=delaunayn([SLx(:),SLz(:)]);
            writeVTK('FlowFieldStreamwise',t,[SLx(:),SLz(:)],SLu(:));
        end
    end
end
%% ===================================================================== %%
% = Reviewed: 2021.02.24 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker@tudelft.nl                                  = %
% ======================================================================= %