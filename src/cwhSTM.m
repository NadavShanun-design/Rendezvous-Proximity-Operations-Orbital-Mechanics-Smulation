function Phi = cwhSTM(t, n)
% CWHSTM Clohessy-Wiltshire-Hill State Transition Matrix
%   Computes the 6x6 state transition matrix for the CWH equations
%
% Inputs:
%   t - time (s)
%   n - mean motion (rad/s)
%
% Outputs:
%   Phi - 6x6 state transition matrix

% Pre-compute trigonometric terms
nt = n*t;
cos_nt = cos(nt);
sin_nt = sin(nt);

% Initialize 6x6 matrix
Phi = zeros(6);

% Position submatrix (3x3)
Phi(1,1) = 4 - 3*cos_nt;
Phi(1,2) = 0;
Phi(1,3) = 0;
Phi(1,4) = sin_nt/n;
Phi(1,5) = 2*(1-cos_nt)/n;
Phi(1,6) = 0;

Phi(2,1) = 6*(sin_nt - nt);
Phi(2,2) = 1;
Phi(2,3) = 0;
Phi(2,4) = 2*(cos_nt - 1)/n;
Phi(2,5) = 4*sin_nt/n - 3*t;
Phi(2,6) = 0;

Phi(3,1) = 0;
Phi(3,2) = 0;
Phi(3,3) = cos_nt;
Phi(3,4) = 0;
Phi(3,5) = 0;
Phi(3,6) = sin_nt/n;

% Velocity submatrix (3x3)
Phi(4,1) = 3*n*sin_nt;
Phi(4,2) = 0;
Phi(4,3) = 0;
Phi(4,4) = cos_nt;
Phi(4,5) = 2*sin_nt;
Phi(4,6) = 0;

Phi(5,1) = 6*n*(cos_nt - 1);
Phi(5,2) = 0;
Phi(5,3) = 0;
Phi(5,4) = -2*sin_nt;
Phi(5,5) = 4*cos_nt - 3;
Phi(5,6) = 0;

Phi(6,1) = 0;
Phi(6,2) = 0;
Phi(6,3) = -n*sin_nt;
Phi(6,4) = 0;
Phi(6,5) = 0;
Phi(6,6) = cos_nt;

end 