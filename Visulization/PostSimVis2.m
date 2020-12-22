f = figure;
hold on;

narc_height = true(size(OP.t_id));
u_grid_z = NaN(size(u_grid_x(:)));
if size(OP_pos_old,2)==3
    narc_height = OP_pos_old(:,3)<mean(T.pos(:,3))*1.2;
    narc_height = and(OP_pos_old(:,3)>mean(T.pos(:,3))*0.8,narc_height);
end

[u_grid_x,u_grid_y] = meshgrid(linspace(5,2995,301),linspace(1.25,995,301));

for wakes = 1:length(T.D)
    F = scatteredInterpolant(...
        OP_pos_old(and(OP.t_id==wakes,narc_height),1),...
        OP_pos_old(and(OP.t_id==wakes,narc_height),3),...
    sqrt(sum(OP.u(and(OP.t_id==wakes,narc_height),:).^2,2)),'nearest','none');

    % Get grid values within the wake, outside nan
    u_grid_z_tmp = F(u_grid_x(:),u_grid_y(:));
    u_grid_z = min([u_grid_z, u_grid_z_tmp],[],2);

end

%% Fill up the values outside of the wakes with free windspeed measurements
nan_z = isnan(u_grid_z);

u_grid_z_tmp = getWindVec4(...
    [u_grid_x(nan_z),u_grid_y(nan_z),ones(size(u_grid_x(nan_z)))*119],...
    U_abs, U_ang, UF);

u_grid_z(nan_z) = sqrt(sum(u_grid_z_tmp.^2,2));
u_grid_z=reshape(u_grid_z,size(u_grid_x));

%%
u_grid_z = getWindVec4(...
    [u_grid_x(:),u_grid_y(:),ones(size(u_grid_x(:)))*119],...
    U_abs, U_ang, UF);

surf(u_grid_x,u_grid_y,zeros(size(u_grid_x)),...
    reshape(sqrt(sum(u_grid_z.^2,2)),size(u_grid_x)),'EdgeColor','none');

for i_T = 1:length(T.D)
    % Get start and end of the turbine rotor
    rot_pos = ...
        [cos(T.yaw(i_T)), -sin(T.yaw(i_T));...
        sin(T.yaw(i_T)), cos(T.yaw(i_T))] * ...
        [0,0;T.D(i_T)/2,-T.D(i_T)/2];
    rot_pos = rot_pos + repmat(T.pos(i_T,1:2)',1,size(rot_pos,2)); 
    plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',3);
end

title('Field plot')
axis equal
xlabel('West-East [m]')
ylabel('South-North [m]')
xlim(fLim_x)
ylim(fLim_y)
c = colorbar;
c.Label.String ='Windspeed [m/s]';
hold off
%%
% ==== Prep for export ==== %
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width

% Set font & size
set(f.Children, ...
    'FontName',     'Arial', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';