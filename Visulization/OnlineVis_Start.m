% Start Online visulization
% Preparation of the online visulization.

%% Field Limits
fLim_x = fieldLims(:,1)';
fLim_y = fieldLims(:,2)';

%% create a meshgrid for the field coordinates, used by the contour plot
res = 10;
[u_grid_x,u_grid_y] = meshgrid(fLim_x(1):res:fLim_x(2),fLim_y(1):res:fLim_y(2));
u_grid_z = zeros(size(u_grid_x));

%% creating a cell array to store the rotor graphics
% since the number of rotors changes, there is not one object to delete but
% a varying number.
rotors = cell(length(T.D),1);

%% Meshgrid of field variables interpolation 
[UF.ufieldx,UF.ufieldy] = meshgrid(...
    linspace(min(UF.lims(:,1)),max(UF.lims(:,1)),UF.Res(1)),...
    linspace(min(UF.lims(:,2)),max(UF.lims(:,2)),UF.Res(2)));

%% Clean up
clear pos res
%% ===================================================================== %%
% = Reviewed: 2020.09.28 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %