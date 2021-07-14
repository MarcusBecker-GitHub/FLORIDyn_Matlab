%% Normalise yaw behaviour in SOWFA and FLORIDyn
% Script to normalise the power produced in one simulation case with
% another one: The first SOWFA case is divided by the second one, so are
% the FLORIDyn simulations. The SOWFA power data is filtered before it is
% combined with the other SOWFA simulation.
file2val_coll = ...
    {'/ValidationData/csv/2T_20_','/ValidationData/csv/2T_00_torque_'};
%{'/ValidationData/csv/3T_pos_y_','/ValidationData/csv/3T_00_'};

%% Prep general FLORIDyn environment
[T,fieldLims,Pow,VCpCt,chain] = loadLayout('twoDTU10MW');
[U, I, UF, Sim] = loadWindField('const',... 
    'windAngle',0,...
    'SimDuration',1000,...
    'FreeSpeed',true,...
    'Interaction',true,...
    'posMeasFactor',2000,...
    'alpha_z',0.11,...
    'windSpeed',8,...
    'ambTurbulence',0.06);
Vis.online      = false;
Vis.Snapshots   = false;
Vis.FlowField   = false;
Vis.PowerOutput = true;
Vis.Console     = true;
[OP, chain] = assembleOPList(chain,T,'sunflower');

%% Run both simulations, norm and yaw
pHist = cell(2,1);
T_basic = T;
for i = 1:2
    file2val = file2val_coll{i};
    LoadSOWFAData;
    [powerHist,~,T,~]=...
        FLORIDyn(T_basic,OP,U,I,UF,Sim,fieldLims,Pow,VCpCt,chain,Vis,Control);
    pHist{i}=powerHist;
end
%% Norm and plot
% SOWFA
S_P_yaw = importGenPowerFile([file2val_coll{1} 'generatorPower.csv']);
S_P_noy = importGenPowerFile([file2val_coll{2} 'generatorPower.csv']);

f = figure;
nT = length(T.D);
%% Design lowpass filter for SOWFA
omega = 0.03;
lp_con = tf([omega^2],[1 2*omega*.7 omega^2]);
lp_dis = c2d(lp_con,.2);
% Cut off initial 30s in SOWFA for filter
iOff = 30/0.2*nT;

for iT = 1:nT
    S_P_yaw_filt = filtfilt(lp_dis.Numerator{1},lp_dis.Denominator{1},...
        S_P_yaw(iOff+iT:nT:end,3)/UF.airDen);
    S_P_noy_filt = filtfilt(lp_dis.Numerator{1},lp_dis.Denominator{1},...
        S_P_noy(iOff+iT:nT:end,3)/UF.airDen);
    S_T = S_P_noy(iOff+iT:nT:end,2)-S_P_yaw(iT,2);
    
    F_P_yaw = pHist{1}(:,iT+1);
    F_P_noy = pHist{2}(:,iT+1);
    F_T = pHist{2}(:,1);
    
    subplot(nT,1,iT)
    plot(S_T,...
        S_P_yaw_filt(1:length(S_P_noy_filt))./S_P_noy_filt,...
        '-.','LineWidth',2)
    hold on
    plot(F_T,F_P_yaw./F_P_noy,'LineWidth',2)
    hold off
    grid on
    xlim([0 F_T(end)])
    xlabel('Time [s]')
    ylabel('Norm. Power [W/W]')
    title(['Norm. Power of T' num2str(iT-1)])
    legend('SOWFA','FLORIDyn')
end
