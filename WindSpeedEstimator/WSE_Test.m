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
V       = zeros(nSteps,nT+1);
offset  = 200;

%% Init WSE
WSE.V       = ones(nT,1)*8; % Wind speed
WSE.gamma   = 20;
WSE.beta    = 40;
WSE.omega   = rotorSpeed((1:nT) + 2*(offset-1),3)* pi/30;
WSE.Ee      = ones(nT,1)*0;
WSE.T_prop  = estimator_dtu10mw();
WSE.dt      = rotorSpeed(nT+1,2)-rotorSpeed(1,2);

%% loop

for i = offset:nSteps
    Rotor_Speed = rotorSpeed((1:nT) + 2*(i-1),3);
    Blade_pitch = bladePitch((1:nT) + 2*(i-1),3);
    Gen_Torque  = genTorque((1:nT) + 2*(i-1),3);
    yaw         = nacelleYaw((1:nT) + 2*(i-1),3);
    yaw = zeros(size(yaw));
    
    [V_out,WSE] = ...
        WindSpeedEstimatorIandI_FLORIDyn(...
        WSE, Rotor_Speed, Blade_pitch, Gen_Torque,yaw);
    V(i,2:nT+1) = V_out';
    V(i,1) = rotorSpeed(2*(i-1)+2,2);
end
figure(2)
hold on
for iT = 1:nT
    plot(V(offset:end,1),V(offset:end,iT+1))
end
grid on