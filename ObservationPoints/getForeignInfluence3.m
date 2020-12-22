function r_f = getForeignInfluence3(OP,T,chain,OP_r,onlyRotorPlane)

% Save number of turbines
nT = length(T.D);
inds = [1:length(OP.t_id)]';
r_f = ones(size(OP_r));

% Create relations matrix
%   -1: No interaction / no partner
%    0: No partner found yet
%   >0: ID of partner
rel = -ones(size(OP.pos,1),nT);
aboveZero = OP.pos(:,3)>0;

% if only rotor plane, set rest also to -1
if onlyRotorPlane
    % Activate only rotor points for search of enighbour
    ind = chain.List(:,1) + chain.List(:,2);
    rel(ind,:)  = 0;
    
    % ======== DIFFERENT SEARCH REQUIRED IF ONLY ROTOR PLANE ======== %
    % Always have to look in all wakes - right? No partners
else
    % Activate search for all points above the ground
    rel(aboveZero,:) = 0;
end

% Search for nearest neighbours
for t_i = 1:nT
    opTi = OP.t_id == t_i;
    rel(opTi,t_i)=-1;
    D = T.D(t_i);
    
    % t_i is looking in the wake of t_ii for nearest neighbours:
    %   First tubine looks T2 to end, second in 3 to end, ...
    for t_ii = 1:nT
        if t_ii == t_i; continue; end
        % Include only searching points for the other turbine! needs to be 0 at
        % other turbine index not t_i
        opTi_tmp = and(opTi,rel(:,t_ii)==0);
        
        opTii = OP.t_id == t_ii;
        
        % Drop the points at height 0
        opTii = and(opTii,OP.pos(:,3)>0);
        
        rel_tmp = zeros(sum(opTi_tmp),1);
        ti_pos_tmp = OP.pos(opTi_tmp,:);
        
        % Calculate distances for the searching OPs
        for op_i = 1:length(rel_tmp)
            % Calc Distance
%             [dis,ind] = min(sqrt(...
%                 sum((OP.pos(opTii,:)...
%                 -repmat(ti_pos_tmp(op_i,:),sum(opTii),1)).^2,2)));
            [dis,ind] = min(sqrt(...
                sum((OP.pos(opTii,:)...
                -ti_pos_tmp(op_i,:)).^2,2)));
            if dis<D/6
                % close enough
                rel_tmp(op_i) = ind;
            else
                rel_tmp(op_i) = -1;
            end
        end
        % Write all, overwrite with fitting indeces later
        rel(opTi_tmp,t_ii)=rel_tmp;
        
        % Only mind the ones with connections
        opTi_tmp(opTi_tmp) = and(opTi_tmp(opTi_tmp),rel_tmp>0);
        
        % correct the relation index
        inds_tmp = inds(opTii);
        rel(opTi_tmp,t_ii) = inds_tmp(rel_tmp(rel_tmp>0));
        
        % Reverse mapping is difficult since one OP might be the closest
        % for multiple other, but it itself only has one neighbour
        % -> only assign those who have one connection!
        if t_i<t_ii
            % Don't modifiy already set relations
            inds_tmp = inds(opTi);
            [uniqueMatches, iu, ~] = unique(rel(opTi,t_ii));
            rel(uniqueMatches(2:end),t_i) = inds_tmp(iu(2:end));
        end
    end
    
    
end

for t_i = 1:nT
    entries = rel(:,t_i)>0;
    r_f(entries) = r_f(entries).*(1-OP_r(rel(entries,t_i)));
end

end
