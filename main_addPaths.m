%% Add paths
addpath('./WindField')
addpath('./Controller')
addpath('./ObservationPoints')
addpath('./WakeModel')
addpath('./Visulization')
addpath('./TurbineData')
addpath('./Misc')
addpath('./ValidationData')
addpath('./ValidationData/csv')
addpath('./SOWFATools')
addpath('./WindSpeedEstimator')

warning('off','MATLAB:scatteredInterpolant:DupPtsAvValuesWarnId')
warning('off','MATLAB:scatteredInterpolant:InterpEmptyTri2DWarnId')
warning('off','MATLAB:scatteredInterpolant:InterpEmptyTri3DWarnId')

%% ===================================================================== %%
% = Reviewed: 2020.09.30 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker.mail@gmail.com                              = %
% ======================================================================= %