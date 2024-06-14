%
%           _____ _____  ______  
%     /\   / ____|  __ \|  ____| 
%    /  \ | |    | |__) | |__    
%   / /\ \| |    |  _  /|  __|   
%  / ____ \ |____| | \ \| |____  
% /_/    \_\_____|_|  \_\______|

% ACRE - Automated CFD Characterisation for Low Temperature Reaction Kinetics


% GNU License

% Copyright (c) [2024] [Luke Driver (University of Leeds)] 
% email: scldr@leeds.ac.uk - Contact me for questions, troublshooting or if you want any functionaliy added!
% Note this code only works on a linux system and has been primarily made to be run on the HPC.

% You need to have both MATLAB, and Ansys Fluent and ICEM (2022 R1 or later)

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program. If not, see <https://www.gnu.org/licenses/>.

% INPUT 
% Nozzle_Inlet_Radius (units in mm)

% OUTPUT AR (Area ratio)

% This scrit calculates the area ratio between the throat and nozzle exit radius

function AR = Area_Ratio_From_Nozzle(Nozzle_Inlet_Radius)
    %Nozzle_Inlet_Radius = 5; % CHANGEME
    nozzle_profile_formatter(Nozzle_Inlet_Radius) 
    nozzle_data = readmatrix("NozzleProfileFormatted.txt") ;
    
    nozzle_x_coords = nozzle_data(:,1); nozzle_y_coords = nozzle_data(:,2); %#ok<*NASGU> 
    Throat_Radius = min(nozzle_y_coords);
    Nozzle_Exit_Radius = nozzle_y_coords(end);
    Throat_Area = pi*Throat_Radius^2;
    Nozzle_Exit_Area = pi*Nozzle_Exit_Radius^2;

    AR = Nozzle_Exit_Area/Throat_Area;
end

