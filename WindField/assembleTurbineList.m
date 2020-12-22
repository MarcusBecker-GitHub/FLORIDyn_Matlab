function [tl_pos,tl_D,tl_ayaw,fieldLims] = assembleTurbineList(layout,varargin)
%assembleTurbineList creates list of turbines with their properties
%   Sets the number, position, height and diameter, but also stores the yaw
%   and axial induction factor of the controller, along with the current
%   Power output
%
% INPUT
%   layout  := to be defined (probably name or id)
%
% OUTPUT
% Turbine Data
%   tl_pos      := [n x 3] vec; [x,y,z] world coord. (can be nx2)
%   tl_D        := [n x 1] vec; Turbine diameter
%   tl_ayaw     := [n x 2] vec; axial induction factor and yaw (world coord.)
%   tl_U        := [n x 2] vec; Wind vector [Ux,Uy] (world coord.)

Dim = 3;             %<--- 2D / 3D change
%% Code to use varargin values
% function(*normal in*,'var1','val1','var2',val2[numeric])
if nargin>1
    %varargin is used
    for i=1:2:length(varargin)
        %go through varargin which is build in pairs and assign variable
        %stored in the first entry with the value stored in the second
        %entry.
        if isnumeric(varargin{i+1})
            %Value is a number -> for 'eval' a string is needed, so convert
            %num2str
            eval([varargin{i} '=' num2str(varargin{i+1}) ';']);
        else
            %Value is a string, can be used as expected
            stringVar=varargin{i+1};
            eval([varargin{i} '= stringVar;']);
            clear stringVar
        end
    end
end
%%
switch layout
    case 'twoDTU10MW'
        T_Pos = [400 500 119 178.4;...
            1300 500 119 178.4];
        fieldLims = [0 0; 2000 1000];
    case 'nineDTU10MW'
        T_Pos = [...
            600  600  119 178.4;...     % T0
            1500 600  119 178.4;...     % T1
            2400 600  119 178.4;...     % T2
            600  1500 119 178.4;...     % T3
            1500 1500 119 178.4;...     % T4
            2400 1500 119 178.4;...     % T5
            600  2400 119 178.4;...     % T6
            1500 2400 119 178.4;...     % T7
            2400 2400 119 178.4;...     % T8
            ]; 
        fieldLims = [0 0; 3000 3000];
    otherwise
        T_Pos = [400 0 119 178.4;...
            1300 0 119 178.4];
        fieldLims = [0 0; 2000 1000];
end

tl_pos  = T_Pos(:,1:Dim);
tl_D    = T_Pos(:,end);
tl_ayaw = zeros(length(tl_D),2);

end

%% NEEDS TO BE FILLED WITH PROPER WINDFARMS