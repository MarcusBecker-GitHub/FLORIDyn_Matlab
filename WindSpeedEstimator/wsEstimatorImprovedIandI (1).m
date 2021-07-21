classdef wsEstimatorImprovedIandI < matlab.mixin.Copyable %handle
    %WSESTIMATOR This is the main class of the wsEstimator program
    %   This class is based on the I&I Wind Speed estimator developed by
    %   Ortega et al.
    
    properties
        time
        windSpeed
        rotSpeed
        res
        estimatorProperties
        turbineProperties
    end
    
    methods
        function obj = wsEstimatorImprovedIandI(turbineType,dt,gamma,beta,rotSpeedInitial,windSpeedInitial,Parameters)
            %wsEstimator Construct an instance of this class
            if strcmp(lower(turbineType),'nrel5mw')
                turbineProperties = estimator_nrel5mw();
			elseif strcmp(lower(turbineType),'dtu10mw')
                turbineProperties = estimator_dtu10mw();	
            else
                error('Cannot find properties file for this turbine.')
            end
            
            if nargin < 3
                gamma = 10; % Adaptation gain of the estimator, should be non-negative
				beta = 40;
            end
            if nargin < 5
                rotSpeedInitial = 1.0; % Rotor speed [rad/s]
                windSpeedInitial = 7.5; % Wind speed [m/s]
            end

            % Save to self
            obj.estimatorProperties = struct('dt',dt,'gamma',gamma,'beta',beta);
            obj.turbineProperties = turbineProperties;
          
            % Set initial estimates (wind speed, integrator)
            obj.setInitialValues(rotSpeedInitial,windSpeedInitial);
        end
        
        
        function setInitialValues(obj, rotSpeedInitial, windSpeedInitial)
            % Update wind speed and time
            obj.time = 0;
            obj.windSpeed = windSpeedInitial;
			obj.rotSpeed = rotSpeedInitial;
            
            % Update integrator state
            gamma = obj.estimatorProperties.gamma;
			beta = obj.estimatorProperties.beta;
            %integratorInitial = windSpeedInitial-gamma*rotSpeedInitial;
            integratorInitial = 0;
            obj.estimatorProperties.integratorState = integratorInitial;
        end
        
        
        function update(obj, genTorqueMeasured, rotSpeedMeasured, pitchMeasured)
            % Import variables from obj
            fluidDensity = obj.turbineProperties.fluidDensity; % Fluid density [kg/m3]
            rotorRadius = obj.turbineProperties.rotorRadius; % Rotor radius [m]
            rotorArea = pi*rotorRadius^2; % Rotor swept surface area [m2]
            gamma = obj.estimatorProperties.gamma; % Estimator gain
			beta = obj.estimatorProperties.beta; % Estimator gain
            gbRatio = obj.turbineProperties.gearboxRatio; % Gearbox ratio
            inertTot = obj.turbineProperties.inertiaTotal; % Inertia
            dt = obj.estimatorProperties.dt; % Timestep
            
            % Calculate aerodynamic torque
            tipSpeedRatio = rotSpeedMeasured*rotorRadius/obj.windSpeed; % Estimated tip speed ratio [-]
            Cp = max(obj.turbineProperties.cpFun(tipSpeedRatio,pitchMeasured),0); % Power coefficient [-]
            GBEfficiency=1;
            %YICHAO
            %[X, Y] = meshgrid(obj.turbineProperties.Tables.TSR, obj.turbineProperties.Tables.Pitch);
            %Cpp = max(interp2(X, Y, obj.turbineProperties.Tables.Cp, tipSpeedRatio, pitchMeasured, 'linear',0),0);
            
            if isnan(Cp)
                disp(['Cp is out of the region of operation: TSR=' ...
                    num2str(tipSpeedRatio) ', Pitch=' num2str(pitchMeasured) ' deg.'])
                disp('Assuming windSpeed to be equal to the past time instant.')
            else
                aerodynamicTorque = 0.5*fluidDensity*rotorArea*((obj.windSpeed^3)/rotSpeedMeasured)*Cp; % Torque [Nm]
                aerodynamicTorque = max(aerodynamicTorque, 0.0); % Saturate torque to non-negative numbers
               
				% Update estimator state and wind speed estimate
                %obj.rotSpeed =  obj.rotSpeed - dt*(genTorqueMeasured*gbRatio - aerodynamicTorque)/ inertTot;
                %obj.estimatorProperties.integratorState = obj.estimatorProperties.integratorState - dt*(rotSpeedMeasured-obj.rotSpeed);
                %obj.windSpeed = beta*obj.estimatorProperties.integratorState - gamma*(rotSpeedMeasured-obj.rotSpeed);
                
                % Update estimator state and wind speed estimate (YICHAO)
                %alpha=36.51316; %(k2+k1)/(2*k1*k2) ??? 
                %time-delay e^-sT ??
                omegadot=-(GBEfficiency*genTorqueMeasured*gbRatio - aerodynamicTorque)/(inertTot);
                obj.rotSpeed =  obj.rotSpeed + dt*omegadot;
                obj.res= -obj.rotSpeed+rotSpeedMeasured;
                obj.estimatorProperties.integratorState = obj.estimatorProperties.integratorState + dt*(obj.res);
                obj.windSpeed = (beta*obj.estimatorProperties.integratorState + gamma*(obj.res));
                
            end
            
            % Update time
            obj.time = obj.time + obj.estimatorProperties.dt;
        end
        
    end
end

