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

%SCRIPTCHANGER
% This script is used to modify the lines in each script file
% It opens up the script file passed into the function, reads the contents
% of the file and changes the line specified into the function. 


function ScriptChanger(ScriptName,ScriptLine, LineChange)
    file_contents = fileread(ScriptName);
    lines = splitlines(file_contents);
    Line = ScriptLine;
    Change = LineChange;
    lines{Line} = Change;
    
    for i = 1:numel(lines)
        lines{i} = char(lines{i});
    end
    
    new_file_contents = strjoin(lines, '\n');
    fid = fopen(ScriptName, 'w');
    fwrite(fid, new_file_contents);
    fclose(fid);
end

