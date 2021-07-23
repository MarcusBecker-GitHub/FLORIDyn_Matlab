%% Windspeed estimator test file
% Import rotor speed
file2val    = '/ValidationData/csv/9T_paper_ADM_';
rotorSpeed  = importYawAngleFile([file2val 'rotorSpeedFiltered.csv']);
bladePitch  = importYawAngleFile([file2val 'bladePitch.csv']);
genTorque   = importYawAngleFile([file2val 'generatorTorque.csv']);
nacelleYaw  = importYawAngleFile([file2val 'nacelleYaw.csv']);
nacelleYaw(:,3)    = (270-nacelleYaw(:,3))/180*pi;

nT      = 9;
nSteps  = size(rotorSpeed,1)/nT;
offset  = 200;

%% Init WSE
WSE.V       = ones(nT,1)*8; % Wind speed
WSE.gamma   = 20; %20; %5
WSE.beta    = 40; %40; %0
WSE.omega   = rotorSpeed((1:nT) + nT*(offset-1),3)* pi/30;
WSE.Ee      = ones(nT,1)*0;
WSE.T_prop  = estimator_dtu10mw();
WSE.dt      = rotorSpeed(nT+1,2)-rotorSpeed(1,2);

%% loop
V   = zeros(nSteps,nT+1);
Ee  = zeros(nSteps,nT);
om  = zeros(nSteps,nT);
oM  = zeros(nSteps,nT);

for i = offset:nSteps
    Rotor_Speed = rotorSpeed((1:nT) + nT*(i-1),3);
    Blade_pitch = bladePitch((1:nT) + nT*(i-1),3);
    Gen_Torque  = genTorque((1:nT) + nT*(i-1),3);
    yaw         = nacelleYaw((1:nT) + nT*(i-1),3);
    yaw = zeros(size(yaw));
    
    [V_out,WSE] = ...
        WindSpeedEstimatorIandI_FLORIDyn(...
        WSE, Rotor_Speed, Blade_pitch, Gen_Torque,yaw);
    V(i,2:nT+1) = V_out';
    V(i,1) = rotorSpeed(nT*(i-1)+2,2);
    Ee(i,:) = WSE.Ee';
    om(i,:) = WSE.omega';
    oM(i,:) = Rotor_Speed' * pi/30;
end
figure
t = V(offset:end,1);
subplot(3,1,1)
hold on
m = mean(V(offset:end,2:end),2);
s = std(V(offset:end,2:end),[],2);

fill([t; flipud(t)],...
    [(m - s);flipud((m+s))],...
    0.6*[1 1 1],'EdgeColor','none','FaceAlpha',0.5);
plot(t,m)
% for iT = 1:nT
%     plot(V(offset:end,1),V(offset:end,iT+1))
% end
grid on
title('U_{rotor}')
hold off

subplot(3,1,2)
hold on
m = mean(om(offset:end,:),2);
s = std(om(offset:end,:),[],2);
fill([t;flipud(t)],...
    [m + s; flipud(m - s)],...
    0.6*[1 1 1],'EdgeColor','none','FaceAlpha',0.5);
plot(t,m)

m = mean(oM(offset:end,:),2);
s = std(oM(offset:end,:),[],2);
fill([t;flipud(t)],...
    [m + s; flipud(m - s)],...
    0.6*[1 1 1],'EdgeColor','none','FaceAlpha',0.5);
plot(t,m)
legend('','Estimated','','Measured')
% for iT = 1:nT
%     plot(V(offset:end,1),om(offset:end,iT))
%     plot(V(offset:end,1),oM(offset:end,iT))
% end
grid on
title('\omega estimator and measured')
hold off

subplot(3,1,3)
hold on
m = mean(Ee(offset:end,:),2);
s = std(Ee(offset:end,:),[],2);
fill([t;flipud(t)],...
    [m + s; flipud(m - s)],...
    0.6*[1 1 1],'EdgeColor','none','FaceAlpha',0.5);
plot(t,m)

% for iT = 1:nT
%     plot(V(offset:end,1),Ee(offset:end,iT))
% end
grid on
title('Ee')
hold off