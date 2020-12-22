%% Online flow field incl SOWFA flow field
% Creates a figure with three subplots with (1) the FLORIDyn flow field,
% (2) the SOWFA flow field and (3) the Relative Error between the fields.
%% Flow field SOWFA 
path = '/Users/marcusbecker/Qsync/Masterthesis/Data/ThreeTurbineDataDaan/3TurbineDynamicCt/sliceDataInstantaneous/2';
%path = '/Users/marcusbecker/Qsync/Masterthesis/Data/ThreeTurbineDataDaan/3TurbineDynamicCt/sliceDataInstantaneous/2';
%file = '/U_slice_streamwise.vtk';
file = '/U_slice_horizontal.vtk';
fileTime = max(round(Sim.TimeSteps(k)),2);
fileNr = pad(num2str(fileTime),4,'left','0');

if exist([path fileNr file],'file')==2
    [~,cellCenters,cellData] = importVTK([path fileNr file]);
    UmeanAbsScattered = sqrt(sum(cellData.^2,2));
    
    % Horizontal slice trough the wake field (xy plane)
    % Create 2D interpolant
    interpolant = ...
        scatteredInterpolant(cellCenters(:,[1,2]),UmeanAbsScattered); % [1,3]),UmeanAbsScattered);
    
    % x axis plot = x axis field
    Xaxis = linspace(...
        min(cellCenters(:,1),[],1),...
        max(cellCenters(:,1),[],1),301);
    
    % y axis plot = y axis field
    Yaxis = linspace(...
        min(cellCenters(:,2),[],1),...      % (:,2),[],1),...
        max(cellCenters(:,2),[],1),301);    % (:,2),[],1),300);
    
    % Create meshgrid for interpolation
    [Xm,Ym] = meshgrid(Xaxis,Yaxis);
    U_SOWFA = interpolant(Xm,Ym);
end

%% Flow field FLORIDyn

narc_height = true(size(OP.t_id));

if size(OP_pos_old,2)==3
    narc_height = OP_pos_old(:,3)<mean(T.pos(:,3))*1.2;
    narc_height = and(OP_pos_old(:,3)>mean(T.pos(:,3))*0.8,narc_height);
end

[u_grid_x,u_grid_y] = meshgrid(Xaxis,Yaxis);
u_grid_z = NaN(size(u_grid_x(:)));

for wakes = 1:length(T.D)
    F = scatteredInterpolant(...
        OP_pos_old(and(OP.t_id==wakes,narc_height),1),...
        OP_pos_old(and(OP.t_id==wakes,narc_height),2),...   % 3
    sqrt(sum(OP.u(and(OP.t_id==wakes,narc_height),:).^2,2)),'nearest','none');

    % Get grid values within the wake, outside nan
    u_grid_z_tmp = F(u_grid_x(:),u_grid_y(:));
    
    u_grid_z = min([u_grid_z, u_grid_z_tmp],[],2);
end

% Fill up the values outside of the wakes with free windspeed measurements
nan_z = isnan(u_grid_z);

u_grid_z_tmp = getWindVec4(...
    [u_grid_x(nan_z),u_grid_y(nan_z),ones(size(u_grid_x(nan_z)))*119],...
    U_abs, U_ang, UF);

u_grid_z(nan_z) = sqrt(sum(u_grid_z_tmp.^2,2));
u_grid_z=reshape(u_grid_z,size(u_grid_x));


    
%% Relative Error flow field



%% Plot
f = figure(11);
% ======================== FLORIDyn
s1 = subplot(3,1,1);
imagesc(Xaxis,Yaxis,u_grid_z);
hold on
set(gca,'YDir','normal');
axis equal;
axis tight;
c = colorbar;
c.Label.String ='Wind speed [m/s]';
c.Limits = [0,14];
set(gca, 'Clim', [0, 14])
colormap jet
xlabel('West-East [m]')
ylabel('South-North [m]')
title('FLORIDyn flow field')

% Plot Rotors
for i_T = 1:length(T.D)
    % Get start and end of the turbine rotor
    rot_pos = ...
        [cos(T.yaw(i_T)), -sin(T.yaw(i_T));...
        sin(T.yaw(i_T)), cos(T.yaw(i_T))] * ...
        [0,0;T.D(i_T)/2,-T.D(i_T)/2];
    rot_pos = rot_pos + repmat(T.pos(i_T,1:2)',1,size(rot_pos,2)); 
    plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',2);
end
ylim([1000,2000])
hold off

% ======================== SOWFA
s2 = subplot(3,1,2);
imagesc(Xaxis,Yaxis,U_SOWFA);
hold on
set(gca,'YDir','normal');
axis equal;
axis tight;
c = colorbar;
c.Label.String ='Wind speed [m/s]';
c.Limits = [0,14];
set(gca, 'Clim', [0, 14])
xlabel('West-East [m]')
ylabel('South-North [m]')
title('SOWFA flow field')
% Plot Rotors
for i_T = 1:length(T.D)
    % Get start and end of the turbine rotor
    rot_pos = ...
        [cos(T.yaw(i_T)), -sin(T.yaw(i_T));...
        sin(T.yaw(i_T)), cos(T.yaw(i_T))] * ...
        [0,0;T.D(i_T)/2,-T.D(i_T)/2];
    rot_pos = rot_pos + repmat(T.pos(i_T,1:2)',1,size(rot_pos,2)); 
    plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',2);
end
ylim([1000,2000])
hold off

% ======================== RE
s3 = subplot(3,1,3);
imagesc(Xaxis,Yaxis,(U_SOWFA-u_grid_z)./U_SOWFA*100);
hold on
set(gca,'YDir','normal');
axis equal;
axis tight;
c = colorbar;
c.Label.String ='Error [%]';
c.Limits = [-150,150];
set(gca, 'Clim', [-150,150])
colormap jet
c.Limits = [-150,150];
xlabel('West-East [m]')
ylabel('South-North [m]')
title('Relative wind speed error')
for i_T = 1:length(T.D)
    % Get start and end of the turbine rotor
    rot_pos = ...
        [cos(T.yaw(i_T)), -sin(T.yaw(i_T));...
        sin(T.yaw(i_T)), cos(T.yaw(i_T))] * ...
        [0,0;T.D(i_T)/2,-T.D(i_T)/2];
    rot_pos = rot_pos + repmat(T.pos(i_T,1:2)',1,size(rot_pos,2)); 
    plot3(rot_pos(1,:),rot_pos(2,:),[20,20],'k','LineWidth',2);
end
ylim([1000,2000])
hold off

% ======================== Prep for export
% scaling
f.Units               = 'centimeters';
f.Position(3)         = 16.1; % line width

% Set font & size
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);

set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))

% Export
f.PaperPositionMode   = 'auto';
%% Save to movie file
pause(0.1)
if Vis.Snapshots
    nr = num2str(k);
    nr = pad(nr,5,'left','0');
    print(['./Snapshot/' nr], '-dpng', '-r300')
end