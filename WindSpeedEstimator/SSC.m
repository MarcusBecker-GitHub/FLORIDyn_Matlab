%% SSC EXAMPLE FUNCTION
addpath(genpath('windSpeedEstimator'))

% Setup zeroMQ server
zmqServer = zeromqObj('/home/bmdoekemeijer/OpenFOAM/bmdoekemeijer-2.4.0/jeromq/jeromq-0.4.4-SNAPSHOT.jar',1701,3600,true);

% Load the yaw setpoint LUT and set-up a simple function
nTurbs = 2;

% Initial control settings
torqueArrayOut     = 0.0 *ones(1,nTurbs); % Not used unless 'torqueSC' set in turbineProperties
yawAngleArrayOut   = 270.*ones(1,nTurbs); % Not used unless 'yawSC' set in turbineProperties
pitchAngleArrayOut = 0.0 *ones(1,nTurbs); % Not used unless 'PIDSC' or 'pitchSC' set in turbineProperties

% Setup empty variable
estimatedWindSpeedArray = [];

% Loop initialization
firstRun = true;

% Start control loop
disp(['Entering wind farm controller loop...']);
while 1
    % Receive information from SOWFA
    dataReceived = zmqServer.receive();
    currentTime  = dataReceived(1,1);
    measurementVector = dataReceived(1,2:end); % [powerGenerator[1], torqueRotor[1], thrust[1], powerGenerator[2], torqueRotor[2], thrust[2]]
    
    % Measurements: [genPower,rotSpeedF,azimuth,rotThrust,rotTorque,genTorque,nacYaw,bladePitch]
    generatorPowerArray = measurementVector(1:8:end);
    rotorSpeedArray     = measurementVector(2:8:end);
    azimuthAngleArray   = measurementVector(3:8:end);
    rotorThrustArray    = measurementVector(4:8:end);
    rotorTorqueArray    = measurementVector(5:8:end);
    genTorqueArray      = measurementVector(6:8:end);
    nacelleYawArray     = measurementVector(7:8:end);
    bladePitchArray     = measurementVector(8:8:end);
    
    %% Wind Speed Estimator
    if firstRun
        dt = rem(currentTime,1e3)
        
        % Initialize a wind speed estimator for each turbine
        for ii = 1:nTurbs
            gamma = 5.0;
            rotSpeedInitial = 1.0;
            windSpeedInitial = 7.0;
            WSE{ii} = wsEstimatorImprovedIandI('dtu10mw',dt,gamma,rotSpeedInitial,windSpeedInitial);
        end
        firstRun = false;
    end
    
    % Update wind speed estimator for each turbine
    for ii = 1:nTurbs
        WSE{ii}.update(genTorqueArray(ii), rotorSpeedArray(ii), bladePitchArray(ii));
        disp(['WS of Turbine[' num2str(ii) '] = ' num2str(WSE{ii}.windSpeed) ' m/s.'])
    end
    %% Control
    ...
        
    % Create updated string
    disp([datestr(rem(now,1)) '__    Synthesizing message string.']);
    dataSend = setupZmqSignal(torqueArrayOut,yawAngleArrayOut,pitchAngleArrayOut);
    
    % Send a message (control action) back to SOWFA
    zmqServer.send(dataSend);
    
    % Save variables
    estimatedWindSpeedArray = [estimatedWindSpeedArray; arrayfun(@(ii) WSE{ii}.windSpeed,1:nTurbs)];
    if ~rem(currentTime,10)
        save('workspace.mat')
    end
end

% Close connection
zmqServer.disconnect()

function [dataOut] = setupZmqSignal(torqueSignals,yawAngles,pitchAngles)
	dataOut = [];
    for i = 1:length(yawAngles)
        dataOut = [dataOut torqueSignals(i) yawAngles(i) pitchAngles(i)];
    end
end