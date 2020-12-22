function ind = pos2ind(pos,num_xy,grid_lims)
%POS2IND performs a nearest neighbor interpolation from any position to a
% grid of values and returns the index of the grid matrix entry related to
% the position
% ======================================================================= %
% INPUTS
% pos       := [n x 3] vec; points to get index for
% num_xy    := [1 x 2] vec; Number of grid points in x and y direction
% grid_lims := [2 x 2] mat; [delta x, delta y; (x,y) bottom left]
% ======================================================================= %
% OUTPUT
% ind       := [n x 1] vec; Index of the grid matrix the position belongs
%                           to.
% ======================================================================= %
%% Nearest neighbour interpolation
% Transform the (x,y) coordinates into the indeces of the wind field, so
% that the position is automatically matched to an entry in the matrix.
num_x = num_xy(1);
num_y = num_xy(2);

% Remove offset to lower left corner
n_pos = pos(:,1:2)-repmat(grid_lims(2,:),size(pos,1),1);

% Normalize position to range of the grid
%   Positions within the grid now have values in range of [0,1] 
n_pos(:,1) = (1-n_pos(:,1)./grid_lims(1,1));
n_pos(:,2) = (1-n_pos(:,2)./grid_lims(1,2));

% match outliers to closest edge
n_pos(n_pos>1) = 1;
n_pos(n_pos<0) = 0;

% round to index-space [1:n]
n_pos(:,1) = round(n_pos(:,1) * (num_x-1))+1;
n_pos(:,2) = round(n_pos(:,2) * (num_y-1))+1;

n_uf2 = [num_xy(2),num_xy(1)];
ind = sub2ind(n_uf2,n_pos(:,2),n_pos(:,1));
end
%% ===================================================================== %%
% = Reviewed: 2020.09.29 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %
