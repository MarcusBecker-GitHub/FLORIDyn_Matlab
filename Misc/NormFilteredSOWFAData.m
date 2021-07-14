%% Norm SOWFA data
% Get path
path.yaw = '/ValidationData/csv/3T_paper_yaw_dt004_';
path.bl = '/ValidationData/csv/3T_paper_bl_dt004_';
nT = 3;
UF.airDen = 1.225; % SOWFA
%% Load generated data
powSOWFA.yaw    = importGenPowerFile([path.yaw 'generatorPower.csv']);
powSOWFA.bl     = importGenPowerFile([path.bl 'generatorPower.csv']);
%% Design filter for SOWFA
deltaT_SOWFA    = (powSOWFA.yaw(nT+1,2)-powSOWFA.yaw(1,2));
omega           = 0.03;
lp_con          = tf([omega^2],[1 2*omega*.7 omega^2]);
lp_dis_S        = c2d(lp_con,deltaT_SOWFA);
iOff            = round(30/deltaT_SOWFA)*nT;
%% Filter and divide
figure
hold on
for iT = 1:nT
    powSOWFA.Filt_yaw = filtfilt(lp_dis_S.Numerator{1},lp_dis_S.Denominator{1},...
        powSOWFA.yaw(iOff+iT:nT:end,3)/UF.airDen);
    
    powSOWFA.Filt_bl = filtfilt(lp_dis_S.Numerator{1},lp_dis_S.Denominator{1},...
        powSOWFA.bl(iOff+iT:nT:end,3)/UF.airDen);
    % Plot filtered data
    plot(...
        powSOWFA.yaw(iOff+iT:nT:end,2)-powSOWFA.yaw(iT,2),...
        powSOWFA.Filt_yaw./powSOWFA.Filt_bl,...
        '-.','LineWidth',2)
end
hold off
grid on
xlabel('Time [s]')
ylabel('Norm. Power [W W^{-1}]')

%% Norm FLORIDyn
% Save FLORIDyn powerHist for the yawed case in powFLORIDyn.yaw and for the
% Baseline in powFLORIDyn.bl
gcf
hold on
for iT = 1:nT
    
    inOut = ones(2,1).*powFLORIDyn.yaw(2,iT+1);
    initCond = filtic(lp_dis_F.Numerator{1},lp_dis_F.Denominator{1},inOut,inOut);
    % Apply the lowpass filter with initial conditions
    powFLORIDyn.Filt_yaw = filter(lp_dis_F.Numerator{1},lp_dis_F.Denominator{1},...
        powFLORIDyn.yaw(:,iT+1),initCond);
    
    inOut = ones(2,1).*powFLORIDyn.bl(2,iT+1);
    initCond = filtic(lp_dis_F.Numerator{1},lp_dis_F.Denominator{1},inOut,inOut);
    % Apply the lowpass filter with initial conditions
    powFLORIDyn.Filt_bl = filter(lp_dis_F.Numerator{1},lp_dis_F.Denominator{1},...
        powFLORIDyn.bl(:,iT+1),initCond);
    
    plot(powFLORIDyn.yaw(:,1),powFLORIDyn.Filt_yaw./powFLORIDyn.Filt_bl,'LineWidth',2)
end
hold off
