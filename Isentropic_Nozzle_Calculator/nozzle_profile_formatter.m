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

% This script opens a 1D nozzle profile and outputs the correct format
% which can be read into spaceclaim properly.

% This also makes sure nozzle inlet is at x = 0 (for axisymmetric model).

%%%%%% ENSURE units are mm!!!!!!! %%%%%
function nozzle_profile_formatter(nozzle_inlet_radius)
    %nozzle_inlet_radius = 5; % set in mm same as reservoir radius (5mm in this case)
    
    %%
    nozzle_data = readmatrix("nozzle_profile.txt");
    nozzle_data_x = nozzle_data(:,1); nozzle_data_x = rmmissing(nozzle_data_x);
    nozzle_data_y = nozzle_data(:,2); nozzle_data_y = rmmissing(nozzle_data_y);
    
    xpoint_1 = nozzle_data_x(1);
    ypoint_1 = nozzle_data_y(1);
    
    TF = issorted(nozzle_data_x);
    
    if TF == 1
        
    else
        msgbox("Check that your x-coordinates are in order!!","Error","error");
        return;
    end
    
    
    if length(nozzle_data_x) ~= length(nozzle_data_y)
        msgbox("Check Length of X and Y data that has been inputted!!","Error","error");
        return;
    end
    
    if xpoint_1 > 0 
        data_xnew = nozzle_data_x - xpoint_1;
    elseif xpoint_1 < 0
        data_xnew = nozzle_data_x - xpoint_1;
    elseif xpoint_1 == 0
        data_xnew = nozzle_data_x;
        msgbox("X Coordinate In Correct Place (No Action Required)");
       
    end
    
    if ypoint_1 > 0 < nozzle_inlet_radius
        ymove = nozzle_inlet_radius - ypoint_1;
        data_ynew = nozzle_data_y + ymove;
    elseif ypoint_1 < 0
        ymove = ypoint_1 - nozzle_inlet_radius;
        data_ynew = nozzle_data_y - ymove;
    elseif ypoint_1 == nozzle_inlet_radius
        data_ynew = nozzle_data_y;
        msgbox("Y Coordinate In Correct Place (No Action Required)");
    end
    
    
    % figure
    % plot(data_x,data_y, '-*', 'MarkerIndices', 1:20:length(data_x), 'LineWidth',2, 'color', [0.008 0.42 0.27]), hold on
    % plot(data_xnew, data_ynew, '-x', 'MarkerIndices', 1:20:length(data_xnew), 'LineWidth',2, 'color', [0 0.1 0.8])
    % ylim([0 1.1*max(data_ynew)])
    % xlim([0 1.1*max(data_xnew)])
    % ylabel(" y (mm)")
    % xlabel(" m (mm)")
    % grid on
    % yline(0 ,'--', 'LineWidth',2)
    % legend("Original", "Formatted", "Symmetry", 'FontSize',14)
    
    polyline = 'polyline=true';
    
    fileID = fopen("nozzle_profile_f.txt", 'w');
        %fprintf(fileID, '%s\n', polyline);
    fprintf(fileID, '%d \n', length(nozzle_data_x));
    
    for i = 1:length(nozzle_data_x)
        fprintf(fileID, '%.3f %.3f %d \n', data_xnew(i), data_ynew(i), 0);
    end
    
    In = 'nozzle_profile_f.txt';
    Out = 'NozzleProfileFormatted.txt';
    fclose(fileID);
    copyfile(In, Out);
    delete(In);
    delete('nozzle_profile_formatter.asv');
    %msgbox("Formatting Complete!")
end
