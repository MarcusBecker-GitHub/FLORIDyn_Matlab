%======= Main script to initialize and start a FLORIDyn simulation =======%
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
% ========= ! If you intend to use SOWFA data, use mainSOWFA.m ! ======== %
% Control.Type:
%   'SOWFA_greedy_yaw'  -> Uses SOWFA yaw angles and a greedy controller
%                           for C_T and C_P based on lookup tables and the 
%                           wind speed (needs additional files)
%   'SOWFA_bpa_tsr_yaw' -> Uses SOWFA yaw angles, blade-pitch-angles and
%                           tip-speed-ratio (needs additional files)
%   'FLORIDyn_greedy'   -> A greedy controller based on lookup tables and 
%                           the wind speed (no additional files)
%   'AxialInduction'    -> Will use a = 1/3 for all turbines and copies the
%                           yaw angle from Control.yaw (in degree)
% 
% Control.init:
%   Set to true if you are starting a new simulation, if you are copying
%   the states from a previous simulation, set to false.

Control.Type = 'AxialInduction';
Control.init = true;

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
%       Farm Conners Project
%       'FC_oneINNWIND10MW'
%       'FC_threeINNWIND10MW'
%       'FC_nineINNWIND10MW'
%  
%   Chain length & the number of chains can be set as extra vars, see 
%   comments in the function for additional info.
[T,fieldLims,Pow,VCpCt,chain] = loadLayout('threeDTU10MW');

%% Set the yaw angle for all turbines (Farm Connor specific)
% Angle in degree, will be converted to rad
Control.yaw  = T.yaw;
% switch length(T.D)
%     case 1
%         % 1T
%         Control.yaw(1) = 0;
%     case 3
%         % 3T
%         Control.yaw(1) = 0;         % First row
%         Control.yaw(2) = 0;         % Second row
%     case 9
%         % 9T
%         Control.yaw(1:3:end) = 0;   % First row
%         Control.yaw(2:3:end) = 0;   % Second row
% end

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
    'windAngle',45,...
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
Vis.FlowField   = true;
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
    labels = cell(nT,1);
    
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
    title([num2str(nT) ' turbine case'])
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