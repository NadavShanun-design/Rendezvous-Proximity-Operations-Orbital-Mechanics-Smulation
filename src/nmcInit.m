function x0 = nmcInit(radius, phase, n)
% NMCINIT Generate initial state for Natural Motion Circle
%   Creates an initial state vector that will result in a circular
%   relative motion orbit (Natural Motion Circle)
%
% Inputs:
%   radius - radius of the NMC (m)
%   phase - initial phase angle (rad)
%   n - mean motion (rad/s)
%
% Outputs:
%   x0 - initial state vector [r; v] (6x1)

% Initialize state vector
x0 = zeros(6,1);

% Set position components
x0(1) = radius * cos(phase);  % x
x0(2) = radius * sin(phase);  % y
x0(3) = 0;                    % z

% Set velocity components for circular motion
x0(4) = -n * radius * sin(phase);  % vx
x0(5) = n * radius * cos(phase);   % vy
x0(6) = 0;                         % vz

end 