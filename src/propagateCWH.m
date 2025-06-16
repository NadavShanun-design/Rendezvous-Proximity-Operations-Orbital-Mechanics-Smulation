function x = propagateCWH(x0, t, n)
% PROPAGATECWH Propagate state using Clohessy-Wiltshire-Hill equations
%   Propagates a state vector using the CWH STM
%
% Inputs:
%   x0 - initial state vector [r; v] (6x1)
%   t - time to propagate (s)
%   n - mean motion (rad/s)
%
% Outputs:
%   x - propagated state vector [r; v] (6x1)

% Get the state transition matrix
Phi = cwhSTM(n, t);

% Propagate the state
x = Phi * x0;

end 