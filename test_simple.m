% TEST_SIMPLE.M
% Quick test to verify physics functions work

clear; clc;

% Add paths
addpath('src');

% Test basic propagation
fprintf('Testing RPO Physics Functions...\n');

% Initial state: [x, y, z, vx, vy, vz] in meters and m/s
x0 = [1000; 500; 0; 0; 0; 0];  % Deputy satellite 1km ahead, 500m to the side
n = 0.0011;  % Mean motion (rad/s)
dt = 60;     % Time step (60 seconds)

fprintf('Initial state: [%.1f, %.1f, %.1f] m\n', x0(1), x0(2), x0(3));

% Test propagation for 10 minutes
x1 = propagateCWH(x0, 10*60, n);
fprintf('After 10 min:  [%.1f, %.1f, %.1f] m\n', x1(1), x1(2), x1(3));

% Test STM
STM = cwhSTM(10*60, n);
x1_stm = STM * x0;
fprintf('STM result:    [%.1f, %.1f, %.1f] m\n', x1_stm(1), x1_stm(2), x1_stm(3));

% Check if they match
diff = norm(x1 - x1_stm);
if diff < 1e-6
    fprintf('✓ STM and propagation match!\n');
else
    fprintf('✗ STM and propagation differ by %.2e\n', diff);
end

% Test Natural Motion Circle
try
    x_nmc = nmcInit(2000, 0, n);  % 2km radius circle
    fprintf('✓ Natural Motion Circle: r=%.1f m\n', norm(x_nmc(1:3)));
catch
    fprintf('✗ Natural Motion Circle failed\n');
end

% Test Two-Impulse Solution
try
    x_target = [2000; 0; 0; 0; 0; 0];  % Target 2km ahead
    tof = 1800;  % 30 minutes
    [dv1, dv2] = twoImpulseCWH(x0, x_target, tof, n);
    fprintf('✓ Two-impulse: ΔV1=%.2f m/s, ΔV2=%.2f m/s\n', norm(dv1), norm(dv2));
catch
    fprintf('✗ Two-impulse solution failed\n');
end

fprintf('\nAll basic tests completed!\n'); 