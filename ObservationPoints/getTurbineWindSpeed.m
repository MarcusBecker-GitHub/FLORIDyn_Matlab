function tl_u = getTurbineWindSpeed(op_u,chainList, tl_D)
%GETTURBINEWINDSPEED calculates the effective wind speed at the rotor plane
%   The wind speed of the first OPs in the chains is summed, weighted over
%   the area they represent.
% ======================================================================= %
% INPUT
%   op_u        := [nx2] vec; Effective wind vector at the OPs location
%   chainList   := [cx5] mat; List of the c chains, their indexes & weights
%   tl_D        := [tx1] vec; Diameter of all t turbines
% ======================================================================= %
% OUTPUT
%   tl_u        := [tx1] vec; Effective wind speed at the rotor plane
% ======================================================================= %
%%
% Get indeces of the starting observation points
ind = chainList(:,1) + chainList(:,2);
numT = length(tl_D);

% Get speed of first OPs in chains
all_u = sqrt(op_u(ind,1).^2 + op_u(ind,2).^2);

% Apply weights
all_u = chainList(:,5).*all_u;

% Sum for each turbines and return
tl_u = zeros(numT,1);
for i = 1:numT
    tl_u(i) = sum(all_u(chainList(:,4)==i));
end

end
%% ===================================================================== %%
% = Reviewed: 2020.09.29 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %