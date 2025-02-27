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


% This code utilises Ansys ICEM and Ansys Fluent to automate the nozzle characterisation workflow using CFD.
% Code Functionality:
% -> Any Nozzle Geometry can be used, and a code has been included to correctly format the data before this code can run
% -> User can set any boundary condition, this includes lab temperature, reservoir pressure and vaccum pressure
% -> User can set the Bath gas, either nitrogen, helium or argon to view its effect on the wake
% -> Automated scrips have been made which automated the geometry, meshing and solution process to allow chemists to focus on results
% -> The code outputs the 1D axial characterisation profile, which is shown throughout the literature

% Note this only works for nozzles with M<=5 at the moment.

% Below are some performance numbers with varying numbers of cores on ARC4 (550k cells) - Performance is not linear 
% ARC4 system uses an Intel Gold 6138 CPU (Sky Lake) with 192GB of RAM per node (1 node = 40 cores)
% 10 cores - 1.048 s/iteration
% 20 cores - 0.798 s/iteration
% 40 cores - 0.502 s/iteration
% Doubling cores from 10 to 20 is a ~ 25% Performance increase, 10 to 40 is a ~ 50% Performance increase

%% This code allows the user to set multple runs runs and submit to the HPC
%% You can set the chamber and reservoir pressure, although the nozzle has to be the same for every run.
    Solver_Type = 1; % 1 for pressure based, 2 for density based DENSITY BASED TAKES MUCH LONGER and may no converge!!!!!!
    CPU_Cores = 40; % Make sure this matches number of cores on your computer (hyper threading doesnt really increase performance). 
    Ansys_Version = 2; % 0 = 2021R2 , 1 = 2022R1, 2  = 2023R1 2 for Bham
    Mesh_Density_Factor = 1;
    CFD_Iterations = 2000;
    Pseudo_Transient_Timescale_Factor = 0.5;
    %Define the inlet/outlet conditions 
    Tin = 293; % Inlet Temp BC (K) - Reservoir Temp
    Tout = 293 ; % Outlet Temp BC (K) - Vaccum Line Temperature (same as reservoir usually)

    % Put in here what runs you want to do, this can be aslong as you want
    % make sure there is a space between the numbers and a comma between
    % the run names

    % Create a matrix of points for latin hypercube sampling

    Pin = [5222.73]; % Inlet Pressure BC (Pa) 133.33 Pa = 1 torr - Reservoir Pressure
    Pout = [170.65] % Outlet Pressure BC (Pa) - Vaccum/Chamber Pressure
    
    Solution_Folder = {'M2.25_N2_Pres_5222_Pchm_170_IR_5.00mm'}; % Set the Foldername you want your data saved to - Make sure it represents your nozzle and conditions =
    Bath_Gas = 0 ; % Nitrogen (N2) = 0, Helium (He) = 1, Argon(Ar) = 2.
    %Reactor Dimensions
    %Leeds - Taken from CAD.
    %Bham - Taken from CAD and conservation with Theo
    %Reservoir/Nozzle is at the left most part of the reactor in CFD.
    
    %Please ensure that your nozzle inlet radius = reservoir radius!
    Reactor_Length = 1000; %mm -- Bham = 1000mm, Leeds = 774mm
    Reactor_Radius = 198.2; %mm -- Bham = 198.2mm, Leeds = 120mm
    Reservoir_Radius = 18.5; %mm -- Bham = 18.5mm, Leeds = 5mm
    Reservoir_Length = 23; %mm -- Bham= 23mm, Leeds = 10mm
    Reservoir_Inlet_Diameter = 2.93; %mm (0.116 inch as described in Taylor et al 2008). Code assumes inlet is in the center of reservoir 4mm for Bham, 2.94mm for Leeds

    %Note that the outlet position and outlet diameter makes a negligable difference on results
    Outlet_Diameter = 150; %mm % 150mm for Bham and Leeds
    Outlet_Position = 875; %mm % This is the position of the outlet from the left most wall 875mm for Bham, 550mm for Leeds
    
    Contour = 0; % 0 for no contour plot and 1 for 2D contour plot, note 2D contour plot takes a while to output
    Y_Sampling_Length = 30; % This sets the y range for the contour plot in mm. If this is 30, you will get contour data from 0 - 30mm away from the axis.
    Y_Sampling_Resolution = 1; % this will be every 1mm


    %% MAKE SURE YOU CHANGE THIS TO YOUR NOZZLE!!
    nozzle_inlet_radius = 5; % this is your nozzle inlet radius in mm (5mm for leeds nozzles)
    nozzle_profile_formatter(nozzle_inlet_radius) % this formats the nozzle you are interested in

    % Runs the ACRE Framework for all combinations that were set
    for i = 1:length(Solution_Folder)

    % run the CFD blackbox framework with specified settings
       cfd_blackbox(Solution_Folder{i}, CPU_Cores, Ansys_Version,Tin,Tout,Pin(i),Pout(i),Bath_Gas,Reactor_Length,Reactor_Radius, ...
           Reservoir_Radius, Reservoir_Length, Reservoir_Inlet_Diameter,Outlet_Diameter,Outlet_Position,Contour,Y_Sampling_Length,Solver_Type, Mesh_Density_Factor, Pseudo_Transient_Timescale_Factor, ...
           CFD_Iterations,Y_Sampling_Resolution);

    end
