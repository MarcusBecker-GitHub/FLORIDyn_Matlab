%======= Main script to initialize and start a FLORIDyn simulation =======%
% ------------------------ SOWFA data required! ------------------------- %
% This script may serve as an example on how to prepare and start a       %
% FLORIdyn simulation. This script contains a brief explanation of the    %
% settings. More information about the variables and settings is given in %
% used functions as well as default values.                               %
% ======================================================================= %
% For questions and remarks please contact marcus.becker@tudelft.nl       %
% This code is part of the master thesis of Marcus Becker. The thesis is  %
% avaiable upon request, the results will be published as a paper as soon %
% as possible.                                                            %
% ======================================================================= %
main_addPaths;

%% Set controller type
% Setting for the contoller
% Control.Type:
%   'SOWFA_greedy_yaw'  -> Uses SOWFA yaw angles and a greedy controller
%                           for C_T and C_P based on lookup tables and the 
%                           wind speed (needs additional files)
%   'SOWFA_bpa_tsr_yaw' -> Uses SOWFA yaw angles, blade-pitch-angles and
%                           tip-speed-ratio (needs additional files)
%   'FLORIDyn_greedy'   -> A greedy controller based on lookup tables and 
%                           the wind speed (no additional files)
% 
% Control.init:
%   Set to true if you are starting a new simulation, if you are copying
%   the states from a previous simulation, set to false.

Control.Type = 'SOWFA_greedy_yaw';
Control.init = true;

%% Set path to SOWFA files
% To run this, modify the SOWFA output files to have the ending .csv they
% are expected to be avaiable under i.e. [file2val 'generatorPower.csv']
%
% Two control options are implemented:
%   1) Run greedy control
%       Needed files:
%       'nacelleYaw.csv'
%   2) Calculate Ct and Cp based on blade pitch and tip speed ratio
%       Needed files:
%       'nacelleYaw.csv','generatorPower.csv',
%       'bladePitch.csv','rotorSpeedFiltered.csv'
%       ATTENTION!
%       The SOWFA file 'bladePitch.csv' has to be modified to say
%           0     instead of     3{0}
%       Search & delete all "3{" and "}"
%
% Needed for plotting:
%   'generatorPower.csv'
file2val = '/ValidationData/csv/2T_00_torque_';
LoadSOWFAData;

%% Load Layout
%   Load the turbine configuration (position, diameter, hub height,...) the
%   power constants (Efficiency, p_p), data to connect wind speed and
%   power / thrust coefficient and the configuration of the OP-chains:
%   relative position, weights, lengths etc.
%
%   Currently implemented Layouts
%       'oneDTU10MW'    -> one turbine
%       'twoDTU10MW'    -> two turbines at 900m distance
%       'nineDTU10MW'   -> nine turbines in a 3x3 grid, 900m dist.
%       'threeDTU10MW'  -> three turbines in 1x3 grid, 5D distance
%       'fourDTU10MW'   -> 2x2 grid 
%  
%   Chain length & the number of chains can be set as extra vars, see 
%   comments in the function for additional info.
[T,fieldLims,Pow,VCpCt,chain] = loadLayout('twoDTU10MW');

%% Load the environment
%   U provides info about the wind: Speed(s), direction(s), changes.
%   I does the same, but for the ambient turbulence, UF hosts constant
%   used for the wind field interpolation, the air density, atmospheric
%   stability etc. The Sim struct holds info about the simulation: Duration
%   time step, various settings. See comments in the function for 
%   additional info.
% 
%   Currently implemented scenarios:
%       'const'                     -> Constant wind speed, direction and 
%                                       amb. turbulence
%       '+60DegChange'              -> 60 degree wind angle change after
%                                       300s (all places at the same time)  
%       'Propagating40DegChange'    -> Propagating 40 degree wind angle
%                                       change starting after 300s
%
%   Numerous settings can be set via additional arguments, see the comments
%   for more info.
[U, I, UF, Sim] = loadWindField('const',... 
    'windAngle',0,...
    'SimDuration',1000,...
    'FreeSpeed',true,...
    'Interaction',true,...
    'posMeasFactor',2000,...
    'alpha_z',0.1,...
    'windSpeed',8,...
    'ambTurbulence',0.06);

%% Visulization
% Set to true or false
%   .online:      Scattered OPs in the wake with quiver wind field plot
%   .Snapshots:   Saves the Scattered OP plots, requires online to be true
%   .FlowField:   Plots the flow field at the end of the simulation
%   .PowerOutput: Plots the generated power at the end of the simulation
%   .Console:     Online simulation progress with duration estimation
%                 (very lightweight, does not require online to be true)
Vis.online      = false;
Vis.Snapshots   = false;
Vis.FlowField   = false;
Vis.PowerOutput = true;
Vis.Console     = true;

%% Create starting OPs and build opList
%   Creates the observation point struct (OP) and extends the chain struct.
%   Here, the distribution of the OPs in the wake is set. Currently the
%   avaiable distributions are:
%   'sunflower'         : Recommended distibution with equal spread of the 
%                           OPs across the rotor plane.
%   '2D_horizontal'     : OPs in two horizontal planes, silightly above and
%                           below hub height
%   '2D_vertical'       : OPs in two vertical planes, right and left of the
%                           narcelle.

[OP, chain] = assembleOPList(chain,T,'sunflower');

%% Running FLORIDyn
[powerHist,OP,T,chain]=...
    FLORIDyn(T,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control);

%% Compare power plot
if Vis.PowerOutput
    % Plotting
    f = figure;
    hold on
    nT = length(T.D);
    % Get SOWFA data if avaiable
    if exist([file2val 'nacelleYaw.csv'], 'file') == 2
        powSOWFA_WPS = importGenPowerFile([file2val 'generatorPower.csv']);
        labels = cell(2*nT,1);
        % =========== SOWFA data ===========
        for iT = 1:nT
            plot(...
                powSOWFA_WPS(iT:nT:end,2)-powSOWFA_WPS(iT,2),...
                powSOWFA_WPS(iT:nT:end,3)/UF.airDen,...
                '-.','LineWidth',1)
            labels{iT} = ['T' num2str(iT-1) ' SOWFA wps'];
        end
    else
        labels = cell(nT,1);
    end
    
    % ========== FLORIDyn data =========
    for iT = 1:length(T.D)
        plot(powerHist(:,1),powerHist(:,iT+1),'LineWidth',1.5)
        labels{end-nT+iT} = ['T' num2str(iT-1) ' FLORIDyn'];
    end
    
    hold off
    grid on
    xlim([0 powerHist(end,1)])
    xlabel('Time [s]')
    ylabel('Power generated [W]')
    title([num2str(nT) ' turbine case, based on SOWFA data'])
    legend(labels)
    % ==== Prep for export ==== %
    % scaling
    f.Units               = 'centimeters';
    f.Position(3)         = 16.1; % A4 line width
    set(gca,'LooseInset', max(get(gca,'TightInset'), 0.04))
    f.PaperPositionMode   = 'auto';
end
%% ===================================================================== %%
% = Reviewed: 2020.12.23 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker@tudelft.nl                                  = %
% ======================================================================= %