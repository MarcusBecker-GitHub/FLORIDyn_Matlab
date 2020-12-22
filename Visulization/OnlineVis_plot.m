
%% Plot the OPs
f = figure(1);
clf;
%axes1 = axes('Parent',f);
hold on

n_th = 1;

OPtmp_pos = OP_pos_old(1:n_th:end,:);
OPtmp_u = OP.u(1:n_th:end,:);

aboveGround = OPtmp_pos(:,3)>1; % Cut off bottom layer under 5m
p = scatter3(...
    OPtmp_pos(aboveGround,1),...
    OPtmp_pos(aboveGround,2),...
    OPtmp_pos(aboveGround,3),...
    20-sqrt(sum(OPtmp_u(aboveGround,:).^2,2)),...
    sqrt(sum(OPtmp_u(aboveGround,:).^2,2)),...
    'filled');

%% Add wind field vectors
Uq = getWindVec3([UF.ufieldx(:),UF.ufieldy(:)],UF.IR, U_abs, U_ang, UF.Res, UF.lims);
q = quiver(UF.ufieldx(:),UF.ufieldy(:),Uq(:,1),Uq(:,2),'Color',[0.5,0.5,0.5]);

colormap jet
c = colorbar;
c.Label.String ='Windspeed [m/s]';
c.Limits = [0,10];
axis equal
xlabel('West-East [m]')
xlim(fLim_x);
ylabel('South-North [m]')
ylim(fLim_y);
zlabel('Height [m]')
zlim([-300,500]);

nr = num2str(Sim.TimeSteps(k));
nr = pad(nr,4,'left','0');
title(['Nine turbine case, +60 deg wind change. t = ' nr  's'])

%view([-i/251*80-5 20]);
zrot = max(k/80*(-10)-5,-15) + max(k-144,0)/60*13 - max(k-204,0)/60*13;
xrot = min(k/80*37,37)+ 5 + max(k-144,0)/80*38 - max(k-204,0)/80*38;
view([zrot xrot]);
grid on
%% Plot the rotors
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
set(f.Children, ...
    'FontName',     'Frontpage', ...
    'FontSize',     10);
%axes1.Projection = 'perspective';

%% Plot the Power Output
% subplot(2,1,2)
% plot(Sim.TimeSteps,powerHist(1,:),'LineWidth',2);
% hold on
% for ii = 2:length(T.D)
%     plot(Sim.TimeSteps,powerHist(ii,:),'LineWidth',2);
% end
% title('Power Output')
% ylabel('Power output in W')
% xlabel('Time [s]')
% xlim([0,Sim.TimeSteps(end)])
% ylim([0 inf])
% grid on
% hold off

% pause(0.1)
% if Vis.Snapshots
%     nr = num2str(k);
%     nr = pad(nr,4,'left','0');
%     print(['./Snapshot/' nr], '-dpng', '-r300')
% end



% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)