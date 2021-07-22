function [turbineProperties] = estimator_dtu10mw()
% NEW (information straight from SOWFA):
load('cpInterp_DTU10MW_FAST.mat')

% Define turbine properties
turbineProperties = struct(...
    'GearboxRatio',50.0,... % Gearbox ratio [-]
    'InertiaTotal',1.409969209E+08,... % Total inertia
    'RotorRadius',89.2,... % Rotor radius [m]
    'CpFun',cpInterpolant,... % Cp interpolant for TSR and blade pitch
    'FluidDensity',1.23,...
    'GearboxEff',1); % Fluid density
end