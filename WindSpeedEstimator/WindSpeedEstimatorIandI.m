function [V, omega_hat] = WindSpeedEstimatorIandI(omega_g,pitch,Pg, Parameters, VI, gamma, Beta, DT)
%% Extended I&I Wind speed estimator
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Reference: 
% Liu Y., Pamososuryo A., Ferrari M.G. R., van Wingerden J.W., 
% The Immersion and Invariance Wind Speed Estimator Revisited and New Results, 
% IEEE Control Systems Letters, 2021.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% The script is made by Yichao Liu in 17/05/2021. %
% Modified by Marcus Becker in 14/07/2021.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
%% Inputs
% omega_g       : Generator speed
% omega (*)     : Estimated rotor speed
% Ee    (*)     : Integrated error between est. rot. speed and measured
% pitch         : Current blade pitch
% Pg            : Power generator
% Parameters    : Parameters used by the I&I estimator
%           .Effic  : Efficiency of the WT (power)
%           .G      : Gear box ratio
%           .J      : Equivalent inertia
%           .rho    : Air density
%           .R      : Turbine rotor radius
%           .Tables         : Turbine specific look up tables 
%           	   .Cp      : Power Coefficient (TSR & Blade pitch)
%                  .TSR     : Resolution of the tip speed ratio
%                  .Pitch   : Resolution of the blade pitch
% VI            : Wind speed input (previous estimate)
% gamma         : Proportional gain (>0)
% Beta          : Integral gain
% DT            : Time step
%
% (*) currently persistent variable
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
persistent omega Ee
%% Initialization
if isempty(omega) 
    omega = omega_g/Parameters.G;
    Ee = 0;
    VI = 5;
end

TSR     = omega_g/Parameters.G*Parameters.R/VI;
[X, Y]  = meshgrid(Parameters.Tables.TSR, Parameters.Tables.Pitch);
Cpp     = max(interp2(X, Y, Parameters.Tables.Cp,...
                        TSR, pitch, 'linear',0),0);

%% Estimation
%1. omegadot = (1/J)*(T_r/N-T_g)
omegadot =-(-1/2 * Parameters.rho * pi * Parameters.R^2 * Cpp * ...
    VI^3 + Pg / Parameters.Effic) / Parameters.J / omega_g * Parameters.G;

%2. estimated omega = integration of omegadot
omega   = omega + omegadot * DT; 

%3. delta_omega = measured omega - omega
diff_omega = -omega + omega_g / Parameters.G;

% 4. Vo = gamma*delta_omega
Vo = gamma * diff_omega;
Ee = Ee + diff_omega * DT;
Vo = Vo + Beta * Ee;

%% Output 
V = Vo;
omega_hat = omega;