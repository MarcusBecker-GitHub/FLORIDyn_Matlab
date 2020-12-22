function I_0 = getAmbientTurbulence(pos, IR, I, n_uf, lims)
%GETAMBIENTTURBULENCE returns the ambient turbulence at the requested
%positions, interpolated by a nearest neighbour interpolation.
% ======================================================================= %
% INPUTS
% pos       := [n x 3] vec; points to get velocity for
% IR        := [p x m] Mat; Matrix which takes n measurements and
%                           returns m interpolated values: x2=IR*x1;
% I         := [1 x m] vec; Ambient turbulence measurements
% n_uf      := [1 x 2] vec; Number of points in x and y direction
% lims      := [2 x 2] mat; [delta x, delta y; (x,y) bottom left]
% ======================================================================= %
% OUTPUT
% I_0       := [n x 1] vec; Ambient turbulence intensity at the positions
% ======================================================================= %
%%
% Get the index of the grid matrix the position is matching to
%   Relates to the output of the IR multiplication
i = pos2ind(pos,n_uf,lims);

nx = n_uf(1);
ny = n_uf(2);

%% Interpolate
% Interpolate absolute value
I_interp = reshape(IR*I',[nx,ny]);
I_0 = I_interp(i);
end
%% ===================================================================== %%
% = Reviewed: 2020.09.28 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %