%% Simulation preparation

% Online visulization script (1/2)
if Vis.online
    OnlineVis_Start;
end

% Check if field variables are changing over Simulation time
UangVar = size(U.ang,1)>1;
UabsVar = size(U.abs,1)>1;
IVar    = size(I.val,1)>1;
U_ang   = U.ang(1,:);
U_abs   = U.abs(1,:);
I_val   = I.val(1,:);

% Preparing the console output
if Vis.Console
    fprintf(' ============ FLORIDyn Progress ============ \n');
    fprintf(['  Number of turbines  : ' num2str(length(T.D)) '\n']);
    dispstat('','init')
end

% Preallocate the power history
powerHist = zeros(length(T.D),Sim.NoTimeSteps);

if Control.init
    % Set free wind speed as starting wind speed for the turbines
    T.U = getWindVec4(T.pos, U_abs, U_ang, UF);
    T.u = sqrt(T.U(:,1).^2+T.U(:,2).^2);
    T.I_f = zeros(size(T.u));
    T.axi = ones(size(T.u))*1/3;
end

k = 1; % Needed for Controlle Script

nT = length(T.D);
% Set the C_t coefficient for all OPs (otherwise NaNs occur)
ControllerScript;
OP.Ct = T.Ct(OP.t_id);

%% ===================================================================== %%
% = Reviewed: 2020.12.23 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker@tudelft.nl                                  = %
% ======================================================================= %