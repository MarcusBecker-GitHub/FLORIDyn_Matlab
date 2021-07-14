%% Get TI
[~,cellCenters,cellData] = importVTK('./CheckTIandShear/U_slice_horizontal.vtk');
UmeanAbsScattered = sqrt(sum(cellData.^2,2));

% interpolant = scatteredInterpolant(cellCenters(:,1:2),UmeanAbsScattered);
%% Free stream areas
Borders = {[0,500;0,1000],[700,1400;0,1000],...
    [1600,2300;0,1000],[2500,3000;0,1000]};

f = plotVTK('./CheckTIandShear/U_slice_horizontal.vtk');
hold on
for iB = 1:length(Borders)
    inB = and(cellCenters(:,1)>=Borders{iB}(1,1),...
        cellCenters(:,1)<=Borders{iB}(1,2));
    
    u_m = mean(UmeanAbsScattered(inB));
    u_v = std(UmeanAbsScattered(inB));
    scatter(cellCenters(inB,1),cellCenters(inB,2))
%     % x axis plot = x axis field
%     Xaxis = linspace(...
%         Borders{iB}(1,1),...
%         Borders{iB}(1,2),10);
%     
%     % y axis plot = z axis field
%     Yaxis = linspace(...
%         Borders{iB}(2,1),...
%         Borders{iB}(2,2),10);
%     
%     [Xm,Ym] = meshgrid(Xaxis,Yaxis);
%     UmeanAbs = interpolant(Xm,Ym);
%     
%     u_m = mean(UmeanAbs,'all');
%     u_v = std(UmeanAbs,0,'all');
    disp(['Sector ' num2str(iB) ', Ti = ' num2str(u_v/u_m*100,2) '%, U = '...
        num2str(u_m,2) 'm/s'])
%     scatter(Xm(:),Ym(:))
end
hold off