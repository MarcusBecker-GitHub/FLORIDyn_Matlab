function [U, I, UF, Sim] = loadWindField(fieldScenario,varargin)
% LOADWINDFIELD Creates the data necessary for the environment
%   Wind variables like speed and direction are set here, as well as air
%   density, resolution of the interpolation grid. The location of the
%   measurement points are set here, ideally they are in a rectangle.
% ======================================================================= %
% INPUT
%   fieldScenario   := String; Name of the Scenario used for the switch
%                               case below.
%                       'const': Constant wind from an constant angle
%                       '+60DegChange': 60 degree wind direction change 
%                                       after 300s for another 300s.
%
%   varargin        := String,Value: Option to change the value of the 
%                                    default variables.
% --- Var Name -|- Default -|- Explenation ------------------------------ %
% windSpeed     | 8 m/s     | Free wind speed/ starting wind speed
% windAngle     | 0 deg     | Wind direction/ starting wind direction
%               |           | 0  = direction of the x axis
%               |           | 90 = direction of the y axis
% ambTurbulence | 0.06 = 6% | Ambient turbulence intensity
% posMeasFactor | 3000      | The Position of the measurements of the wind
%               |           | speed, angle etc., is determined by this 
%               |           | factor: corners will be at (0,0),(k,0),(0,k),
%               |           | (k,k) with k=posMeasFactor. Can be set in the
%               |           | code for more or different locations.
% uf_res        | [60,60]   | Grid resolution of the field interpolation,
%               |           | first in x direction, then y direction
% alpha_z       | 0         | factor for atmospheric stability, for values
%               |           | >0 the wind speed closer to the ground is
%               |           | reduced. Diabeled for 0.
%               |           | alpha < 0.2 unstable conditions (turbulent)
%               |           | alpha > 0.2 stable conditions (laminar)
% airDen        |1.225kg/m^3| Air density, for SOWFA at 1.225, can be
%               |           | disabled by setting to 1.
% interpMethod  | 'natural' | Method used for field interpolation. other 
%               |           | Options: 'nearest', 'linear'
% SimDuration   | 1000s     | Duration of the Simulation
% TimeStep      | 4s        | Duration of one time step
% FreeSpeed     | true      | Determines if the OPs travel at free speed or
%               |           | at their own effective wind speed.
% WidthFactor   | 6         | Multiplication factor for the sig_y and sig_z
%               |           | of the gaussian function describing the
%               |           | field. 6 -> the OPs get distributed on 6*sig
% z_h           | 119m      | Height of the wind speed measurement
% Interaction   | true      | If activated, the OPs look for foreign wake
%               |           | influences, disabeling dastically decreases
%               |           | simulation time
% redInteraction| true      | If activated, only the OPs at the rotor plane
%               |           | look for foreign influences, otherwise all do
% ======================================================================= %
% OUTPUT
%   U           := Struct;    All data related to the wind
%    .abs       := [txn] mat; Absolute value of the wind vector at the n
%                             measurement points for t time steps. If t=1,
%                             the wind speed is constant.
%    .ang       := [txn] mat; Same as .abs, but for the angle of the vector
%
%   I           := Struct;    All data connected to the ambient turbulence
%    .val       := [txn] mat; Same as U.abs, but for the turbulence
%                             intensity
%    .pos       := [nx2] mat; Measurement positions (same as wind!)
%
%   UF          := Struct;    Data connected to the (wind) field
%    .lims      := [2x2] mat; Interpolation area
%    .IR        := [mxn] mat; Maps the n measurements to the m grid points
%                             of the interpolated mesh
%    .Res       := [1x2] mat; x and y resolution of the interpolation mesh
%    .pos       := [nx2] mat; Measurement positions
%    .airDen    := double;    AirDensity
%    .alpha_z   := double;    Atmospheric stability (see above)
%    .z_h       := double;    Height of the measurement
%
%   Sim
%    .Duration  := double;    Duration of the Simulation in seconds
%    .TimeStep  := double;    Duration of one time step
%    .TimeSteps := [1xt] vec; All time steps
%    .NoTimeSteps= int;       Number of time steps
%    .FreeSpeed := bool;      OPs traveling with free wind speed or own
%                             speed
%    .WidthFactor= double;    Multiplication factor for the field width
%    .Interaction= bool;      Whether the wakes interact with each other
%    .redInteraction = bool;  All OPs calculate their interaction (false)
%                             or only the OPs at the rotor plane (true)
% ======================================================================= %
%% Default variables
% Wind field data
windSpeed       = 8;        % m/s
windAngle       = 0;        % Degree, will be converted in rad
ambTurbulence   = .06;      % in percent
posMeasFactor   = 3000;     % Determines location of measurement points
posMeas         = [0,0;1,0;0,1;1,1]*posMeasFactor;
uf_res          = [20,20];  % resolution across the field [x,y]
alpha_z         = 0;        % factor for height decrease due to 
                            %   atmospheric stability
                            %     0 = a disabled
                            %   0.2 > a unstable conditions (turbulent)
                            %   0.2 < a stable conditions (laminar)
airDen          = 1.225;    % Air density kg/m^3 (SOWFA)
                            % airDen  = 1.1716; %kg/m^3
interpMethod    = 'natural';% Interpolation method for the wind field
% Simulation data
SimDuration     = 1000;     % in s
TimeStep        = 4;        % in s
FreeSpeed       = true;     % bool
WidthFactor     = 6;
z_h             = 119;      % in m
Interaction     = true;     % bool
redInteraction  = true;  % bool
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

%% Derived variables
measPoints  = size(posMeas,1);
timeSteps   = 0:TimeStep:SimDuration;
NoTimeSteps = length(timeSteps);

%% Simulation constants
Sim.Duration    = SimDuration;
Sim.TimeStep    = TimeStep;
Sim.TimeSteps   = timeSteps;
Sim.NoTimeSteps = NoTimeSteps;
Sim.FreeSpeed   = FreeSpeed;
Sim.WidthFactor = WidthFactor;
Sim.Interaction = Interaction;
Sim.reducedInteraction = redInteraction;

%%
switch fieldScenario
    case 'const'
        % Constant wind along the x axis
        % Wind
        U.abs = ones(1,measPoints)*windSpeed;
        U.ang = ones(1,measPoints)*windAngle/180*pi;
        
        % Constant ambient turbulence
        I.val = ones(1,measPoints)*ambTurbulence;
        
    case '+60DegChange'
        % +60 Deg Change after 600s over the next 300s.
        % Two DTU 10MW Turbines 
        
        % Constant wind speed: [1 x m] vector
        U.abs = ones(1,measPoints).*windSpeed;
        
        % Changing angle: [t x m] matrix
        U.ang = ones(NoTimeSteps,measPoints).*windAngle/180*pi;
        I_start = round(600/TimeStep);
        I_dur = round(300/TimeStep);
        changeAng = linspace(0,60/180*pi,I_dur);
        
        % Throw error if the simulation time is set too short
        if I_start+I_dur>NoTimeSteps
            error(['simulation is too short, set SimDuration'...
                ' at least to ' num2str((I_start+I_dur)*TimeStep) 's.'] ...
                )
        end
        
        U.ang(I_start+1:I_start+I_dur,:) = ...
            U.ang(I_start+1:I_start+I_dur,:) + changeAng';
        U.ang(I_start+I_dur+1:end,:) = ...
            U.ang(I_start+I_dur+1:end,:) + changeAng(end);
        U.ang = mod(U.ang,2*pi);
        
        % Constant ambient turbulence
        I.val = ones(1,measPoints)*ambTurbulence;
        
    case 'Propagating40DegChange'
        posMeas = [0,0;2000,0;0,1000;2000,1000];
        
        U.abs = ones(NoTimeSteps,measPoints).*windSpeed;
        
        % Changing angle: [t x m] matrix
        U.ang = ones(NoTimeSteps,measPoints).*windAngle/180*pi;
        I_start = round(300/TimeStep);
        changeAng = linspace(0,40/180*pi,I_start);
        
        % Offset with which the angle changes at the measurement points
        offset = round(60/TimeStep);
        
        % Throw error if the simulation time is set too short
        if 2*I_start+3*offset>NoTimeSteps
            error(['simulation is too short, set SimDuration'...
                ' at least to ' num2str(2*I_start*TimeStep) 's.'] ...
                )
        end
        
        % Apply change to all four measurement points, starting lower-left
        % corner, upper-left, lower-right to top-right. Offset is constant
        % between the m.-points
        U.ang(I_start+1:2*I_start,1) = ...
            U.ang(I_start+1:2*I_start,1) + changeAng';
        
        U.ang(I_start+offset+1:2*I_start+offset,3) = ...
            U.ang(I_start+offset+1:2*I_start+offset,3) + changeAng';
        
        U.ang(I_start+2*offset+1:2*I_start+2*offset,2) = ...
            U.ang(I_start+2*offset+1:2*I_start+2*offset,2) + changeAng';
        
        U.ang(I_start+3*offset+1:2*I_start+3*offset,4) = ...
            U.ang(I_start+3*offset+1:2*I_start+3*offset,4) + changeAng';
        
        % Set the remaining entries to the last value
        U.ang(2*I_start+1:end,1) = ...
            U.ang(2*I_start+1:end,1) + changeAng(end);
        
        U.ang(2*I_start+offset+1:end,3) = ...
            U.ang(2*I_start+offset+1:end,3) + changeAng(end);
        
%         U.ang(2*startI+2*offset+1:end,2) = ...
%             U.ang(2*startI+2*offset+1:end,2) + changeAng(end);
%         
%         U.ang(2*startI+3*offset+1:end,4) = ...
%             U.ang(2*startI+3*offset+1:end,4) + changeAng(end);
   
        % Make sure the angle is in range [0,2pi)
        U.ang = mod(U.ang,2*pi);
        
        % Constant ambient turbulence
        I.val = ones(1,measPoints)*ambTurbulence;
    case 'WindGusts'
        
        
        
    case 'TestWindfield'
        uf_res = [30,15];
        posMeas = [0,0;
            2000,0;
            0,1000;
            2000,1000;
            500,800;
            1800,300;
            800,0;
            1200,1000];
        measPoints = size(posMeas,1);
        v_abs = 10;  %m/s
        v_ang = 6;  %m/s
        U.abs = zeros(NoTimeSteps,measPoints);
        U.ang = zeros(NoTimeSteps,measPoints);
        
        for m = 1:size(posMeas,1)
            U.abs(:,m) = windSpeed + ...
                3*sin(2*pi/4000*(v_abs*timeSteps-posMeas(m,1)));
            U.ang(:,m) = (windAngle + ...
                30*sin(2*pi/2000*(v_ang*timeSteps-posMeas(m,2))))/180*pi;
        end
        I.val = ones(1,measPoints)*ambTurbulence;
    otherwise
        error('Unknown wind conditions, no simulation started')
end
%% Wind field
UF.lims = ...
    [max(posMeas(:,1))-min(posMeas(:,1)),max(posMeas(:,2))-min(posMeas(:,2));...
    min(posMeas(:,1)),min(posMeas(:,2))];

[ufieldx,ufieldy] = meshgrid(...
    linspace(min(posMeas(:,1)),max(posMeas(:,1)),uf_res(1)),...
    linspace(min(posMeas(:,2)),max(posMeas(:,2)),uf_res(2)));

UF.IR = createIRMatrix(posMeas,...
    [fliplr(ufieldx(:)')',fliplr(ufieldy(:)')'],interpMethod);

UF.Res      = uf_res;
UF.alpha_z  = alpha_z;
UF.pos      = posMeas;
UF.airDen   = airDen;
UF.z_h      = z_h;
end
%% ===================================================================== %%
% = Reviewed: 2020.09.28 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %