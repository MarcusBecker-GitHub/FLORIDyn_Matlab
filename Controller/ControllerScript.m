%% Controller script
% Modifies T to set C_p and C_t which is then used to calculate the power
% and the wake. If a switch to the axial induction factor is desired, it
% should be implemented here.

yaw = zeros(size(T.yaw));

switch Control.Type
    case 'SOWFA_greedy_yaw'
        % Read yaw of SOWFA Sim (deg)
        for iT = 1:nT
            yaw(iT) = interp1(...
                Control.yawSOWFA(iT:nT:end,2),...
                Control.yawSOWFA(iT:nT:end,3),Sim.TimeSteps(k));
        end
        
        % Yaw conversion SOWFA to FLORIDyn
        yaw = (270*ones(size(yaw))-yaw)/180*pi;
        
        % Calculate Ct and Cp based on the wind speed
        %    Ct is restricted at 1, otherwise complex numbers appear in the FLORIS
        %    equations
        T.Cp    = interp1(VCpCt(:,1),VCpCt(:,2),T.u);
        T.Ct    = min(interp1(VCpCt(:,1),VCpCt(:,3),T.u),0.89);
    case 'SOWFA_bpa_tsr_yaw'
        % Read yaw of SOWFA Sim (deg)
        for iT = 1:nT
            yaw(iT) = interp1(...
                Control.yawSOWFA(iT:nT:end,2),...
                Control.yawSOWFA(iT:nT:end,3),Sim.TimeSteps(k));
        end
        
        % Yaw conversion SOWFA to FLORIDyn
        yaw = (270*ones(size(yaw))-yaw)/180*pi;
        
        % Ct / Cp calculation based on the blade pitch and tip speed ratio
        for iT = 1:nT
            bpa = max(interp1(bladePitch(iT:nT:end,2),bladePitch(iT:nT:end,3),Sim.TimeSteps(k)),0);
            tsr = interp1(tipSpeed(iT:nT:end,2),tipSpeed(iT:nT:end,3),Sim.TimeSteps(k))/T.u(1);
            T.Cp(iT) = Control.cpInterp(bpa,tsr);
            T.Ct(iT) = Control.ctInterp(bpa,tsr);
        end
    case 'FLORIDyn_greedy'
        % Calculate Ct and Cp based on the wind speed
        %    Ct is restricted at 1, otherwise complex numbers appear in the FLORIS
        %    equations
        T.Cp    = interp1(VCpCt(:,1),VCpCt(:,2),T.u);
        T.Ct    = min(interp1(VCpCt(:,1),VCpCt(:,3),T.u),0.89);
        
        % Normal yaw (yaw is defined clockwise)
        yaw = (-yaw)/180*pi;
    case 'MPC'
%         degPerS = 0.5;
%         % Apply yaw, bpa and tsr
%         maxDeg = degPerS*Sim.TimeStep;
%         
%         % will reach bpa
%         wr_bpa = abs(Control.bpa-T.bpa)<maxDeg;
%         T.bpa(wr_bpa)=Control.bpa(wr_bpa);
%         T.bpa(~wr_bpa)=sign(Control.bpa(~wr_bpa)-T.bpa(~wr_bpa))*maxDeg;
%         
%         % will reach yaw
%         wr_yaw = abs(Control.yaw-T.yaw)<maxDeg/180*pi;
%         yaw(wr_yaw)=Control.bpa(wr_yaw);
%         yaw(~wr_yaw)=sign(Control.bpa(~wr_yaw)-T.bpa(~wr_yaw))*maxDeg/180*pi;
%         
%         Ttsr = 12; % Time constant PT1
%         T.tsr = T.tsr + Sim.TimeStep/Ttsr*(Control.tsr-T.tsr);
        
%         % Instant TSR, BPA and Yaw
%         T.tsr = Control.tsr;
%         T.bpa = Control.bpa;
%         yaw = Control.yaw;
%         for iT = 1:nT
%             bpa = T.bpa(iT);
%             tsr = T.tsr(iT);
%             T.Cp(iT) = Control.cpInterp(bpa,tsr);
%             T.Ct(iT) = Control.ctInterp(bpa,tsr);
%         end
    
        % Axial induction factor
        yaw = Control.yaw;
        TConst = 12; % Time constant PT1
        T.axi = Control.axi + Sim.TimeStep/TConst*(Control.axi-T.axi);
        
        T.Ct = 4*T.axi.*(1-T.axi.*cos(yaw));
        T.Cp = 4*T.axi.*(1-T.axi).^2;
        
end

% Set Yaw relative to the wind angle and add offset
T.yaw   = atan2(T.U(:,2),T.U(:,1));
T.yaw   = T.yaw + yaw;

T.Ct = min(T.Ct,ones(size(T.Ct))*0.89);
%% Calculate Power Output
% 1/2*airdensity*AreaRotor*C_P*U_eff^3*cos(yaw)^p_p
T.P = 0.5*UF.airDen*(T.D/2).^2.*pi.*T.Cp.*T.u.^3.* Pow.eta.*...
    cos(T.yaw-atan2(T.U(:,2),T.U(:,1))).^Pow.p_p;

powerHist(:,k)= T.P;

%% ===================================================================== %%
% = Reviewed: 2020.12.23 (yyyy.mm.dd)                                   = %
% === Author: Marcus Becker                                             = %
% == Contact: marcus.becker@tudelft.nl                                  = %
% ======================================================================= %