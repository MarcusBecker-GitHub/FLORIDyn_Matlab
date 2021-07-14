function [T,fieldLims,Pow,VCpCt,chain] = loadLayout(layout, varargin)
% LOADLAYOUT Creates and loads the data necessary for the wind farm layout
%   Here, the layout of the wind farm, its dimentions and the data of the
%   turbines are set. The different layouts are chosen by a switch case.
%   The switch case might overwrite data which can be set in variargin, so
%   be aware to check for that.
%   In the current version of the code, chains can have different lengths,
%   but it is not possible to change the length during the simulation.
% ======================================================================= %
% INPUT
%   layout      := String; Name of the Scenario used for the switch case.
%                           'nineDTU10MW_Maatren':
%                               9 turbines in a 3x3 grid
%                           'twoDTU10MW_Maarten':
%                               2 turbines behind each other
%
%   varargin    := String,Value: Option to change the value of the 
%                                    default variables.
% --- Var Name -|- Default -|- Explenation ------------------------------ %
% ChainLength   | 200 OPs   | Number of Observation points in a chain
% NumChains     | 100       | Number of chains per wind turbine
% ======================================================================= %
% OUTPUT
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines    (Allocation)
%    .Ct        := [nx1] vec; Current Ct of the n turbines     (Allocation)
%    .Cp        := [nx1] vec; Current Cp of the n turbines     (Allocation)
%    .P         := [nx1] vec; Power production                 (Allocation)
%
%   fieldLims   := [2x2] mat; limits of the wind farm area (must not be the
%                             same as the wind field!)
%
%   Pow         := Struct;    All data related to the power calculation
%    .eta       := double;    Efficiency of the used turbine
%    .p_p       := double;    cos(yaw) exponent for power calculation 
%
%   VCtCp       := [nx3];     Wind speed to Ct & Cp mapping
%                               (Only used by controller script)
%
%   chain       := Struct;    Data related to the OP management / chains
%    .NumChains := int;       Number of Chains per turbine
%    .Length    := int/[nx1]; Length of the Chains - either uniform for all
%                             chains or individually set for every chain.
% ======================================================================= %
%% Default variables
% Observation Point data
ChainLength     = 200;      % OPs per chain
NumChains       = 50;       % Chains per turbine

%% Code to use varargin values
% function(*normal in*,'var1','val1','var2',val2[numeric])
if nargin>1
    %varargin is used
    for i=1:2:length(varargin)
        %go through varargin which is build in pairs and assign variable
        %stored in the first entry with the value stored in the second
        %entry.
        if isnumeric(varargin{i+1})
            %Value is a number -> for 'eval' a string is needed, so convert
            %num2str
            eval([varargin{i} '=' num2str(varargin{i+1}) ';']);
        else
            %Value is a string, can be used as expected
            stringVar=varargin{i+1}; %#ok<NASGU>
            eval([varargin{i} '= stringVar;']);
            clear stringVar
        end
    end
end

%%
switch layout
    case 'oneDTU10MW'
        % Nine DTU 10MW turbines in a 3x3 grid positioned with 900m
        % distance. 
        T_Pos = [...
            500  500  119 178.4]; 
        
        fieldLims = [0 0; 1000 1000];
        
        Pow.eta     = 1.08;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCpCt_10MW_SOWFA.mat');
    case 'twoDTU10MW'
        % Two DTU 10MW Turbines 
        T_Pos = [400 500 119 178.4;...
            1300 500 119 178.4];
        
        fieldLims = [0 0; 2000 1000];
        
        Pow.eta     = 1.126;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCpCt_10MW_SOWFA.mat');
        
        % 
        ChainLength = [ones(NumChains,1)*120;ones(NumChains,1)*45];   
    case 'threeDTU10MW'
        D = 178.4;
        % Three DTU 10MW Turbines 
        T_Pos = [...
            1500-5*D 1500 119 D;...
            1500 1500 119 D;...
            1500+5*D 1500 119 D];
        
        fieldLims = [0 0; 3000 3000];
        
        Pow.eta     = 0.8572; %8.2m/s %1.126; % 8m/s %1.08;     %Def. DTU 10MW
        Pow.p_p     = 2.2;%1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCpCt_10MW_SOWFA.mat');
        
        % Chain lengths should be sufficient for 9m/s
        ChainLength = [...
            ones(NumChains,1)*100;...
            ones(NumChains,1)*80;...
            ones(NumChains,1)*40];
    case 'fourDTU10MW'
        T_Pos = [...
            600  600  119 178.4;...     % T0
            1500 600  119 178.4;...     % T1
            600  1500 119 178.4;...     % T2
            1500 1500 119 178.4;...     % T3
            ]; 
        
        fieldLims = [0 0; 2100 2100];
        
        Pow.eta     = 1.08;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCpCt_10MW_SOWFA.mat');
    case 'nineDTU10MW'
        % Nine DTU 10MW turbines in a 3x3 grid positioned with 900m
        % distance. 
        T_Pos = [...
            600  2400 119 178.4;...     % T0
            1500 2400 119 178.4;...     % T1
            2400 2400 119 178.4;...     % T2
            600  1500 119 178.4;...     % T3
            1500 1500 119 178.4;...     % T4
            2400 1500 119 178.4;...     % T5
            600  600  119 178.4;...     % T6
            1500 600  119 178.4;...     % T7
            2400 600  119 178.4;...     % T8
            ]; 
        
        fieldLims = [0 0; 3000 3000];
        
        Pow.eta     = 0.9365;%8;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCpCt_10MW_SOWFA.mat');
    case 'FC_nineINNWIND10MW'
        % Nine DTU 10MW turbines in a 3x3 grid for the Farm Conners
        % project
        T_Pos = [...
            2143.3, 378.2   119 178.3;...     % T0
            3025.9, 1260.8  119 178.3;...     % T1
            3908.4, 2143.3  119 178.3;...     % T2
            1260.8, 1260.8  119 178.3;...     % T3
            2143.3, 2143.3  119 178.3;...     % T4
            3025.9, 3025.9  119 178.3;...     % T5
            278.2,  2143.3  119 178.3;...     % T6
            1260.8, 3025.9  119 178.3;...     % T7
            2143.3, 3908.4  119 178.3;...     % T8
            ]; 
        
        fieldLims = [0 0; 5000 5000];
        
        Pow.eta     = 1.08;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCpCt_10MW_SOWFA.mat');
    case 'FC_threeINNWIND10MW'
        % Three INNWIND 10MW turbines in a 1x3 grid for the Farm Conners
        % project
        T_Pos = [...
            954.5,  954.5   119 178.3;...     % T0
            1584.9, 1584.9  119 178.3;...     % T1
            2152.3, 2278.4  119 178.3;...     % T2
            ]; 
        
        fieldLims = [0 0; 5000 5000];
        
        Pow.eta     = 1.08;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCpCt_10MW_SOWFA.mat');
    case 'FC_oneINNWIND10MW'
        % One INNWIND 10MW turbine for the Farm Conners project
        T_Pos = [...
            954.5 954.5   119 178.3...     % T0
            ]; 
        
        fieldLims = [0 0; 5000 5000];
        
        Pow.eta     = 1.08;     %Def. DTU 10MW
        Pow.p_p     = 1.50;     %Def. DTU 10MW
        
        % Get VCtCp
        load('./TurbineData/VCpCt_10MW_SOWFA.mat');
    otherwise
        error('Unknown scenario, no simulation started');
end
T.pos  = T_Pos(:,1:3); % 1:Dim
T.D    = T_Pos(:,end);
T.yaw  = zeros(length(T.D),1);
T.Ct   = zeros(length(T.D),1);
T.Cp   = zeros(length(T.D),1);
T.P    = ones(length(T.D),1)*5*10^6;
T.bpa  = zeros(length(T.D),1);
T.tsr  = ones(length(T.D),1)*8;
%% Store chain configuration
chain.NumChains = NumChains;
chain.Length    = ChainLength;
end
%% ===================================================================== %%
% = Reviewed: 2020.11.03 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %