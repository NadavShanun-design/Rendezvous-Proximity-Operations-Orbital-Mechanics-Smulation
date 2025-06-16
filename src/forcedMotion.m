function u = forcedMotion(x, n, kp, kd)
% FORCEDMOTION PD control for station-keeping in CWH frame
%   Computes control input to maintain position using PD control
%
% Inputs:
%   x - current state vector [r; v] (6x1)
%   n - mean motion (rad/s)
%   kp - proportional gain
%   kd - derivative gain
%
% Outputs:
%   u - control input vector (3x1)

% Extract position and velocity
r = x(1:3);
v = x(4:6);

% Compute control input using PD control
% Add CWH dynamics compensation
u = -kp * r - kd * v + [0; 0; -n^2*r(3)];

end 