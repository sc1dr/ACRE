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

% Calculates the mach number itteratively from the nozzle area ratio
% (isentropic relationships)

function M = Nozzle_Area_to_Mach(area_ratio, gamma)

 % Initial guess and parameters
    Mach_Guess = 1;  % Initial guess for Mach number decreasing past 1 causes issues so keep at 1
    increment = 0.00001;  % Increment for Mach number
    residual = 10;      % Initial residual
    tolerance = 0.001; % Convergence tolerance

    while abs(residual) > tolerance
        M = Mach_Guess;
        term1 = (1 + M^2 * (gamma - 1) / 2);
        term2 = (gamma + 1) / (gamma - 1);
        numerator = term1^(term2 / 2);
        denominator = M * ((gamma + 1) / 2)^(term2 / 2);
        rhs = numerator / denominator;
        residual = area_ratio - rhs;
        Mach_Guess = Mach_Guess + increment * sign(residual);  % Update guess
    end

    M = Mach_Guess;  % Final Mach number
end
