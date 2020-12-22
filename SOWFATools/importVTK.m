function [dataType,cellCenters,cellData] = importVTK(file)
%IMPORTVTK imports standard SOWFA vtk files
% [dataType,cellCenters,cellData] = importVTK(file);
% 
% input: file = location of vtk-file
% outputs
% dataType =  OpenFOAM label of measurement (e.g. U, Umean, have not tested
% for several measurements)
% cellCenters = locations of sampling (x,y,z)
% cellData = sampling values (could be vectors (rows))
% 
% Usage:
% [dataType,cellCenters,cellData] = importVTK('Umean_slice_1.vtk')
%
% then dataType{1} = 'Umean', and for a typical Umean_slice_1, 
% cellCenters(:,3) = hubheight 
% also, note that:
% - Umean is a vector with x- y- and z-component of mean velocity
% note that the cellCenters are scattered, so you have to use 
% scatteredInterpolant or TriScatteredInterp (older MATLAB) in order to 
% get the data on a uniform grid, e.g.
% 
% EXAMPLE (make sure to add Utilities to path)
% [dataType,cellCenters,cellData] = importVTK('Umean_slice_1.vtk');
% UmeanAbsScattered = sqrt(sum(cellData.^2,2)); % get the absolute mean velocity
% interpolant = scatteredInterpolant(cellCenters(:,1:2),UmeanAbsScattered); % create 2D interpolant
% % or interpolant = TriScatteredInterp(cellCenters(:,1:2),UmeanAbsScattered);
% % create uniform grid at hub-height
% Z = cellCenters(1,3); % hub-height
% Xaxis = linspace(min(cellCenters(:,1),[],1),max(cellCenters(:,1),[],1),300);
% Yaxis = linspace(min(cellCenters(:,2),[],1),max(cellCenters(:,2),[],1),300);
% [Xm,Ym] = meshgrid(Xaxis,Yaxis);
% UmeanAbs = interpolant(Xm,Ym); % interpolate on grid
% imagesc(Xaxis,Yaxis,UmeanAbs); % plot it
% set(gca,'YDir','normal'); axis equal;
% colormap(diverging_map(linspace(0,1,100),[0.230,0.299,0.754],[0.706,0.016,
% 0.150])); % get the paraview colormap

    file = fopen(file,'r');
    while (~feof(file))
        inputText = textscan(file,'%s',1,'delimiter','\n');
        inputText = strtrim(cell2mat(inputText{1}));
        if strcmpi(inputText,'DATASET POLYDATA')
            nPoints = cell2mat(textscan(file,'POINTS %d float'));
            pointsXYZ = cell2mat(textscan(file,'%f %f %f',nPoints));
        end
       
        if strncmpi(inputText,'POLYGONS',8)
            nPolygons  = sscanf(inputText,'POLYGONS %d %d');
%             nEdgesCell = nPolygons(2)/nPolygons(1)-1;
            nPolygons  = nPolygons(1);
%             polygons = cell2mat(textscan(file,'3 %d %d %d',nPolygons));
%             polygons = cell2mat(textscan(file,[num2str(nEdgesCell) ' %d %d %d %d'],nPolygons));
            polygons = cell2mat(textscan(file,['%d %d %d %d %d %d %d %d %d %d %d'],nPolygons));
            nEdgesCell = polygons(:,1);
            
            if(length(unique(nEdgesCell)) == 1)
                nEdgesCell = nEdgesCell(1);
                polygons = polygons(:,2:nEdgesCell+1);
            else
                polygons = polygons(:,2:end);
            end
        end
        
        if strncmpi(inputText,'CELL_DATA',9)
            nAttributes = cell2mat(textscan(file,'FIELD attributes %d',1));
            cellData = cell(1,nAttributes);
            dataType = cell(1,nAttributes);
            for att = 1:nAttributes
                fieldData = textscan(file,'%s %d %d %s',1);
                if strcmpi(fieldData{4},'float') && fieldData{3}==nPolygons
                    dataType{att} = fieldData{1};
                    format = strtrim(repmat('%f ',[1,fieldData{2}]));
                    cellData{att} = cell2mat(textscan(file,format,nPolygons));
                else
                    error('format problem')
                end
            end
        end
    end
    
    % cell to point data
    
    if length(nEdgesCell) > 1
        % Slow loop, inefficient way of doing things, but clear:
        cellCenters = zeros(nPolygons,3);
        for i = 1:nPolygons
            tmp_cellPositions = pointsXYZ(polygons(i,1:nEdgesCell(i))+1,:);
            cellCenters(i,:) = mean(tmp_cellPositions,1);
        end
    else
        % Efficient way of doing things
        cellCenters = [mean(reshape((pointsXYZ(polygons+1,1)),[],nEdgesCell),2),...
            mean(reshape((pointsXYZ(polygons+1,2)),[],nEdgesCell),2),...
            mean(reshape((pointsXYZ(polygons+1,3)),[],nEdgesCell),2)];
    end
    cellData = cell2mat(cellData);
    
    fclose(file);
    
end

