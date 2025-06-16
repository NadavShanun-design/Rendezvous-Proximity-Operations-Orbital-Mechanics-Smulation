%% RPO Core Functions Test Script
% This script demonstrates the basic functionality of each core RPO function
% with detailed explanations for beginners.

%% 1. Setup - Define Basic Parameters
% First, we need to define some basic parameters that we'll use throughout
% the tests. In space, we often work with the mean motion (n) which is
% related to the orbital period.

% For a typical Low Earth Orbit (LEO), mean motion is about 0.0011 rad/s
n = 0.0011;  % mean motion in radians per second

% Let's also define a time span for our tests
t = 3600;    % 1 hour in seconds

%% 2. Test Natural Motion Circle (NMC) Initialization
% A Natural Motion Circle is a special type of relative orbit where a
% spacecraft will naturally move in a circle around a reference point
% without any thrust.

% Define NMC parameters
radius = 1000;  % 1 kilometer radius
phase = 0;      % Start at 0 degrees (right side of circle)

% Generate initial state for NMC
x0 = nmcInit(radius, phase, n);

% Display the initial state
disp('Initial state for Natural Motion Circle:')
disp('Position (x, y, z) in meters:')
disp(x0(1:3))
disp('Velocity (vx, vy, vz) in meters/second:')
disp(x0(4:6))

%% 3. Test State Propagation
% Now let's see how this state evolves over time using the CWH equations

% Propagate the state for 1 hour
x = propagateCWH(x0, t, n);

% Display the final state
disp('Final state after 1 hour:')
disp('Position (x, y, z) in meters:')
disp(x(1:3))
disp('Velocity (vx, vy, vz) in meters/second:')
disp(x(4:6))

%% 4. Test Two-Impulse Rendezvous
% Let's create a simple rendezvous scenario where we want to move from
% one position to another

% Define initial and final states
x0 = [1000; 0; 0; 0; 0; 0];  % Start 1 km to the right
xf = [0; 1000; 0; 0; 0; 0];  % End 1 km above

% Calculate the required impulses
[dV1, dV2] = twoImpulseCWH(x0, xf, t, n);

% Display the required velocity changes
disp('Required velocity changes for rendezvous:')
disp('First impulse (m/s):')
disp(dV1)
disp('Second impulse (m/s):')
disp(dV2)

%% 5. Test Station-Keeping Control
% Finally, let's test the station-keeping control that would maintain
% a position

% Define control gains
kp = 0.01;  % proportional gain
kd = 0.1;   % derivative gain

% Calculate control input for the current state
u = forcedMotion(x0, n, kp, kd);

% Display the control input
disp('Station-keeping control input (m/s^2):')
disp(u)

%% 6. Visualize the Results
% Let's create a simple plot to visualize the NMC motion

% Create time points for plotting
t_points = linspace(0, t, 100);
x_history = zeros(6, length(t_points));

% Propagate state at each time point
for i = 1:length(t_points)
    x_history(:,i) = propagateCWH(x0, t_points(i), n);
end

% Plot the trajectory
figure;
plot3(x_history(1,:), x_history(2,:), x_history(3,:), 'b-', 'LineWidth', 2);
grid on;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Natural Motion Circle Trajectory');
view(45, 30);  % Set a good viewing angle 