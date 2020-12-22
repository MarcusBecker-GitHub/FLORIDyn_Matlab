function U = getWindVec2(pos,IR, U_meas_x, U_meas_y, n_uf, lims)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%
% INPUTS
% pos       := [n x 2] vec; points to get velocity for
% IR        := [m x n] Mat; Matrix which takes n measurements and
%                     returns m interpolated values: x2=IR*x1;
% U_meas_x  := [1 x n] vec; n Measurements in x direction
% U_meas_y  := [1 x n] vec; n Measurements in y direction
% n_uf      := [1 x 2] vec; Number of points in x and y direction
% lims      := [2 x 2] mat; [delta x, delta y; (x,y) bottom left]
nx = n_uf(1);
ny = n_uf(2);

% Nearest neighbour interpolation
n_pos = pos(:,1:2)-lims(2,:);

n_pos(:,1) = (1-n_pos(:,1)./lims(1,1));
n_pos(:,2) = n_pos(:,2)./lims(1,2);

n_pos(n_pos>1) = 1;
n_pos(n_pos<0) = 0;

n_pos(:,1) = round(n_pos(:,1) * (nx-1))+1;
n_pos(:,2) = round(n_pos(:,2) * (ny-1))+1;

n_uf2 = [n_uf(2),n_uf(1)];
i = sub2ind(n_uf2,n_pos(:,2),n_pos(:,1));

U = zeros(size(pos(:,1:2)));

U_interp = reshape(IR*U_meas_x',[nx,ny]);
U(:,1) = U_interp(i);

U_interp = reshape(IR*U_meas_y',[nx,ny]);
U(:,2) = U_interp(i);

end

