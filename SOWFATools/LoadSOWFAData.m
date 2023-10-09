%% ======= Script to read and store SOWFA simulation settings =========== %
% This script reads and stores the data provided by the SOWFA simulations.
% Data considered:
%   nacelleYaw
%       Yaw misalignment of the turbines
%           It is assumed that T0 is aligned with the wind at t=0. SOWFA
%           stores the nacelle yaw as an orientation, while this code only
%           considers misalignment. Therefore we deduct the initial
%           orientation of T0 from all turbine orientation data to arrive
%           at the yaw misalignment.
%   bladePitch & rotorSpeedFiltered
%       FLORIDyn has access to the Ct/Cp tables of the DTU10MW based on the
%       blade pitch and the tip-speed ratio. Using these two files, the
%       code will use the Ct/Cp tables. NOTE these tables are only usable
%       for the DTU 10MW reference turbine - another turbine type has
%       different tables and a comparison will lead to unexpected
%       behaviour.
% ======================================================================= %
%% Check for SOWFA files and load
if exist([file2val 'nacelleYaw.csv'], 'file') == 2
    % Get yaw angle (deg)
    Control.yawSOWFA = importYawAngleFile([file2val 'nacelleYaw.csv']);
    Control.yawSOWFA(:,2) = Control.yawSOWFA(:,2)-Control.yawSOWFA(1,2);
    
else
    error('nacelleYaw.csv file not avaiable, change link and retry')
end

if exist([file2val 'bladePitch.csv'], 'file') == 2
    try
        bladePitch = importYawAngleFile([file2val 'bladePitch.csv']);
    catch
        error(['bladePitch.csv file not correct formatted, search and '...
            'delete "3{" and "}"'])
    end
    if exist([file2val 'rotorSpeedFiltered.csv'], 'file') == 2
        tipSpeed = importYawAngleFile([file2val 'rotorSpeedFiltered.csv']);
        %  Conversion from rpm to m/s tip speed 
        tipSpeed(:,3) = tipSpeed(:,3)*pi*89.2/30;
    else
        error('rotorSpeedFiltered.csv missing!')
    end
    bladePitch(:,2) = bladePitch(:,2)-bladePitch(1,2);
    tipSpeed(:,2) = tipSpeed(:,2)-tipSpeed(1,2);
    
    load('./TurbineData/Cp_Ct_SOWFA.mat');
    Control.cpInterp = scatteredInterpolant(...
        sowfaData.pitchArray,...
        sowfaData.tsrArray,...
        sowfaData.cpArray,'linear','nearest');
    Control.ctInterp = scatteredInterpolant(...
        sowfaData.pitchArray,...
        sowfaData.tsrArray,...
        sowfaData.ctArray,'linear','nearest');
end

%% ===================================================================== %%
% = Reviewed: 2023.10.09 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker@tudelft.nl                                  = %
% ======================================================================= %