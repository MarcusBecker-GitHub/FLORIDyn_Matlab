function [powerHist,OP,T,chain]=FLORIDyn(T,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control)
% FLORIDyn simulation
% INPUT 
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines    (Allocation)
%    .Ct        := [nx1] vec; Current Ct of the n turbines     (Allocation)
%    .Cp        := [nx1] vec; Current Cp of the n turbines     (Allocation)
%    .P         := [nx1] vec; Power production                 (Allocation)
%
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
%   Sim         := Struct;    Simulation data
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
%    .List      := [nx5] vec; [Offset, start_id, length, t_id, relArea]
%    .dstr      := [nx2] vec; Relative y,z distribution of the chain in the
%                             wake, factor multiplied with the width, +-0.5
% 
%   Vis         := Struct;    What to visualize
%    .online    := bool;      Enable online plotting
%    .Snapshots := bool;      Store scatter plots as pictures (requires
%                             online to be true)
%    .FlowField := bool;      Plots the flow field
%    .PowerOutput := bool;    Plots the power output after the simulation
%    .Console   := bool;      Console output about the simulation state and
%                             progress with time estimation
%
%   Control     := Struct;    Controller related settings and variables
%    .init      := bool;      Initialize turbine states
%    .Type      := String;    Control strategy
%       [If needed]
%    .yawSOWFA  := [n x t+1]vec; [time, yaw T0, yaw T1, ...] 
%    .cpInterp  := scattered interpolant object; C_P as function of bpa/tsr
%    .ctInterp  := scattered interpolant object; C_T as function of bpa/tsr
% ======================================================================= %
% OUTPUT
%   powerHist   := [nx(nT+1)] [Time,P_T0,P_T1,...,]
%                             Stores the time and the power output of the 
%                             turbine at that time
%
%   OP          := Struct;    Data related to the state of the OPs
%    .pos       := [nx3] vec; [x,y,z] world coord. (can be nx2)
%    .dw        := [nx1] vec; downwind position (wake coordinates)
%    .yaw       := [nx1] vec; yaw angle (wake coord.) at the time of creat.
%    .Ct        := [nx1] vec; Ct coefficient at the time of creation
%    .t_id      := [nx1] vec; Turbine OP belongs to
%    .U         := [nx2] vec; Uninfluenced wind vector at OP position
%    .u         := [nx1] vec; Effective wind speed at OP position
%
%   T           := Struct;    All data related to the turbines
%    .pos       := [nx3] mat; x & y positions and nacelle height for all n
%                             turbines.
%    .D         := [nx1] vec; Diameter of all n turbines
%    .yaw       := [nx1] vec; Yaw setting of the n turbines    (Allocation)
%    .Ct        := [nx1] vec; Current Ct of the n turbines     (Allocation)
%    .Cp        := [nx1] vec; Current Cp of the n turbines     (Allocation)
%    .P         := [nx1] vec; Power production                 (Allocation)
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
%   Sim         := Struct;    Data connected to the Simulation
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

%% Preparation for Simulation
%   Script starts the visulization, checks whether the field variables are
%   changing over time, prepares the console progress output and sets
%   values for the turbines and observation points which may not be 0
%   before the simulation starts.
SimulationPrep;

%% Simulation
for k = 1:Sim.NoTimeSteps
    if Vis.Console;tic;end
    
    % Update measurements if they are variable
    if UangVar; U_ang = U.ang(k,:); end
    if UabsVar; U_abs = U.abs(k,:); end
    if IVar;    I_val = I.val(k,:); end
    
    %================= CONTROLLER & POWER CALCULATION ====================%
    % Update Turbine data to get controller input
    T.U = getWindVec4(T.pos, U_abs, U_ang, UF);
    T.I0 = getAmbientTurbulence(T.pos, UF.IR, I_val, UF.Res, UF.lims);
    % Set Ct/Cp and calculate the power output
    ControllerScript;
    
    %================= INSERT NEW OBSERVATION POINTS =====================%
    OP = initAtRotorPlane(OP, chain, T);
    
    %====================== INCREMENT POSITION ===========================%
    % Update wind dir and speed along with amb. turbulence intensity
    OP.U = getWindVec4(OP.pos, U_abs, U_ang, UF);
    
    OP.I_0 = getAmbientTurbulence(OP.pos, UF.IR, I_val, UF.Res, UF.lims);
    
    % Save old position for plotting if needed
    if Vis.online; OP_pos_old = OP.pos;end %#ok<NASGU>
    
    % Calculate the down and crosswind steps along with the windspeed at
    % the turbine rotor planes
    [OP, T]=makeStep2(OP, chain, T, Sim);
    
    % Increment the index of the chain starting entry
    chain.List = shiftChainList(chain.List);
    
    %===================== ONLINE VISULIZATION ===========================%
    if Vis.online; OnlineVis_plot; end
    if and(Vis.FlowField,k == Sim.NoTimeSteps)
        hold off
        PostSimVis;
    end
    
    % Display the current simulation progress
    if Vis.Console;ProgressScript;end
    
end

%% Store power output together with time line
powerHist = [Sim.TimeSteps',powerHist'];
end
%% ===================================================================== %%
% = Reviewed: 2020.12.23 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker@tudelft.nl                                  = %
% ======================================================================= %