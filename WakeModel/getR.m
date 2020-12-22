function r = getR(op_dw, op_ayaw, op_t_id, tl_D, chainList, cl_dstr)
% GETR calculates the reduction factor of the wind velocity to get the
% effective windspeed based on the eq. u = U*r
%
% INPUT
% OP Data
%   op_dw       := [n x 1] vec; downwind position
%   op_ayaw     := [n x 2] vec; axial induction factor and yaw (wake coord.)
%   op_t_id     := [n x 1] vec; Turbine op belongs to
%
% Chain Data
%   chainList   := [n x 1] vec; (see at the end of the function)
%   cl_dstr     := [n x 1] vec; Distribution relative to the wake width
%
% Turbine Data
%   tl_D        := [n x 1] vec; Turbine diameter

%% Gaussian Wake Model
% Bastankhah and Porté-Angel (2014)
% Abkar and Porté-Angel (2015)
% Niafyifar and Porté-Angel (2015)
% Bastankhah and Porté-Angel (2016)
% Dilip and Porté-Angel (2016)
%
% Equations taken from
%   Design and analysis of a spatially heterogeneous wake
%   Farrell A., King J. et al.
%   eawe 2020, https://doi.org/10.5194/wes-2020-57

%% FLORIS Model
% Gebraad et al (2014)
%========= Turbine Power ===========#
eta = 0.768;
p_p = 1.88;

%========= Expansion ===============#
m_mid = 0;         % introduced
m_en = -0.5;
m_ef = 0.3;
m_em = 1;
k_e = 0.0963;

%========= Velocity ================#
M_Umid = 0.375;    % introduced
M_Un = 0.375;
M_Uf = 1;
M_Um = 5.125;
alpha_U = pi/180 * 5;
beta_U = pi/180 * 1.66;

%% How to get the reduction
op_D = tl_D(op_t_id);
% Step 1: Calculate the filed width at any point in the wake
% D+2*k_e*me_field
fieldWidth = op_D + 2*k_e*m_em*op_dw;

% Step 2: With the width, the crosswind position of the points can be
% calculated
op_c = getChainIDforOP(chainList);
cw = fieldWidth .* cl_dstr(op_c,:); %independet from centerline

% Add centerline. Unfortunately the architecture currently does not allow a
% wake offset, so the wake is made bigger to contain the deflection part.
% Downside of this is, that there are unneccesary points in the wake.
centerline = c_line(op_dw,op_ayaw,op_D);
cw(:,1) = cw(:,1) + ...
    2*centerline.*cl_dstr(op_c,1);

if size(cw,2) == 1
    % 2D
    m_u = get_m_u(op_dw, cw, op_ayaw(:,2), op_D, centerline);
else
    % 3D
    m_u = get_m_u(op_dw, sqrt(sum(cw.^2,2)), op_ayaw(:,2), op_D, centerline);
end


r = 1 - (0.5 + atan(2*op_dw./(pi*op_D)))*2.*op_ayaw(:,1).*...
    (op_D./(op_D + 2*k_e*m_u.*op_dw)).^2;
r(m_u==0) = 1; % (1 = no influence)
end

function op_c = getChainIDforOP(chainList)
% A for loop :(
op_c = zeros(sum(chainList(:,3)),1);
for i = 1:size(chainList,1)-1
    op_c(chainList(i,2):chainList(i+1,2)-1) = i;
end
op_c(chainList(end,2):end)=size(chainList,1);
end

function c_lin = c_line(op_dw,op_ayaw,op_D)
% CENTERLINE CALCULATION

%========= Deflection Constants==============#
k_d = 0.15;
a_d = -4.5;
xi_init = pi/180 * 1.5;

C_T = xi_init + 0.5*cos(op_ayaw(:,2)).^2.*sin(op_ayaw(:,2))*4.*...
    op_ayaw(:,1).*(1-op_ayaw(:,1));
k_x_D = 2*k_d*op_dw./op_D+1;

c_lin = C_T.*(15*k_x_D.^4+C_T.^2)./((30*k_d*k_x_D.^5)./op_D)-...
    C_T.*op_D.*(15+C_T.^2)/(30*k_d) + a_d;
end

function m_u = get_m_u(dw, cw, yaw, D, cl)
%========= Expansion ===============#
m_mid = 0;         % for linear transition
m_en = -0.5;
m_ef = 0.3;
m_em = 1;
k_e = 0.0963;
%========= Velocity ================#
M_Umid = 0.375;    % for linear transition
M_Un = 0.375;
M_Uf = 1;
M_Um = 5.125;
alpha_U = pi/180 * 5;
beta_U = pi/180 * 1.66;


border_up_mf = cl + (0.5*D + k_e*m_em*dw);
border_lw_mf = cl - (0.5*D + k_e*m_em*dw);
border_up_ff = cl + (0.5*D + k_e*m_ef*dw);
border_lw_ff = cl - (0.5*D + k_e*m_ef*dw);
border_up_nf = cl + (0.5*D + k_e*m_en*dw);
border_lw_nf = cl - (0.5*D + k_e*m_en*dw);

M_U = ...
    M_Um * (sign(cw-border_lw_mf)-sign(cw-border_lw_ff))*0.5 + ...
    M_Uf * (sign(cw-border_lw_ff)-sign(cw-border_lw_nf))*0.5 + ...
    M_Un * (sign(cw-border_lw_nf)-sign(cw-border_up_nf))*0.5 + ...
    M_Uf * (sign(cw-border_up_nf)-sign(cw-border_up_ff))*0.5 + ...
    M_Um * (sign(cw-border_up_ff)-sign(cw-border_up_mf))*0.5;

m_u = M_U./cos(alpha_U + beta_U*yaw);
end