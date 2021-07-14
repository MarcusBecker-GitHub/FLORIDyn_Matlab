
%% Plot the OPs
f = figure(4);
clf;
%axes1 = axes('Parent',f);
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
title([num2str(length(T.D)) ' turbine case, t = ' nr  's'])

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
% set(f.Children, ...
%     'FontName',     'Frontpage', ...
%     'FontSize',     10);
%axes1.Projection = 'perspective';

pause(0.1)
if Vis.Snapshots
    % Store pictures, might require the creation of the folder "Snapshot"
    nr = num2str(k);
    nr = pad(nr,4,'left','0');
    print(['./Snapshot/' nr], '-dpng', '-r300')
end