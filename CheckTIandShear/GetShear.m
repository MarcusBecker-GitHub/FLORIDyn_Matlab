%%
[~,cellCenters,cellData] = importVTK('./CheckTIandShear/U_slice_vertical_Freestream.vtk');
UmeanAbsScattered = sqrt(sum(cellData.^2,2));
interpolant = ...
    scatteredInterpolant(cellCenters(:,2:3),UmeanAbsScattered);

% x axis plot = y axis field
Xaxis = linspace(...
    min(cellCenters(:,2),[],1),...
    max(cellCenters(:,2),[],1),300);

% y axis plot = z axis field
Yaxis = linspace(...
    min(cellCenters(:,3),[],1),...
    max(cellCenters(:,3),[],1),300);
[Xm,Ym] = meshgrid(Xaxis,Yaxis);
UmeanAbs = interpolant(Xm,Ym);

vertVeloProfile = [mean(UmeanAbs,2),Yaxis'];
%%
powLaw=@(alpha,u,z) (z/119).^alpha.*u;
cost = @(x) sqrt(sum((powLaw(x(1),x(2),vertVeloProfile(:,2))-vertVeloProfile(:,1)).^2));
%%
A = [1 0;-1 0; 0 1; 0 -1];
b = [0.5;0.01;8.5;7.5];
sol = fmincon(cost,[0.11;8],A,b);
disp(['U = ' num2str(sol(2)) ', alpha_s = ' num2str(sol(1))]);