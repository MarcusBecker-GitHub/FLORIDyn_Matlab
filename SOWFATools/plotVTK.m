function fig = plotVTK(path)
% plotVTK plots the provided vtk wind field file and returns the figure.
% It supports xy, yz and xz slice plots. This function is dependent on the
% function importVTK().
%
% EXAMPLE (make sure to add Utilities to path)
%   fig = plotVTK('Umean_slice_1.vtk')
% ======================================================================= %

% Get data and calculate the absolute mean velocity
[~,cellCenters,cellData] = importVTK(path);
UmeanAbsScattered = sqrt(sum(cellData.^2,2));

% Determine the changing dimensions
% xySlice = 1+2+0 = 3
% yzSlice = 0+2+0 = 2
% xzSlice = 1+0+0 = 1
variation = var(cellCenters)>1;
sliceType = variation*[1;2;0];

if sum(variation) == 3
    error(['plotVTK only supports (x,y), (y,z) or (x,z)-plane slices. '...
        'The plovided file shows changes in all three dimensions.'])
end

switch sliceType
    case 3
        % Horizontal slice trough the wake field (xy plane)
        % Create 2D interpolant
        interpolant = ...
            scatteredInterpolant(cellCenters(:,1:2),UmeanAbsScattered);
        
        % x axis plot = x axis field
        Xaxis = linspace(...
            min(cellCenters(:,1),[],1),...
            max(cellCenters(:,1),[],1),300);
        
        % y axis plot = y axis field
        Yaxis = linspace(...
            min(cellCenters(:,2),[],1),...
            max(cellCenters(:,2),[],1),300);
        
    case 2
        % Vertical slice perpendicular to the wind (yz plane)
        % Create 2D interpolant
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
        
    case 1
        % Streamwise slice (xz plane)
        % Create 2D interpolant
        interpolant = ...
            scatteredInterpolant(cellCenters(:,[1,3]),UmeanAbsScattered);
        
        % x axis plot = x axis field
        Xaxis = linspace(...
            min(cellCenters(:,1),[],1),...
            max(cellCenters(:,1),[],1),300);
        
        % y axis plot = z axis field
        Yaxis = linspace(...
            min(cellCenters(:,3),[],1),...
            max(cellCenters(:,3),[],1),300);
end

% Create meshgrid for interpolation
[Xm,Ym] = meshgrid(Xaxis,Yaxis);
UmeanAbs = interpolant(Xm,Ym);

% Plot result
fig = figure();
imagesc(Xaxis,Yaxis,UmeanAbs);
set(gca,'YDir','normal');
axis equal;
axis tight;
