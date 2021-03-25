function rel = getRelations(OP,T,chain,onlyRotorPlane)
%getRelations Returns a matrix with the indices of the closest neigbours in
%the other wakes for each OP and -1 if the OP is in no wake.
% ======================================================================= %
% INPUT
%   OP          := Struct;    Data related to the state of the OPs
%    .pos       := [nx3] vec; [x,y,z] world coord. (can be nx2)
%    .dw        := [nx1] vec; downwind position (wake coordinates)
%    .yaw       := [nx1] vec; yaw angle (wake coord.) at the time of creat.
%    .Ct        := [nx1] vec; Ct coefficient at the time of creation
%    .t_id      := [nx1] vec; Turbine OP belongs to
%    .U         := [nx2] vec; Uninfluenced wind vector at OP position
%    .u         := [nx1] vec; Effective wind speed at OP position
%
%   chain       := Struct;    Data related to the OP management / chains
%    .NumChains := int;       Number of Chains per turbine
%    .Length    := int/[nx1]; Length of the Chains - either uniform for all
%                             chains or individually set for every chain.
%    .List      := [nx5] vec; [Offset, start_id, length, t_id, relArea]
%    .dstr      := [nx2] vec; Relative y,z distribution of the chain in the
%                             wake, factor multiplied with the width, +-0.5
%
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines
%    .Ct        := [nx1] vec; Current Ct of the n turbines
%    .Cp        := [nx1] vec; Current Cp of the n turbines
%    .U         := [nx2] vec; Wind vector for the n turbines
%    .u         := [nx1] vec; Effective wind speed at the rotor plane
% ======================================================================= %
% OUTPUT
%   rel         := [nxt] mat; Matrix with the index of the closest
%                               neighbour in the other turbine wakes 
% ======================================================================= %
% https://www.mathworks.com/help/stats/knnsearch.html
% Alternative:
% https://www.mathworks.com/help/matlab/ref/dsearchn.html
%% Test [Idx,D] = knnsearch(X,Y);
numT    = length(T.D);
rel     = zeros(size(OP.pos,1),numT);
if numT==1;return;end

OPsInT      = zeros(numT,1);
chainStarts = false(size(OP.t_id));

ind = chain.List(:,1) + chain.List(:,2);
chainStarts(ind) = true;
%% For each Turbine, retrieve all closest neighbours from all turbines
for iT1 = 1:numT
    isT1 = OP.t_id == iT1;
    OPsInT(iT1) = sum(isT1);
    tD = T.D(iT1);
    for iT2 = 1:numT
        % Skip self
        if iT2 == iT1; continue; end
        % Skip turbines further away than 15D
        if sqrt(sum((T.pos(iT1)-T.pos(iT2)).^2))>15*T.D(iT1); continue; end
            
        isT2 = OP.t_id == iT2;
        
        if onlyRotorPlane
            % Only use OPs at the start of the chains
            isT1 = and(isT1,chainStarts);
            [Idx,D] = knnsearch(OP.pos(isT2,:),OP.pos(isT1,:));
        else
            [Idx,D] = knnsearch(OP.pos(isT2,:),OP.pos(isT1,:));
        end
        
        
        closeOP = D<tD/4;
        
        hasPartner = isT1;
        hasPartner(isT1) = and(hasPartner(isT1),closeOP);
        rel(hasPartner,iT2) = Idx(closeOP);
    end
end


for iT = 2:numT
    isNot = OP.t_id ~= iT;
    match = rel(:,iT)>0;
    rel(and(isNot,match),iT) = rel(and(isNot,match),iT) + sum(OPsInT(1:iT-1));
end

end

