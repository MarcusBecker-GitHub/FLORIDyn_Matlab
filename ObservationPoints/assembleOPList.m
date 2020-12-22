function [OP, chain] = assembleOPList(chain,T,distr_method)
% assembleOPList creates a struct for the Observation Point data needed to
% create the wake shape and the velocity deficit.
%   The function calculates the distribution of the OPs relative to the
%   wake width. It also allocates the storage needed for the rest of the
%   data.
%   The chain struct gets extended by .List and .dstr: .List describes the
%   storage of the OPs in chains. All OPs are stored in a coloumn
%   structure, .List stores the start index of each chain, which entry to
%   overwrite, how many entries a chain has and which turbine it belongs
%   to. Further it also stores the relative area represented by the chain.
%   The .dstr entry holds the relative chain cross wind position
% ======================================================================= %
% INPUT
%   chain       := Struct;    Data related to the OP management / chains
%    .NumChains := int;       Number of Chains per turbine
%    .Length    := int/[nx1]; Length of the Chains - either uniform for all
%                             chains or individually set for every chain.
%
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines
%    .Ct        := [nx1] vec; Current Ct of the n turbines
%    .Cp        := [nx1] vec; Current Cp of the n turbines
%
%   distr_method:= String;    Name of the strategy to distribute points
%                             across the wake cross section
%                               (currently only 'sunflower')
% ======================================================================= %
% OUTPUT
%   OP          := Struct;    Data related to the state of the OPs
%    .pos       := [nx3] vec; [x,y,z] world coord. (can be nx2)
%    .dw        := [nx1] vec; downwind position (wake coordinates)
%    .r         := [nx1] vec; Reduction factor: u = U*(1-r)
%    .yaw       := [nx1] vec; yaw angle (wake coord.) at the time of creat.
%    .Ct        := [nx1] vec; Ct coefficient at the time of creation
%    .t_id      := [nx1] vec; Turbine OP belongs to
%    .U         := [nx2] vec; Uninfluenced wind vector at OP position
%    .I_f       := [nx1] vec; Foreign added turbunlence
%
%   chain       := Struct;    Data related to the OP management / chains
%    .NumChains := int;       Number of Chains per turbine
%    .Length    := int/[nx1]; Length of the Chains - either uniform for all
%                             chains or individually set for every chain.
%    .List      := [nx5] vec; [Offset, start_id, length, t_id, relArea]
%    .dstr      := [nx2] vec; Relative y,z distribution of the chain in the
%                             wake, factor multiplied with the width, +-0.5
% ======================================================================= %
%% Constants
Dim             = 3; % Since the model is defined in 3D
NumTurb         = length(T.D);
NumChainsTot    = chain.NumChains*NumTurb; % Total number of chains across all t.
chainList       = zeros(NumChainsTot,5);
chainList(:,4)  = reshape(repmat(1:NumTurb,chain.NumChains,1),NumChainsTot,1);

% ==== Build Chains ==== %
if length(chain.Length)==NumChainsTot
    % diverse length, for every chain there is a length.
    
    % Get starting indeces
    chainList(:,2) = cumsum(chain.Length')'-chain.Length+1;
else
    % Starting points
    chainList(:,2) = cumsum(ones(1,NumChainsTot)*chain.Length(1))'...
        -chain.Length(1)+1;
end

% Store chain length
chainList(:,3) = chain.Length;
    
% Allocate opList
len_OPs = sum(chainList(:,3));

%(pos, dw, r, U, a,yaw t_ind)
op_pos  = zeros(len_OPs,Dim);
op_dw   = zeros(len_OPs,1);
op_U    = zeros(len_OPs,2);
op_yaw  = zeros(len_OPs,1);
op_Ct   = zeros(len_OPs,1);        %Otherwise the first points are init. wrong
op_t_id = assignTIDs(chainList,len_OPs);

op_pos(:,1:Dim) = T.pos(op_t_id,1:Dim);

cl_dstr = zeros(NumChainsTot,Dim-1);

% Relative area the OPs are representing
cl_relA = zeros(NumChainsTot,1);

switch distr_method
    case 'sunflower'
        % Distribute the n chains with r = sqrt(n) approach. The angle
        % between two chains still has to be determined.
        % In chain list, the relative coordinates have to be set 
        % [-.5,0.5] 
        if Dim == 3
            % 3 Dimentional field: 2D rotor plane
            [y,z,repArea] = sunflower(chain.NumChains, 2);
            
            cl_dstr(:,1) = repmat(y,NumTurb,1).*0.5;
            cl_dstr(:,2) = repmat(z,NumTurb,1).*0.5;
            cl_relA = repmat(repArea,NumTurb,1);
        else
            % 2 Dimentional field: 1D rotor plane
            y = linspace(-0.5,.5,chain.NumChains)';
            cl_dstr(:) = repmat(y,NumTurb,1);
            
            
            % Calculate the represened Area by the observation point
            % assuming a circular rotor plane with r=0.5.
            
            % A(d) calculates the area given by a circular segment with the
            % distance d to the circle center
            A =@(d) 0.25*acos(d/0.5)-d.*0.5.*sqrt(1-d.^2/0.25);
            
            % repArea contains the area from the center to the outside
            
            %d = zeros(floor(chain.NumChains/2),1);
            if mod(chain.NumChains,2)==0
                % Even
                d = 1/chain.NumChains*(0:(chain.NumChains-1)/2);
                repArea = A(d);
                repArea(1:end-1) = repArea(1:end-1)-repArea(2:end);
                
                % Combine halves and normalize
                repArea_all = [repArea(end:-1:1),repArea];
                repArea_all = repArea_all/sum(repArea_all);
                cl_relA = repmat(repArea_all',NumTurb,1);
            else
                % Uneven
                d = [0,1/(chain.NumChains-1)*(0.5:(chain.NumChains-1)/2)];
                repArea = A(d);
                repArea(1:end-1) = repArea(1:end-1)-repArea(2:end);
                
                % Center area is split in two
                repArea(1) = repArea(1)*2;
                
                % Combine halves and normalize
                repArea_all = [repArea(end:-1:2),repArea];
                repArea_all = repArea_all/sum(repArea_all);
                cl_relA = repmat(repArea_all',NumTurb,1);
            end
            
        end
    case '2D_horizontal'
        % 2 Dimentional field: 1.5D rotor plane
        upN = round(chain.NumChains/2);
        lowN = chain.NumChains-upN;
        
        y_up = linspace(-0.5,.5,upN)';
        y_low = linspace(-0.5,.5,lowN)';
        
        z_up = ones(size(y_up))*0.05;
        z_low = -ones(size(y_low))*0.05;
        
        cl_dstr(:,1) = repmat([y_up;y_low],NumTurb,1);
        cl_dstr(:,2) = repmat([z_up;z_low],NumTurb,1);
        
        % Calculate the represened Area by the observation point
        % assuming a circular rotor plane with r=0.5.
        %   A(d) calculates the area given by a circular segment with the
        %   distance d to the circle center
        A =@(d) 0.25*acos(d/0.5)-d.*0.5.*sqrt(1-d.^2/0.25);
        
        if mod(upN,2)==0
            % Even Up
            d = 1/upN*(0:(upN-1)/2);
            repArea = A(d)/2;
            repArea(1:end-1) = repArea(1:end-1)-repArea(2:end);
            
            % Combine halves
            repArea_up = [repArea(end:-1:1),repArea];
        else
            % Uneven Up
            d = [0,1/(upN-1)*(0.5:(upN-1)/2)];
            repAreaUp = A(d)/2;
            repAreaUp(1:end-1) = repAreaUp(1:end-1)-repAreaUp(2:end);
            % Center area is split in two
            repAreaUp(1) = repAreaUp(1)*2;
            
            % Combine halves
            repArea_up = [repAreaUp(end:-1:2),repAreaUp];
        end
        
        if mod(lowN,2)==0
            % Even Low
            d = 1/lowN*(0:(lowN-1)/2);
            repArea = A(d)/2;
            repArea(1:end-1) = repArea(1:end-1)-repArea(2:end);
            
            % Combine halves
            repArea_low = [repArea(end:-1:1),repArea];
        else
            % Uneven Low
            d = [0,1/(lowN-1)*(0.5:(lowN-1)/2)];
            repAreaLow = A(d)/2;
            repAreaLow(1:end-1) = repAreaLow(1:end-1)-repAreaLow(2:end);
            % Center area is split in two
            repAreaLow(1) = repAreaLow(1)*2;
            
            % Combine halves
            repArea_low = [repAreaLow(end:-1:2),repAreaLow];
        end
        
        % Combine and normalize
        repArea_all = [repArea_up,repArea_low];
        repArea_all = repArea_all/sum(repArea_all);
        cl_relA = repmat(repArea_all',NumTurb,1);
        
    case '2D_vertical'
        % 2 Dimentional field: 1.5D rotor plane
        upN = round(chain.NumChains/2);
        lowN = chain.NumChains-upN;
        
        z_up  = linspace(-0.5,.5,upN)';
        z_low = linspace(-0.5,.5,lowN)';
        
        y_up  = ones(size(z_up))*0.05;
        y_low = -ones(size(z_low))*0.05;
        
        cl_dstr(:,1) = repmat([y_up;y_low],NumTurb,1);
        cl_dstr(:,2) = repmat([z_up;z_low],NumTurb,1);
        
        % Calculate the represened Area by the observation point
        % assuming a circular rotor plane with r=0.5.
        %   A(d) calculates the area given by a circular segment with the
        %   distance d to the circle center
        A =@(d) 0.25*acos(d/0.5)-d.*0.5.*sqrt(1-d.^2/0.25);
        
        if mod(upN,2)==0
            % Even Up
            d = 1/upN*(0:(upN-1)/2);
            repArea = A(d)/2;
            repArea(1:end-1) = repArea(1:end-1)-repArea(2:end);
            
            % Combine halves
            repArea_up = [repArea(end:-1:1),repArea];
        else
            % Uneven Up
            d = [0,1/(upN-1)*(0.5:(upN-1)/2)];
            repAreaUp = A(d)/2;
            repAreaUp(1:end-1) = repAreaUp(1:end-1)-repAreaUp(2:end);
            % Center area is split in two
            repAreaUp(1) = repAreaUp(1)*2;
            
            % Combine halves
            repArea_up = [repAreaUp(end:-1:2),repAreaUp];
        end
        
        if mod(lowN,2)==0
            % Even Low
            d = 1/lowN*(0:(lowN-1)/2);
            repArea = A(d)/2;
            repArea(1:end-1) = repArea(1:end-1)-repArea(2:end);
            
            % Combine halves
            repArea_low = [repArea(end:-1:1),repArea];
        else
            % Uneven Low
            d = [0,1/(lowN-1)*(0.5:(lowN-1)/2)];
            repAreaLow = A(d)/2;
            repAreaLow(1:end-1) = repAreaLow(1:end-1)-repAreaLow(2:end);
            % Center area is split in two
            repAreaLow(1) = repAreaLow(1)*2;
            
            % Combine halves
            repArea_low = [repAreaLow(end:-1:2),repAreaLow];
        end
        
        % Combine and normalize
        repArea_all = [repArea_up,repArea_low];
        repArea_all = repArea_all/sum(repArea_all);
        cl_relA = repmat(repArea_all',NumTurb,1);
end
chainList(:,5) = cl_relA;

OP.pos  = op_pos;
OP.dw   = op_dw;
OP.U    = op_U;
OP.yaw  = op_yaw;
OP.Ct   = op_Ct;
OP.t_id = op_t_id;
OP.I_f  = zeros(size(op_Ct));

chain.List = chainList;
chain.dstr = cl_dstr;
end

function t_id = assignTIDs(chainList,len_OPs)
% ASSIGNTIDS writes t_id entries of opList
ind_op = 1;
ind_ch = 1;
t_id = zeros(len_OPs,1);
while ind_op<=len_OPs
    if(ind_op == sum(chainList(ind_ch,[2 3])))
        ind_ch = ind_ch + 1;
    end
    
    t_id(ind_op) = chainList(ind_ch,4);
    
    ind_op = ind_op+1;
end
end

% chainList
% [ off, start_id, length, t_id, relArea]

%% ===================================================================== %%
% = Reviewed: 2020.09.28 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %