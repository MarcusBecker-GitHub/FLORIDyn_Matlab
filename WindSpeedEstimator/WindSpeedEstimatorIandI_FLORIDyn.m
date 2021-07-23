function [V_out,WSE] = WindSpeedEstimatorIandI_FLORIDyn(WSE, Rotor_Speed, Blade_pitch, Gen_Torque,yaw)
%% Extended I&I Wind speed estimator
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Reference: 
% Liu Y., Pamososuryo A., Ferrari M.G. R., van Wingerden J.W., 
% The Immersion and Invariance Wind Speed Estimator Revisited and New Results, 
% IEEE Control Systems Letters, 2021.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% The script is based on the work of Yichao Liu and Jean Gonzales Silva.
% Modified by Marcus Becker in 22/07/2021.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
%% Inputs
% WSE       : Wind Speed Estimator States and Parameters
%    .Ee    : State - Integrated error between est. rot. speed and measured
%    .V     : State - Estimated wind speed
%    .omega : State - Estimated rotor speed
%    .beta  : Integral gain
%    .gamma : Proportional gain (>0)
%    .T_prop: Turbine properties
%           .gearboxratio   : Gearbox ratio [-]
%           .inertiaTotal   : Total inertia
%           .rotorRadius    : Rotor radius [m]
%           .cpFun          : Cp interpolant for TSR and blade pitch
%           .fluidDensity   : Fluid density
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
%% Import variables from WSE
fluidDensity    = WSE.T_prop.FluidDensity;  % Fluid density [kg/m3]
rotorRadius     = WSE.T_prop.RotorRadius;   % Rotor radius [m]
rotorArea       = pi*rotorRadius^2;         % Rotor swept surface area [m2]
gamma           = WSE.gamma;                % Estimator gain
beta            = WSE.beta;                 % Estimator gain
gbRatio         = WSE.T_prop.GearboxRatio;  % Gearbox ratio
inertTot        = WSE.T_prop.InertiaTotal;  % Inertia
dt              = WSE.dt;                   % Timestep
GBEfficiency    = WSE.T_prop.GearboxEff;    % Gearbox efficiency
p_p = 2.2;
%% Calculate aerodynamic torque
%   Estimated tip speed ratio [-]
tipSpeedRatio   = (Rotor_Speed * pi * rotorRadius)./(WSE.V * 30); 
%   Power coefficient [-]
Cp = max(WSE.T_prop.CpFun(tipSpeedRatio,Blade_pitch),0); 
%   Correct for yaw angle
Cp = Cp.*cos(yaw).^p_p;
%% Estimate wind speed
if isnan(Cp)
    disp(['Cp is out of the region of operation: TSR=' ...
        num2str(tipSpeedRatio) ', Pitch=' num2str(Blade_pitch) ' deg.'])
    disp('Assuming windSpeed to be equal to the past time instant.')
else
    aerodynamicTorque = 0.5 * fluidDensity * rotorArea *...
        ((WSE.V.^3)./(Rotor_Speed* pi/30)) .* Cp; % Torque [Nm]
    
    % Saturate torque to non-negative numbers
    aerodynamicTorque = max(aerodynamicTorque, 0.0); 

    % Update estimator state and wind speed estimate (YICHAO)
    omegadot    = -(GBEfficiency * Gen_Torque * gbRatio - ...
                        aerodynamicTorque)/(inertTot);
    WSE.omega   = WSE.omega + dt*omegadot;
    diff_omega  = - WSE.omega + Rotor_Speed * pi/30;
    WSE.Ee      = WSE.Ee + diff_omega * dt;
    WSE.V       = beta * WSE.Ee + gamma * diff_omega;
end
V_out = WSE.V;
end
