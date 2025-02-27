%
%           _____ _____  ______  
%     /\   / ____|  __ \|  ____| 
%    /  \ | |    | |__) | |__    
%   / /\ \| |    |  _  /|  __|   
%  / ____ \ |____| | \ \| |____  
% /_/    \_\_____|_|  \_\______|

% ACRE - Automated CFD Characterisation for Low Temperature Reaction Kinetics


% MIT License

% Copyright (c) [2023] [Luke Driver (University of Leeds)] 
% email: scldr@leeds.ac.uk - Contact me for questions, troublshooting or if you want any functionaliy added!
% Note this code only works on a linux system and has been primarily made to be run on the HPC.

% You need to have both MATLAB, and Ansys Fluent and ICEM (2022 R1 or later)

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:

% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.

% THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.

% Uses 1D isentropic flow equations to classify a nozzle from its profile
% Code has been tested against the NASA isentropic flow equations toolbox.

Nozzle_Inlet_Radius = 3; % CHANGEME inlet radius (mm)
gamma = 1.64; %CHANGEME ratio of specific heats
Reservoir_Pressure = 5000; % CHANGEME REservoir Pressure (Pa)
Reservoir_Temperature = 300 % CHANGEME in K

AR = Area_Ratio_From_Nozzle(Nozzle_Inlet_Radius);% Calculates Area Ratio
M = Nozzle_Area_to_Mach(AR,gamma); % Calculates Mach number
PR = Pressure_Ratio_from_Mach(gamma,M);
TR = Temperature_Ratio_From_Mach(gamma,M);

disp("Area Ratio = " + AR)
disp("Mach Number= " + M)
disp("Pressure Ratio = " + PR)
disp("Reservoir Pressure (Pa) = " + Reservoir_Pressure)
disp("Nozzle Exit Pressure/Chamber Pressure (Pa) = " + Reservoir_Pressure*PR)
disp("Temperature Ratio = " + TR)
disp("Reservoir Temp (K) = " + Reservoir_Temperature)
disp("Nozzle Exit Temp/Chamber Temp (Pa) = " + Reservoir_Temperature*TR)

Exit_temp = 300*TR


