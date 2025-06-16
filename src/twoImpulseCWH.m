function [dV1, dV2] = twoImpulseCWH(x0, xf, T, n)
% TWOIMPULSECWH Two-impulse rendezvous solution using CWH equations
%   Solves for the two impulses needed to achieve rendezvous
%
% Inputs:
%   x0 - initial state vector [r; v] (6x1)
%   xf - final state vector [r; v] (6x1)
%   T - transfer time (s)
%   n - mean motion (rad/s)
%
% Outputs:
%   dV1 - first impulse vector (3x1)
%   dV2 - second impulse vector (3x1)

% Get the state transition matrix for the transfer time
Phi = cwhSTM(T, n);

% Extract position and velocity components
r0 = x0(1:3);
v0 = x0(4:6);
rf = xf(1:3);
vf = xf(4:6);

% Solve for required initial velocity to reach final position
% rf = Phi(1:3,1:3)*r0 + Phi(1:3,4:6)*v_new
v_new = Phi(1:3,4:6) \ (rf - Phi(1:3,1:3)*r0);

% First impulse: change from current to required velocity
dV1 = v_new - v0;

% Propagate to final time and compute second impulse
x_final = Phi * [r0; v_new];
v_final = x_final(4:6);

% Second impulse: achieve final velocity
dV2 = vf - v_final;

end 