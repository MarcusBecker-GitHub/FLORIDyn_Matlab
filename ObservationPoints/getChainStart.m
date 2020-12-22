function OPs = getChainStart(NumChains, tl_D)
% getChainStart creates starting points of the chains based on the number
% of chains and the turbines
%
% INPUT
% NumChains     := Int
% TurbinePosD   := [nx4] vector, [x,y,z,d] // World coordinates & in m
%
% OUTPUT
% OPs           := [(n*m)x5] m Chain starts [t_id, d,c_ind] per turbine

% Allocation
OPs = zeros(NumChains*length(tl_D),3);

% assign each OP to a turbine (first all OPs from turbine 1, then t2 etc.)

t_d     = repmat(tl_D',NumChains,1);
c_ind   = repmat((1:NumChains)',length(tl_D),1);

OPs(:,1) = t_ind(:);    % Turbine index
OPs(:,2) = t_d(:);      % Turbine diameter
OPs(:,3) = c_ind;       % Chain index
end

% 1:3 are unused!