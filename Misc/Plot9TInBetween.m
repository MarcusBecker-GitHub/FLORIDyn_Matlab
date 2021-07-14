%% SOWFA slice
SOWFASlice = ['W:\OpenFOAM\marcusbecker-2.4.0\simulationCases\2021_Paper_Marcus\9turb_baseline_lowTI_changingDir\postProcessing\sliceDataInstantaneous\', ...
    num2str(20000+1101) '\U_slice_horizontal.vtk'];
f = plotVTK(SOWFASlice);
hold on
for i_T = 1:length(T.D)
    %Plot circular Rotor
    phi = linspace(0,2*pi);
    r = T.D(i_T)/2;
    yR = r*cos(phi);
    zR = r*sin(phi);
    
    cR = [...
        -sin(T.yaw(i_T)),0;...
        cos(T.yaw(i_T)),0;
        0,1]*[yR;zR];
    
    cR = cR'+T.pos(i_T,:);
    plot3(cR(:,1),cR(:,2),cR(:,3),'k','LineWidth',2);
    plot3(...
        [T.pos(i_T,1),T.pos(i_T,1)],...
        [T.pos(i_T,2),T.pos(i_T,2)],...
        [0,T.pos(i_T,3)],...
        'k','LineWidth',1.5);
end
cmp = viridis(1000);
colormap(cmp);
c = colorbar;
c.Label.String ='Wind speed [m/s]';
c.Limits = [.5 9.5];
caxis([.5 9.5]);
f.Units               = 'centimeters';
f.Position(3)         = 16.1/2; % A4 line width
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))
f.PaperPositionMode   = 'auto';
hold off
exportgraphics(gcf,'9T_HorFlow_t1100_SOWFA.pdf','ContentType','vector')
%% FLORIDyn slice 1
OnlineVis_Start;
%% FLORIDyn slice 2
%OP_pos_old = OP.pos;
%% FLORIDyn slice 3 (full)
f = figure;
hold on
n_th = 1;
OPtmp_pos = OP_pos_old(1:n_th:end,:);
OPtmp_u = OP.u(1:n_th:end,:);
aboveGround = OPtmp_pos(:,3)>1; % Cut off bottom layer at/under 1m
p = scatter3(...
    OPtmp_pos(aboveGround,1),...
    OPtmp_pos(aboveGround,2),...
    OPtmp_pos(aboveGround,3),...
    3,...%-sqrt(sum(OPtmp_u(aboveGround,:).^2,2)),...
    sqrt(sum(OPtmp_u(aboveGround,:).^2,2)),...
    'filled');
% Add wind field vectors
Uq = getWindVec3([UF.ufieldx(:),UF.ufieldy(:)],UF.IR, U_abs, U_ang, UF.Res, UF.lims);
q = quiver(UF.ufieldx(:),UF.ufieldy(:),Uq(:,1),Uq(:,2),'Color',[0.5,0.5,0.5]);

colormap(cmp);
c = colorbar;
c.Label.String ='Wind speed [m/s]';
c.Limits = [.5 9.5];
caxis([.5 9.5]);
axis equal
xlabel('West-East [m]')
xlim(fLim_x);
ylabel('South-North [m]')
ylim(fLim_y);
zlabel('Height [m]')
zlim([-10,500]);

view([0 90]);
grid on
% Plot the rotors
for i_T = 1:length(T.D)
    %Plot circular Rotor
    phi = linspace(0,2*pi);
    r = T.D(i_T)/2;
    yR = r*cos(phi);
    zR = r*sin(phi);
    
    cR = [...
        -sin(T.yaw(i_T)),0;...
        cos(T.yaw(i_T)),0;
        0,1]*[yR;zR];
    
    cR = cR'+T.pos(i_T,:);
    plot3(cR(:,1),cR(:,2),cR(:,3),'k','LineWidth',2);
    plot3(...
        [T.pos(i_T,1),T.pos(i_T,1)],...
        [T.pos(i_T,2),T.pos(i_T,2)],...
        [0,T.pos(i_T,3)],...
        'k','LineWidth',1.5);
end

hold off


%% FLORIDyn slice 3 (hubheight)
f = figure;
hold on
OPtmp_pos = OP_pos_old(1:n_th:end,:);
aboveGround = OP_pos_old(:,3)>1; % Cut off bottom layer at/under 1m
narc_height = OP_pos_old(:,3)<mean(T.pos(:,3))*1.5;
narc_height = and(OP_pos_old(:,3)>mean(T.pos(:,3))*0.5,narc_height);
p = scatter3(...
    OPtmp_pos(and(aboveGround,narc_height),1),...
    OPtmp_pos(and(aboveGround,narc_height),2),...
    OPtmp_pos(and(aboveGround,narc_height),3),...
    2,...%-sqrt(sum(OPtmp_u(aboveGround,:).^2,2)),...
    sqrt(sum(OP.u(and(aboveGround,narc_height),:).^2,2)),...
    'filled');
% Add wind field vectors
Uq = getWindVec3([UF.ufieldx(:),UF.ufieldy(:)],UF.IR, U_abs, U_ang, UF.Res, UF.lims);
q = quiver(UF.ufieldx(:),UF.ufieldy(:),Uq(:,1),Uq(:,2),'Color',[0.5,0.5,0.5]);

colormap(cmp);
c = colorbar;
c.Label.String ='Wind speed [m/s]';
c.Limits = [.5 9.5];
caxis([.5 9.5]);
axis equal
xlabel('West-East [m]')
xlim(fLim_x);
ylabel('South-North [m]')
ylim(fLim_y);
zlabel('Height [m]')
zlim([-10,500]);

% nr = num2str(Sim.TimeSteps(k));
% nr = pad(nr,4,'left','0');
% title([num2str(length(T.D)) ' turbine case, t = ' nr  's'])

%view([-i/251*80-5 20]);
% zrot = max(k/80*(-10)-5,-15) + max(k-144,0)/60*13 - max(k-204,0)/60*13;
% xrot = min(k/80*37,37)+ 5 + max(k-144,0)/80*38 - max(k-204,0)/80*38;
view([0 90]);
grid on
% Plot the rotors
for i_T = 1:length(T.D)
    %Plot circular Rotor
    phi = linspace(0,2*pi);
    r = T.D(i_T)/2;
    yR = r*cos(phi);
    zR = r*sin(phi);
    
    cR = [...
        -sin(T.yaw(i_T)),0;...
        cos(T.yaw(i_T)),0;
        0,1]*[yR;zR];
    
    cR = cR'+T.pos(i_T,:);
    plot3(cR(:,1),cR(:,2),cR(:,3),'k','LineWidth',2);
    plot3(...
        [T.pos(i_T,1),T.pos(i_T,1)],...
        [T.pos(i_T,2),T.pos(i_T,2)],...
        [0,T.pos(i_T,3)],...
        'k','LineWidth',1.5);
end

hold off
f.Units               = 'centimeters';
f.Position(3)         = 16.1/2; % A4 line width
set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))
f.PaperPositionMode   = 'auto';
hold off
exportgraphics(gcf,'9T_HorFlow_t1100_FLORIDyn.pdf','ContentType','vector')