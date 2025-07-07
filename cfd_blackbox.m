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

function cfd_blackbox(Solution_Folder, CPU_Cores, Ansys_Version, Tin, Tout, Pin,Pout,Bath_Gas, Reactor_Length, Reactor_Radius, ...
    Reservoir_Radius,Reservoir_Length, Reservoir_Inlet_Diameter, Outlet_Diameter, Outlet_Position,Contour,Y_Sampling_Length, Solver_Type, Mesh_Density_Factor, Pseudo_Transient_Timescale_Factor, ...
    CFD_Iterations,Y_Sampling_Resolution)

%% Setting up folders and using nozzle data (do not touch)
    
    currentFolder = pwd;
    Nozzle_Profile = readmatrix("NozzleProfileFormatted.txt");
    Nozzle_Length = max(Nozzle_Profile(:,1));
    Nozzle__Outlet_Radius = max(Nozzle_Profile(:,2));
    Throat_Radius = min(Nozzle_Profile(:,2));
    Nozzle_Inlet_Radius = (Nozzle_Profile(1,2));
    
    %% User defined variables
    
    %Solution_Folder = 'Ar_90K_A_THIN_Run_19_CFD_Bham'; % Set the Foldername you want your data saved to - Make sure it represents your nozzle and conditions
    %CPU_Cores = 40; % Make sure this matches number of cores on your computer (hyper threading doesnt really increase performance). 
    %Ansys_Version = 2; % 0 = 2021R2 , 1 = 2022R1, 2  = 2023R1
    
    % Define the inlet/outlet conditions 
    %Tin = 295; % Inlet Temp BC (K) - Reservoir Temp
    %Tout = 295; % Outlet Temp BC (K) - Vaccum Line Temperature (same as reservoir usually)
    %Pin = 5584; % Inlet Pressure BC (Pa) 133.33 Pa = 1 torr - Reservoir Pressure
    %Pout = 37.50; % Outlet Pressure BC (Pa) - Vaccum Pressure
    PR = Pin/Pout; % Pressure Ratio of System.
    %Bath_Gas = 0 ; % Nitrogen (N2) = 0, Helium (He) = 1, Argon(Ar) = 2.
    
    % Reactor Dimensions
    % Leeds - 120mm Radius, 774mm Length, Res = 10mm x 10mm, 2.94mm inlet - Taken from CAD.
    % Bham - 198.2mm Radius, 1000mm Length, Res = 18.5mm x 23 m, 4mm inlet - Taken from CAD and conservation with Theo
    % Reservoir/Nozzle is at the left most part of the reactor in CFD.
    
    
    % Please ensure that your nozzle inlet radius = reservoir radius!
    %Reactor_Length = 1000; %mm
    %Reactor_Radius = 198.2; %mm
    %Reservoir_Radius = 18.5; %mm
    %Reservoir_Length = 23; %mm
    %Reservoir_Inlet_Diameter = 4; %mm (0.116 inch as described in Taylor et al 2008). Code assumes inlet is in the center of reservoir
    %Note that the outlet position and outlet diameter makes a negligable difference on results
    %Outlet_Diameter = 150; %mm 
    %Outlet_Position = 875; %mm % This is the position of the outlet from the left most wall
    
    % NOTE: DO NOT CHANGE ANYTHING BELOW.
    
    mkdir(Solution_Folder)

    if Contour == 1
	mkdir([Solution_Folder, '/Contour_Data'])
    end

    mkdir('Meshing')
    %% These are to calculate the axisymmetric outlet
    OA = pi*(Outlet_Diameter/2)^2; % Outlet Area
    Axisymmetric_Outlet_Size = OA/(pi* (Reactor_Radius*2));
    Top_Wall_Length = Reactor_Length - Reservoir_Length - Nozzle_Length;
    
    % Note that the outlet is placed in the center of the reservoir.
    % finds fraction of outlet position for meshing script
    Fraction1 = 1 - ((Outlet_Position - Nozzle_Length - Reservoir_Length) /Top_Wall_Length);
    Fraction2 = 1 - (((Outlet_Position - Nozzle_Length - Reservoir_Length) + (Axisymmetric_Outlet_Size))/Top_Wall_Length);
    
    % finds fraction of inlet position for meshing script
    ResFrac1 = ((Reservoir_Length/2) - 0.5*Reservoir_Inlet_Diameter)/Reservoir_Length;
    ResFrac2 = ((Reservoir_Length/2) + 0.5*Reservoir_Inlet_Diameter)/Reservoir_Length;
    
    
    % This outputs the options set in this code to a file named variable output, please double check this file before you use the results.
    CreateStruct.Interpreter = 'tex';
    CreateStruct.WindowStyle = 'non-modal';
    
    variableString = sprintf(['Double check these conditions are correct:\n\n', ...
        'Number of CPU Cores= %d\n', ...
        'Name of Solution Folder: %s\n', ...
        'Nozzle Length= %.2f mm\n', ...
        'Nozzle Inlet Radius= %.2f mm\n', ...
        'Nozzle Exit Radius= %.2f mm\n', ...
        'Throat Radius= %.2f mm\n', ...
        '\n', ...
        'Inlet Temp= %.2f K\n', ...
        'Outlet Temp= %.2f K\n', ...
        'Inlet Pressure= %.2f Pa\n', ...
        'Outlet Pressure= %.2f Pa\n', ...
        'Pressure Ratio (Pin/Pout)= %.2f\n', ...
        'Bath Gas= %d       Nitrogen = 0, Helium - 1, Argon = 2 \n', ...
        '\n', ...
        'Reactor Length= %.2f mm\n', ...
        'Reactor Radius= %.2f mm\n', ...
        'Reservoir Length= %.2f mm\n', ...
        'Reservoir Radius= %.2f mm\n', ...
        'Outlet Diameter= %.2f mm\n', ...
        'Outlet Position= %.2f mm\n', ...
        '\n'], ...
        CPU_Cores, Solution_Folder, Nozzle_Length, Nozzle_Inlet_Radius, Nozzle__Outlet_Radius, Throat_Radius, ...
        Tin, Tout, Pin, Pout, PR, Bath_Gas, Reactor_Length, Reactor_Radius, ...
        Reservoir_Length, Reservoir_Radius, Outlet_Diameter, Outlet_Position);
    
    % Specify the file name
    OutputFile = [Solution_Folder, '/', 'variable_output.txt'];
    ErrorFile = [Solution_Folder, '/', 'error_file.txt'];
    
    % Write the string to a text file
    fileID_Output = fopen(OutputFile, 'w');
    fprintf(fileID_Output, variableString);
    fclose(fileID_Output);
    
    % Error handling, these output the error message to an errorfile, which can be opened to view the issue.
    if Nozzle__Outlet_Radius > Reactor_Radius
        fileID_Error = fopen(ErrorFile, 'w');
        fprintf(fileID_Error, "Your Nozzle Radius cannot be larger than your reactor radius! Something has gone wrong you need to double check your units/dimensions!!");
        fclose(fileID_Error);
	    return
    end	
    
    if Nozzle_Length > Reactor_Length
        fileID_Error = fopen(ErrorFile, 'w');
        fprintf(fileID_Error, "Your Nozzle Length cannot be larger than your reactor length! Something has gone wrong!!");
        fclose(fileID_Error);
	    return
    end
    
    if (Outlet_Position + 0.5*Axisymmetric_Outlet_Size) > Reactor_Length
        fileID_Error = fopen(ErrorFile, 'w');
        fprintf(fileID_Error, "Your Outlet is not inside your reactor, please change the location!");
        fclose(fileID_Error);
	    return
    end	
    
    if Reservoir_Radius > Nozzle_Inlet_Radius
        ResType = 2;
    elseif Reservoir_Radius < Nozzle_Inlet_Radius
        fileID_Error = fopen(ErrorFile, 'w');
        fprintf(fileID_Error, "Your Reservoir can not be smaller than your nozzle! Change your dimensions!");
        fclose(fileID_Error);
        return
    else
        ResType = 1;
	    
    end
    
    %% This sets the variables in the fluent macro file from user settings. Opens macro file, changes variables and saves.
    if Solver_Type == 1
        FluentScriptFile = 'CFD_Macro.scm'; % pressure based
    elseif Solver_Type == 2
        FluentScriptFile = 'CFD_Macro_DBS.scm'; % Density based
    end

    Fluent_Mesh_File = [currentFolder, '/' Solution_Folder, '\Mesh.msh'];
    Fluent_Mesh_File = strrep(Fluent_Mesh_File, '\', '/');
    Nozzle_Profile_Points = length(Nozzle_Profile(:,1));
    
    if ResType == 1  % This is like Leeds setup, i.e. reservoir is the same size as the nozzle.
        ICEM_Script_File = 'GeoMesh_Macro_Linux.tcl';
    
        % Changes Reactor and Reservoir Size
        ScriptChanger(ICEM_Script_File, 27, ['ic_point {} PNTS pnt.00 ', num2str(-Reservoir_Length), ',' , num2str(Reservoir_Radius), ',', num2str(0)]);
        ScriptChanger(ICEM_Script_File, 28, ['ic_point {} PNTS pnt.01 ', num2str(-Reservoir_Length), ',' , num2str(0), ',', num2str(0)]);
        ScriptChanger(ICEM_Script_File, 29, ['ic_point {} PNTS pnt.02 ', num2str(Reactor_Length-Reservoir_Length), ',' , num2str(0), ',', num2str(0)]);
        ScriptChanger(ICEM_Script_File, 30, ['ic_point {} PNTS pnt.03 ', num2str(Reactor_Length-Reservoir_Length), ',' , num2str(Reactor_Radius), ',', num2str(0)]);
        ScriptChanger(ICEM_Script_File, 31, ['ic_point {} PNTS pnt.04 ', num2str(Nozzle_Length), ',' , num2str(Reactor_Radius), ',', num2str(0)]);
        
        % Change points to account for number of points in XY file
        ScriptChanger(ICEM_Script_File,106, ['ic_hex_split_grid 41 19 pnt', num2str(Nozzle_Profile_Points - 1), ' m PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN'])
        ScriptChanger(ICEM_Script_File,109, ['ic_hex_split_grid 11 13 pnt', num2str(Nozzle_Profile_Points - 1), ' m PNTS FLUID RESERVOIR_WALL INLET NOZZLE_WALL LEFT_REACTOR_WALL TOP_REACTOR_WALL OUTLET RIGHT_REACTOR_WALL AXIS VORFN'])
        ScriptChanger(ICEM_Script_File,116, ['ic_hex_move_node 61 pnt', num2str(Nozzle_Profile_Points - 1)])
        ScriptChanger(ICEM_Script_File, 48, ['ic_curve point CRVS crv.05 {pnt.04 pnt', num2str(Nozzle_Profile_Points -1), '}']);
    
        % Changes Reactor and Reservoir size
        ScriptChanger(ICEM_Script_File, 56, ['ic_point crv_par PNTS pnt.08 {crv.04 ', num2str(Fraction1), '}']);
        ScriptChanger(ICEM_Script_File, 57, ['ic_point crv_par PNTS pnt.09 {crv.04 ', num2str(Fraction2), '}']);
        ScriptChanger(ICEM_Script_File, 58, ['ic_point crv_par PNTS pnt.06 {crv.00 ', num2str(ResFrac1), '}']);
        ScriptChanger(ICEM_Script_File, 59, ['ic_point crv_par PNTS pnt.07 {crv.00 ', num2str(ResFrac2), '}']);
        
        % change mesh density factor
        ScriptChanger(ICEM_Script_File, 157, ['set nodevalue1 [expr ($edgelength1 *' , num2str(Mesh_Density_Factor*8.49),')]']);
        ScriptChanger(ICEM_Script_File, 160, ['set nodevalue2 [expr ($edgelength2 *' , num2str(Mesh_Density_Factor*8.16),')]']);
        ScriptChanger(ICEM_Script_File, 163, ['set nodevalue3 [expr ($edgelength3 *' , num2str(Mesh_Density_Factor*7.179),')]']);
        ScriptChanger(ICEM_Script_File, 166, ['set nodevalue4 [expr ($edgelength4 *' , num2str(Mesh_Density_Factor*2.236),')]']);
        ScriptChanger(ICEM_Script_File, 169, ['set nodevalue5 [expr ($edgelength5 *' , num2str(Mesh_Density_Factor*1.1254),')]']);
        ScriptChanger(ICEM_Script_File, 172, ['set nodevalue6 [expr ($edgelength6 *' , num2str(Mesh_Density_Factor*0.880),')]']);
        ScriptChanger(ICEM_Script_File, 175, ['set nodevalue7 [expr ($edgelength7 *' , num2str(Mesh_Density_Factor*10),')]']);
        ScriptChanger(ICEM_Script_File, 178, ['set nodevalue8 [expr ($edgelength8 *' , num2str(Mesh_Density_Factor*2.6948),')]']);
        
        if Ansys_Version == 0 % 2021 R2
            ScriptChanger(ICEM_Script_File, 256, ['ic_exec /apps/applications/ansys/2021R2/1/default/v212/icemcfd/linux64_amd/icemcfd/output-interfaces/fluent6 -dom $script_dir/Meshing/project1.uns -b $script_dir/Meshing/project1.fbc -dim2d $script_dir/' Solution_Folder '/Mesh']);
            ScriptChanger(ICEM_Script_File, 262, ['ic_reports_write_mesh_report All $script_dir/', Solution_Folder, '/mesh_report.html -format HTML -mesher {ICEM CFD 2021 R2} -title {mesh_report mesh report} -user USER -write_quality All -write_quality_all __NONE__ -write_summary All -write_diagnostics All']);
        
        elseif Ansys_Version == 1 % 2022R1
            ScriptChanger(ICEM_Script_File, 256, ['ic_exec /apps/applications/ansys/2022R1/1/default/v221/icemcfd/linux64_amd/icemcfd/output-interfaces/fluent6 -dom $script_dir/Meshing/project1.uns -b $script_dir/Meshing/project1.fbc -dim2d $script_dir/' Solution_Folder '/Mesh']);
            ScriptChanger(ICEM_Script_File, 262, ['ic_reports_write_mesh_report All $script_dir/', Solution_Folder, '/mesh_report.html -format HTML -mesher {ICEM CFD 2022 R1} -title {mesh_report mesh report} -user USER -write_quality All -write_quality_all __NONE__ -write_summary All -write_diagnostics All']);
        
        elseif Ansys_Version == 2 % 2023R1
            ScriptChanger(ICEM_Script_File, 256, ['ic_exec /opt/apps/pkg/applications/ansys/2023R2/v232/icemcfd/linux64_amd/icemcfd/output-interfaces/fluent6 -dom $script_dir/Meshing/project1.uns -b $script_dir/Meshing/project1.fbc -dim2d $script_dir/' Solution_Folder '/Mesh']);
            ScriptChanger(ICEM_Script_File, 262, ['ic_reports_write_mesh_report All $script_dir/', Solution_Folder, '/mesh_report.html -format HTML -mesher {ICEM CFD 2023 R1} -title {mesh_report mesh report} -user USER -write_quality All -write_quality_all __NONE__ -write_summary All -write_diagnostics All']);
        end
        
    elseif ResType == 2 % This is like Bhams setup i.e. reservoir is larger than nozzle inlet.
        ICEM_Script_File = 'GeoMesh_Macro_Linux_2.tcl';
	    
	    % Changes Reactor and Reservoir Size
	    ScriptChanger(ICEM_Script_File, 20, ['ic_point {} PNTS pnt.00 ', num2str(0), ',' , num2str(Reservoir_Radius), ',', num2str(0)]);
	    ScriptChanger(ICEM_Script_File, 21, ['ic_point {} PNTS pnt.01 ', num2str(-Reservoir_Length), ',' , num2str(Reservoir_Radius), ',', num2str(0)]);
	    ScriptChanger(ICEM_Script_File, 22, ['ic_point {} PNTS pnt.02 ', num2str(-Reservoir_Length), ',' , num2str(0), ',', num2str(0)]);
	    ScriptChanger(ICEM_Script_File, 23, ['ic_point {} PNTS pnt.03 ', num2str(Reactor_Length-Reservoir_Length), ',' , num2str(0), ',', num2str(0)]);
	    ScriptChanger(ICEM_Script_File, 24, ['ic_point {} PNTS pnt.04 ', num2str(Reactor_Length-Reservoir_Length), ',' , num2str(Reactor_Radius), ',', num2str(0)]);
        ScriptChanger(ICEM_Script_File, 25, ['ic_point {} PNTS pnt.05 ', num2str(Nozzle_Length), ',' , num2str(Reactor_Radius), ',', num2str(0)]);
    
        % Change points to account for number of points in XY file
	    ScriptChanger(ICEM_Script_File, 45, ['ic_curve point CRVS crv.06 {pnt.05 pnt', num2str(Nozzle_Profile_Points -1), '}']);
	    ScriptChanger(ICEM_Script_File,78,['ic_hex_split_grid 41 19 pnt', num2str(Nozzle_Profile_Points-1), ' m PNTS CRVS FLUID VORFN'])
        ScriptChanger(ICEM_Script_File, 81, ['ic_hex_split_grid 11 13 pnt', num2str(Nozzle_Profile_Points - 1),' m PNTS CRVS FLUID VORFN'])
        ScriptChanger(ICEM_Script_File,88, ['ic_hex_move_node 61 pnt',num2str(Nozzle_Profile_Points - 1)])
    
	    ScriptChanger(ICEM_Script_File, 50, ['ic_point crv_par PNTS pnt.06 {crv.01	', num2str(ResFrac1), '}']);
        ScriptChanger(ICEM_Script_File, 51, ['ic_point crv_par PNTS pnt.07 {crv.01 ', num2str(ResFrac2), '}']);
        ScriptChanger(ICEM_Script_File, 52, ['ic_point crv_par PNTS pnt.08 {crv.05 ', num2str(Fraction1), '}']);
        ScriptChanger(ICEM_Script_File, 53, ['ic_point crv_par PNTS pnt.09 {crv.05 ', num2str(Fraction2), '}'])

        % Changes mesh density subject to mesh density factor 
        ScriptChanger(ICEM_Script_File, 154, ['set nodevalue1 [expr ($edgelength1 *' , num2str(Mesh_Density_Factor*8.49),')]']);
        ScriptChanger(ICEM_Script_File, 158, ['set nodevalue2 [expr ($edgelength2 *' , num2str(Mesh_Density_Factor*8.16),')]']);
        ScriptChanger(ICEM_Script_File, 162, ['set nodevalue3 [expr ($edgelength3 *' , num2str(Mesh_Density_Factor*7.179),')]']);
        ScriptChanger(ICEM_Script_File, 166, ['set nodevalue4 [expr ($edgelength4 *' , num2str(Mesh_Density_Factor*2.236),')]']);
        ScriptChanger(ICEM_Script_File, 170, ['set nodevalue5 [expr ($edgelength5 *' , num2str(Mesh_Density_Factor*1.1254),')]']);
        ScriptChanger(ICEM_Script_File, 174, ['set nodevalue6 [expr ($edgelength6 *' , num2str(Mesh_Density_Factor*0.880),')]']);
        ScriptChanger(ICEM_Script_File, 178, ['set nodevalue7 [expr ($edgelength7 *' , num2str(Mesh_Density_Factor*10),')]']);
        ScriptChanger(ICEM_Script_File, 182, ['set nodevalue8 [expr ($edgelength8 *' , num2str(Mesh_Density_Factor*2.6948),')]']);
        ScriptChanger(ICEM_Script_File, 186, ['set nodevalue9 [expr ($edgelength9 *' , num2str(Mesh_Density_Factor*5.333),')]']);

	      
        if Ansys_Version == 0 % 2021R2
	        ScriptChanger(ICEM_Script_File, 270, ['ic_exec /apps/applications/ansys/2021R2/1/default/v212/icemcfd/linux64_amd/icemcfd/output-interfaces/fluent6 -dom $script_dir/Meshing/project1.uns -b $script_dir/Meshing/project1.fbc -dim2d $script_dir/' Solution_Folder '/Mesh']);
	        ScriptChanger(ICEM_Script_File, 275, ['ic_reports_write_mesh_report All $script_dir/', Solution_Folder, '/mesh_report.html -format HTML -mesher {ICEM CFD 2021 R2} -title {mesh_report mesh report} -user USER -write_quality All -write_quality_all __NONE__ -write_summary All -write_diagnostics All']);
        elseif Ansys_Version == 1 % 2022R1
	        ScriptChanger(ICEM_Script_File, 270, ['ic_exec /apps/applications/ansys/2022R1/1/default/v221/icemcfd/linux64_amd/icemcfd/output-interfaces/fluent6 -dom $script_dir/Meshing/project1.uns -b $script_dir/Meshing/project1.fbc -dim2d $script_dir/' Solution_Folder '/Mesh']);
	        ScriptChanger(ICEM_Script_File, 275, ['ic_reports_write_mesh_report All $script_dir/', Solution_Folder, '/mesh_report.html -format HTML -mesher {ICEM CFD 2022 R1} -title {mesh_report mesh report} -user USER -write_quality All -write_quality_all __NONE__ -write_summary All -write_diagnostics All']);
        elseif Ansys_Version == 2 % 2023R1
	        ScriptChanger(ICEM_Script_File, 270, ['ic_exec /opt/apps/pkg/applications/ansys/2023R2/v232/icemcfd/linux64_amd/icemcfd/output-interfaces/fluent6 -dom $script_dir/Meshing/project1.uns -b $script_dir/Meshing/project1.fbc -dim2d $script_dir/' Solution_Folder '/Mesh']);
	        ScriptChanger(ICEM_Script_File, 275, ['ic_reports_write_mesh_report All $script_dir/', Solution_Folder, '/mesh_report.html -format HTML -mesher {ICEM CFD 2023 R1} -title {mesh_report mesh report} -user USER -write_quality All -write_quality_all __NONE__ -write_summary All -write_diagnostics All']);
        end
    
    end
    
    
    % Opens mesh file and changes the file name so its opens the correct one.
    ScriptChanger(FluentScriptFile, 1, ['(ti-menu-load-string (format #f "file/read-case', ' ', Fluent_Mesh_File, ' ', 'ok"))']);
    
    % Sets the inlet boundary condition from the inlet variables
    ScriptChanger(FluentScriptFile, 27, ['(ti-menu-load-string (format #f "/define/boundary-conditions/pressure-inlet inlet yes no', ' ', num2str(Pin), ' ', 'no 0 no', ' ', num2str(Tin), ' ', 'no yes no no yes 1 1"))']);
    
    % Sets the outlet boundary condition from the inlet variables
    ScriptChanger(FluentScriptFile, 28, ['(ti-menu-load-string (format #f "/define/boundary-conditions/pressure-outlet outlet yes no', ' ', num2str(Pout), ' ', 'no', ' ', num2str(Tout), ' ', 'no yes no no yes 1 1 yes no no"))']);
    
    % Sets number of itterations and pseudo-time factor
    ScriptChanger(FluentScriptFile, 65, ['(ti-menu-load-string (format #f "/solve/iterate', ' ', num2str(CFD_Iterations), '"))'])
    ScriptChanger(FluentScriptFile, 44, ['(ti-menu-load-string (format #f "/solve/set/pseudo-transient yes yes 1 ', num2str(Pseudo_Transient_Timescale_Factor), ' 0"))' ])

    % Changes the folder where axial plots are saved.
    ScriptChanger(FluentScriptFile, 67, ['(ti-menu-load-string (format #f "/plot plot yes', ' ', Solution_Folder, '/axial_pressure yes no no total-pressure yes 1 0 axis ()"))']);
    ScriptChanger(FluentScriptFile, 68, ['(ti-menu-load-string (format #f "/plot plot yes', ' ', Solution_Folder, '/axial_mach yes no no mach-number yes 1 0 axis ()"))']);
    ScriptChanger(FluentScriptFile, 69, ['(ti-menu-load-string (format #f "/plot plot yes', ' ', Solution_Folder, '/axial_temperature yes no no temperature yes 1 0 axis ()"))']);
    ScriptChanger(FluentScriptFile, 70, ['(ti-menu-load-string (format #f "/plot plot yes', ' ', Solution_Folder, '/axial_density yes no no density yes 1 0 axis ()"))']);
    ScriptChanger(FluentScriptFile, 71, ['(ti-menu-load-string (format #f "/plot plot yes', ' ', Solution_Folder, '/axial_tke yes no no tke yes 1 0 axis ()"))']);
    
    % Changes the folder where the convergence plots are saved
    ScriptChanger(FluentScriptFile, 53, ['(ti-menu-load-string (format #f "/solve/report-files/edit max-mach file-name', ' ', Solution_Folder, '/max-mach-convergence.txt"))']);
    ScriptChanger(FluentScriptFile, 54, ['(ti-menu-load-string (format #f "/solve/report-files/edit min-temp file-name', ' ', Solution_Folder, '/min-temp-convergence.txt"))']);
    
    % Changes the folder name where case and data is saved.
    ScriptChanger(FluentScriptFile, 84, ['(ti-menu-load-string (format #f "/file/write-case', ' ', Solution_Folder, '/CFD_Data.cas y"))']);
    ScriptChanger(FluentScriptFile, 85, ['(ti-menu-load-string (format #f "/file/write-data', ' ', Solution_Folder, '/CFD_Data.dat y"))']);

    %Changes where XY lines for contours are saved
    
    Contour_Line = (Y_Sampling_Length/Y_Sampling_Resolution) + 1; % takes sampling intervals and tells ansys how many lines it needs to make at 0.2mm spacing, i.e. if y = 30 it will make 150 lines.
    a_in_script = 1000/Y_Sampling_Length;
    
    % This just enables or disables the contour data
    if Contour == 1
        ScriptChanger(FluentScriptFile,72, '(do((i 0 (+ i 1)))');
        ScriptChanger(FluentScriptFile,73, ['    ((>= i ',  num2str(Contour_Line), '))']);
        ScriptChanger(FluentScriptFile,74, ['    (define a ', num2str(a_in_script),')']);
        ScriptChanger(FluentScriptFile,75,  ['    (define b i)']);
        ScriptChanger(FluentScriptFile,76,  ['    (define ycoord (/ b a ))'])
        ScriptChanger(FluentScriptFile,77, ['    (ti-menu-load-string (format #f "/surface/rake-surface line_~a ', num2str(Nozzle_Length/1000), ' ~a ',num2str(Reactor_Length/1000), ' ~a 1000" ycoord ycoord ycoord))']);
        ScriptChanger(FluentScriptFile,78, ['    (ti-menu-load-string (format #f "/plot plot yes', ' ' , Solution_Folder, '/Contour_Data/axial_pressure_y_~a yes no no total-pressure yes 1 0 line_~a ()" i ycoord))']);
        ScriptChanger(FluentScriptFile,79, ['    (ti-menu-load-string (format #f "/plot plot yes', ' ' , Solution_Folder, '/Contour_Data/axial_mach_y_~a yes no no mach yes 1 0 line_~a ()" i ycoord))']);
        ScriptChanger(FluentScriptFile,80, ['    (ti-menu-load-string (format #f "/plot plot yes', ' ' , Solution_Folder, '/Contour_Data/axial_temperature_y_~a yes no no temperature yes 1 0 line_~a ()" i ycoord))']);
        ScriptChanger(FluentScriptFile,81, ['    (ti-menu-load-string (format #f "/plot plot yes', ' ' , Solution_Folder, '/Contour_Data/axial_density_y_~a yes no no density yes 1 0 line_~a ()" i ycoord))']);
        ScriptChanger(FluentScriptFile,82, ')');
    elseif Contour == 0
        ScriptChanger(FluentScriptFile,72, ';(do((i 0 (+ i 1)))');
        ScriptChanger(FluentScriptFile,73, ['    ;((>= i ',  num2str(Contour_Line), '))']);
        ScriptChanger(FluentScriptFile,74,  ['    ;(define a ', num2str(a_in_script),')']);
        ScriptChanger(FluentScriptFile,75,  ['    ;(define b i)']);
        ScriptChanger(FluentScriptFile,76,  ['    ;(define ycoord (/ b a ))'])
        ScriptChanger(FluentScriptFile,77, ['    ;(ti-menu-load-string (format #f "/surface/rake-surface line_~a ', num2str(Nozzle_Length/1000), ' ~a ',num2str(Reactor_Length/1000), ' ~a 500" ycoord ycoord ycoord))']);
        ScriptChanger(FluentScriptFile,78, ['    ;(ti-menu-load-string (format #f "/plot plot yes', ' ' , Solution_Folder, '/Contour_Data/axial_pressure_y_~a yes no no total-pressure yes 1 0 line_~a ()" i ycoord))']);
        ScriptChanger(FluentScriptFile,79, ['    ;(ti-menu-load-string (format #f "/plot plot yes', ' ' , Solution_Folder, '/Contour_Data/axial_mach_y_~a yes no no mach yes 1 0 line_~a ()" i ycoord))']);
        ScriptChanger(FluentScriptFile,80, ['    ;(ti-menu-load-string (format #f "/plot plot yes', ' ' , Solution_Folder, '/Contour_Data/axial_temperature_y_~a yes no no temperature yes 1 0 line_~a ()" i ycoord))']);
        ScriptChanger(FluentScriptFile,81, ['    ;(ti-menu-load-string (format #f "/plot plot yes', ' ' , Solution_Folder, '/Contour_Data/axial_density_y_~a yes no no density yes 1 0 line_~a ()" i ycoord))']);
        ScriptChanger(FluentScriptFile,82, ';)');
    end
    
    % Changes the bath gas in the Fluent Script File
    if Bath_Gas == 0 % changes the bath gas to nitrogen as mentioned in the parameter variables. 
        ScriptChanger(FluentScriptFile, 15, '(ti-menu-load-string (format #f "/define/materials/copy fluid nitrogen"))');
        ScriptChanger(FluentScriptFile, 16, '(ti-menu-load-string (format #f "/define/boundary-conditions/fluid fluid yes nitrogen no no no no no no no"))');
        ScriptChanger(FluentScriptFile, 17, '(ti-menu-load-string (format #f "/define/materials delete air"))');
        ScriptChanger(FluentScriptFile, 18, '(ti-menu-load-string (format #f "/define/materials change-create nitrogen nitrogen yes ideal-gas yes piecewise-polynomial 2 0 340 7 1.1863e3 -4.4245 0.0545 -3.4749e-4 1.209e-6 -2.1777e-9 1.5894e-12 340 2000 8 1.0922e3 -0.2679 -2.9022e-5 1.8757e-6 -2.8784e-9 1.905e-12 -6.061e-16 7.595e-20 yes polynomial 8 -0.0014 1.1747e-4 -1.2094e-7 1.3642e-10 -1.0438e-13 5.0045e-17 -1.3416e-20 1.527e-24 yes sutherland three-coefficient-method 1.663e-05 273.11 106.67 no no no"))');
    
    elseif Bath_Gas == 1 % Changes the bath gas to helium
        ScriptChanger(FluentScriptFile, 15, '(ti-menu-load-string (format #f "/define/materials/copy fluid helium"))');
        ScriptChanger(FluentScriptFile, 16, '(ti-menu-load-string (format #f "/define/boundary-conditions/fluid fluid yes helium no no no no no no no"))');
        ScriptChanger(FluentScriptFile, 17, '(ti-menu-load-string (format #f "/define/materials delete air"))');
        ScriptChanger(FluentScriptFile, 18, '(ti-menu-load-string (format #f "/define/materials change-create helium helium yes ideal-gas yes piecewise-linear 5 0 5225 12.17 5206.9 22.177 5197.3 42.177 5194.3 1492.2 5193.2 yes polynomial 8 0.0091 8.0317e-4 -2.0095e-6 4.8453e-9 -6.9467e-12 5.6514e-15 -2.411e-18 4.1848e-22 yes polynomial 8 1.3573e-06 1.0561e-07 -2.9107e-10 7.3974e-13 -1.0916e-15 9.0411e-19 -3.9045e-22 6.837e-26 no no no"))');
    
    
    elseif Bath_Gas == 2 % This changes the bath gas to argon
        ScriptChanger(FluentScriptFile, 15, '(ti-menu-load-string (format #f "/define/materials/copy fluid argon"))');
        ScriptChanger(FluentScriptFile, 16, '(ti-menu-load-string (format #f "/define/boundary-conditions/fluid fluid yes argon no no no no no no no"))');
        ScriptChanger(FluentScriptFile, 17, '(ti-menu-load-string (format #f "/define/materials delete air"))');
        ScriptChanger(FluentScriptFile, 18, '(ti-menu-load-string (format #f "/define/materials change-create argon argon yes ideal-gas yes piecewise-linear 7 0 535.045 103.81 522.53 133.81 521.33 173.81 520.81 243.81 520.53 503.81 520.37 1993.8 520.33 yes polynomial 8 -8.3052e-4 7.8512e-5 -7.0875e-8 6.5431e-11 -4.2832e-14 1.8059e-17 -4.3440e-21 4.5046e-25 yes sutherland three-coefficient-method 2.125e-05 273.11 144.4 no no no"))');
        
    end
            
    %% Opens Ansys ICEM and runs script that makes geometry and mesh for nozzle/reservoir/chamber combo
      ICEM_Log = [Solution_Folder, '/ICEM_Output_Log.txt'];
      fullCommand2 = ['icemcfd -batch -script ', ICEM_Script_File ' >  ' ICEM_Log];
      system(fullCommand2);
    
    % Error handling for meshing file
    if exist(fullfile(Solution_Folder, '/Mesh.msh'), 'file')
         
      else
          fileID_Error = fopen(ErrorFile, 'w');
          fprintf(fileID_Error, 'Something has gone wrong with your mesh creation, please try again! - Check you have properly run the script.');
          fclose(fileID_Error);
          return
    end
    
    %% Opens up Fluent and runs script with initial conditions you set.
    %I could add more setting in the future if chemists like this.
     Fluent_Log = [Solution_Folder, '/Fluent_Output_Log.txt'];
     Fluent_Script = [currentFolder, '/CFD_Macro.scm'];
     fullCommand3 = ['fluent -t ',int2str(CPU_Cores), ' ', '2ddp', ' ', '-g -i', ' ' Fluent_Script ' > ' Fluent_Log];
     system(fullCommand3);
     
    %% Post-processing (will add more in future versions)
    delete('Meshing/*');
    delete('cleanup-fluent*');
    delete('fluent-*');
    delete('core.*');
    delete('ACRE_run.sh.e*');
    delete('ACRE_run.sh.o*');
    delete('tetin_emergency.tin');
    delete('uns_emergency.uns');
    
    axial_temp = readmatrix(Solution_Folder + "/axial_temperature"); axial_temp_data = axial_temp(:,2);
    axial_pressure = readmatrix(Solution_Folder + "/axial_pressure"); axial_pressure_data = axial_pressure(:,2);
    axial_density = readmatrix(Solution_Folder + "/axial_density"); axial_density_data = axial_density(:,2);
    axial_mach = readmatrix(Solution_Folder + "/axial_mach"); axial_mach_data = axial_mach(:,2);
    axial_tke = readmatrix(Solution_Folder + "/axial_tke"); axial_tke_data = axial_tke(:,2);
    axial_temp_data = rmmissing(axial_temp_data); axial_pressure_data = rmmissing(axial_pressure_data);
    axial_density_data = rmmissing(axial_density_data); axial_mach_data = rmmissing(axial_mach_data);
    
    axial_position = axial_temp(:,1) - (Nozzle_Length/1000);
    axial_position = rmmissing(axial_position);
    
    mach_axial_convergence_data = readmatrix(Solution_Folder + "/max-mach-convergence.txt"); 
    temp_axial_convergence_data = readmatrix(Solution_Folder + "/min-temp-convergence.txt");
    itteration_number = mach_axial_convergence_data(:,1);
    mach_axial_convergence = (mach_axial_convergence_data(:,2));
    temp_axial_convergence = (temp_axial_convergence_data(:,2));
    
    Nozzle_exit_index = max(find(abs(axial_position-0)<0.01));

    % use mach number criterion first to find flow length
    mach_number_exit = axial_mach_data(Nozzle_exit_index);
    isentropic_core_criterion1 = 0.95*mach_number_exit;
    isentropic_core_mach_idx = max(find(axial_mach_data > isentropic_core_criterion1));
    isentropic_core_length_criterion1 = axial_position(isentropic_core_mach_idx);

    % use peak of mach number to define if criterion1 is too small...
    TF = islocalmax(axial_mach_data.^10, 'MinProminence',0.01);

    max_mach_at_all_shock_locs = axial_mach_data(TF); % find locations of all shocks
    max_mach_idx_filtered = find(max_mach_at_all_shock_locs > 1); % must be >1

    % max mach of final shocks subject to M >1
    max_mach_filtered_shocks = max_mach_at_all_shock_locs(max(max_mach_idx_filtered));

    % find value in data...
    if length(max_mach_idx_filtered) > 1
        max_mach_loc_in_data_idx = max(find(axial_mach_data == max_mach_filtered_shocks));
        isentropic_core_length_criterion2 = axial_position(max_mach_loc_in_data_idx)
    else
        isentropic_core_length_criterion2 = 0;
    end

    if isentropic_core_length_criterion2 > isentropic_core_length_criterion1
        isentropic_core_length_criterion1 = isentropic_core_length_criterion2;
        isentropic_core_mach_idx = max(find(axial_position < isentropic_core_length_criterion1));
    end

    Flow_Breakdown = axial_position(isentropic_core_mach_idx)*100;
    Flow_Breakdown_Index = isentropic_core_mach_idx;
    % force slightly negative values to be postiive and 0 (as flow length ~0)
    if Flow_Breakdown < 0
        Flow_Breakdown = 0;
    end


    %% Finding the mean, min, max and stddev of stable flow region (same as exp)
    average_temp = mean(axial_temp_data(Nozzle_exit_index:Flow_Breakdown_Index));
    average_density = mean(axial_density_data(Nozzle_exit_index:Flow_Breakdown_Index));
    average_mach= mean(axial_mach_data(Nozzle_exit_index:Flow_Breakdown_Index));
    average_pressure= mean(axial_pressure_data(Nozzle_exit_index:Flow_Breakdown_Index));
    
    min_temp = min(axial_temp_data(Nozzle_exit_index:Flow_Breakdown_Index));
    min_density = min(axial_density_data(Nozzle_exit_index:Flow_Breakdown_Index));
    min_mach= min(axial_mach_data(Nozzle_exit_index:Flow_Breakdown_Index));
    min_pressure= min(axial_pressure_data(Nozzle_exit_index:Flow_Breakdown_Index));
    
    max_temp = max(axial_temp_data(Nozzle_exit_index:Flow_Breakdown_Index));
    max_density = max(axial_density_data(Nozzle_exit_index:Flow_Breakdown_Index));
    max_mach= max(axial_mach_data(Nozzle_exit_index:Flow_Breakdown_Index));
    max_pressure= max(axial_pressure_data(Nozzle_exit_index:Flow_Breakdown_Index));
    
    std_temp = std(axial_temp_data(Nozzle_exit_index:Flow_Breakdown_Index));
    std_density = std(axial_density_data(Nozzle_exit_index:Flow_Breakdown_Index));
    std_mach= std(axial_mach_data(Nozzle_exit_index:Flow_Breakdown_Index));
    std_pressure= std(axial_pressure_data(Nozzle_exit_index:Flow_Breakdown_Index));

    ObjectiveFile = [Solution_Folder, '/', 'Global_Parameters.txt'];
    fileID_Obj_Results = fopen(ObjectiveFile, 'w');
    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Reservoir Pressure (Pa) = ', Pin);
    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Chamber Pressure (Pa) = ', Pout);

    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Standard Deviation of Temperature (K) = ', std_temp);
    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Standard Deviation of Mach Number = ', std_mach);
    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Standard Deviation of Density (kg/m3) = ', std_density);
    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Standard Deviation of Static Pressure (Pa) = ', std_pressure);

    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Average Temperature (K) = ', average_temp);
    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Average Mach Number = ', average_mach);
    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Average Density (kg/m3) = ', average_density);
    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Average Pressure (Pa) = ', average_pressure);

    fprintf(fileID_Obj_Results, '%s \t %d \n' , 'Flow Length (cm) = ', Flow_Breakdown);
    fclose(fileID_Obj_Results);
    
    figure();
    title("Convergence Plots");
    subplot(1,2,1);
    plot(itteration_number, mach_axial_convergence, 'LineWidth',1.5);
    ylabel("Maximum Mach Number (-)");
    xlabel("Itteration Number (-)");
    grid on;
    
    subplot(1,2,2);
    plot(itteration_number, temp_axial_convergence, 'LineWidth',1.5);
    ylabel("Minimum Static Temperature (K)");
    xlabel("Itteration Number (-)");
    grid on;
    
    figure();
    subplot(2,2,1);
    plot(axial_position,axial_temp_data, 'LineWidth',1.5);
    hold on;
    xline(Flow_Breakdown, 'k--', 'LineWidth', 1);
    %hold on;
    %scatter(axial_position(valley_indices_temp), -valleys_temp);
    ylabel("Static Temperature (K)");
    xlabel("Distance From Nozzle Exit (m)");
    grid on;
    ylim([0.8*min_temp 1.2*max_temp]);
    xlim([0 1.3*Flow_Breakdown]);
    text(0.05, 0.95, sprintf('%.3f \x00B1 %.3f%s', average_temp, std_temp, ' K'), 'Units', 'normalized', 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    
    subplot(2,2,2);
    plot(axial_position,axial_mach_data, 'LineWidth',1.5);
    hold on;
    xline(Flow_Breakdown, 'k--', 'LineWidth', 1);
    ylabel("Mach Number");
    xlabel("Distance From Nozzle Exit (m)");
    grid on;
    ylim([0.8*min_mach 1.2*max_mach]);
    xlim([0 1.3*Flow_Breakdown]);
    text(0.05, 0.95, sprintf('%.3f \x00B1 %.3f', average_mach, std_mach), 'Units', 'normalized', 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    
    subplot(2,2,3);
    plot(axial_position,axial_density_data, 'LineWidth',1.5);
    hold on;
    xline(Flow_Breakdown, 'k--', 'LineWidth', 1);
    ylabel("Density (kg/m^{3})");
    xlabel("Distance From Nozzle Exit (m)");
    grid on;
    ylim([0.8*min_density 1.2*max_density]);
    xlim([0 1.3*Flow_Breakdown]);
    text(0.05, 0.95, sprintf('%.3f \x00B1 %.3f%s', average_density, std_density, ' kg/m^3'), 'Units', 'normalized', 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top', 'interpreter','latex');
    
    subplot(2,2,4);
    plot(axial_position,axial_pressure_data, 'LineWidth',1.5);
    hold on;
    xline(Flow_Breakdown, 'k--', 'LineWidth', 1);
    ylabel("Total Pressure (Pa)");
    xlabel("Distance From Nozzle Exit (m)");
    grid on;
    ylim([0.8*min_pressure 1.2*max_pressure]);
    xlim([0 1.3*Flow_Breakdown]);
    text(0.05, 0.95, sprintf('%.3f \x00B1 %.3f%s', average_pressure, std_pressure, ' Pa'), 'Units', 'normalized', 'FontSize', 10, 'FontWeight', 'bold', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    
    saveas(gcf, strcat(Solution_Folder, '/1D_Characterisation.jpg'), 'jpeg');
    saveas(gcf, strcat(Solution_Folder, '/1D_Characterisation.fig'), 'fig');
    
    ResultsFile = [Solution_Folder, '/', '1D_Axial_CFD_Results.txt'];
    fileID__Temp_Results = fopen(ResultsFile, 'w');
    fprintf(fileID__Temp_Results, '%s \t %s \t %s \t %s \t %s \n' , 'X(cm)', 'Mach', 'Static Temp (K)', 'Static Pressure (Pa)', 'Density (kg/m^3)');
    
    for i=1:length(axial_mach_data(:,1))
	    fprintf(fileID__Temp_Results,'%d \t %d \t %d \t %d \t %d \n', axial_position(i)*100,axial_mach_data(i), axial_temp_data(i), axial_pressure_data(i), axial_density_data(i));
    end
    
    fclose(fileID__Temp_Results);

    if Contour == 0
        
    elseif Contour == 1
	mkdir([Solution_Folder, '/Contour_Data'])
        Contour_Files_Folder = ([Solution_Folder, '/Contour_Data']);
        y_interval = 0.01; % y interval in m (0.2mm) (1/5000 in CFD macro)
        all_data_x = []; % Initialize an empty matrix to store x coord data
        all_data_y = []; % Initialize an empty matrix to store y coord data
  
        all_data_t = []; % Initialize an empty matrix to store temperature data
        all_data_m = []; % Initialize an empty matrix to store  mach data
        all_data_p = []; % Initialize an empty matrix to store pressure data
        all_data_d = []; % Initialize an empty matrix to store density data
  


        for i = 1:Contour_Line
            file_name_t = [Contour_Files_Folder, '/axial_temperature_y_', num2str(i - 1)]; 
            data_t = readmatrix(file_name_t); % Read the file with the constructed filename

            file_name_d = [Contour_Files_Folder, '/axial_density_y_', num2str(i - 1)]; 
            data_d = readmatrix(file_name_d); % Read the file with the constructed filename

            file_name_p = [Contour_Files_Folder, '/axial_pressure_y_', num2str(i - 1)]; 
            data_p = readmatrix(file_name_p); % Read the file with the constructed filename

            file_name_m = [Contour_Files_Folder, '/axial_mach_y_', num2str(i - 1)]; 
            data_m = readmatrix(file_name_m); % Read the file with the constructed filename
            
            % setting file data to variable and removing NaNs
            data_x = (data_t(:, 1) - (Nozzle_Length/1000))*100; % nozzle lengh is in mm , data in m
            data_x = rmmissing(data_x);
            y_value = ((i - 1) * y_interval)*100;
            data_y = repmat(y_value, length(data_x), 1); % Using repmat to repeat y_value

            data_t = data_t(:, 2); data_t = rmmissing(data_t);
            data_d = data_d(:, 2); data_d = rmmissing(data_d);
            data_p = data_p(:, 2); data_p = rmmissing(data_p);
            data_m = data_m(:, 2); data_m = rmmissing(data_m);

            all_data_x = [all_data_x;data_x];
	        all_data_y = [all_data_y;data_y];

            all_data_t = [all_data_t;data_t];
            all_data_d = [all_data_d;data_d];
            all_data_p = [all_data_p;data_p];
            all_data_m = [all_data_m;data_m];
        end
    
        % 2D Contour Data
        Temp_Contour_Results_File = [Solution_Folder, '/', '2D_CFD_Data.txt'];
        fileID__Temp_Results = fopen(Temp_Contour_Results_File, 'w');
        fprintf(fileID__Temp_Results, '%s \t %s \t %s \t %s \t %s \t %s \n' , 'X(cm)', ...
            'Y(cm)', 'Static Temperature(K)', 'Density (kg/m3)', 'Static Pressure (Pa)', 'Mach');

        for i = 1:length(all_data_t)
	        fprintf(fileID__Temp_Results,'%d \t %d \t %d \t %d \t %d \t %d \n', all_data_x(i),all_data_y(i), all_data_t(i),all_data_d(i),all_data_p(i),all_data_m(i));
        end
        fclose(fileID__Temp_Results);
     end

end
    %exit;
