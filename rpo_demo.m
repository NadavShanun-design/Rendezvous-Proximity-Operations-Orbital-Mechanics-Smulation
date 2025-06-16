% RPO_DEMO.M
% Simple working demonstration of RPO simulation

clear; close all; clc;

% Add paths
addpath('src');
addpath('scenarios');

fprintf('🚀 Starting RPO Demonstration...\n');

% Load lesson data
if exist(fullfile('scenarios','lesson_1.mat'),'file')
    load(fullfile('scenarios','lesson_1.mat'),'LessonData');
    fprintf('✓ Lesson data loaded\n');
else
    % Create simple demo data
    LessonData.initialState = [1000; 500; 0; 0; 0; 0];  % 1km ahead, 500m to side
    LessonData.waypoints = [
        2000, 0, 0, 1800;      % 2km ahead at 30 min
        0, 0, 0, 3600          % Origin at 1 hour
    ];
    LessonData.narrative = 'Demo: Deputy satellite performs approach maneuver to chief satellite.';
    fprintf('✓ Demo data created\n');
end

% Simulation parameters
n = 0.0011;  % Mean motion (rad/s)
dt = 60;     % Time step (s)
t_max = 3600; % 1 hour simulation

% Initialize
t = 0;
state = LessonData.initialState;
trajectory = state(1:3);

% Create figure
fig = figure('Name','RPO Demo - Running Simulation','NumberTitle','off',...
    'Color',[0.1 0.1 0.1],'Position',[200 200 1000 600]);

% 3D plot
ax = axes('Position',[0.05 0.1 0.6 0.8]);
hold on; grid on; axis equal;
set(ax,'Color','k','XColor','w','YColor','w','ZColor','w');
xlabel('X (m)','Color','w'); ylabel('Y (m)','Color','w'); zlabel('Z (m)','Color','w');
title('RPO Simulation - RUNNING','Color','w','FontSize',16);

% Plot Earth
[X,Y,Z] = sphere(30);
surf(ax, X*6371, Y*6371, Z*6371, 'FaceColor',[0.2 0.5 1],'EdgeColor','none','FaceAlpha',0.6);

% Plot satellites
h_chief = plot3(ax, 0, 0, 0, 'ro', 'MarkerSize', 15, 'MarkerFaceColor', 'r');
h_deputy = plot3(ax, state(1), state(2), state(3), 'bo', 'MarkerSize', 12, 'MarkerFaceColor', 'b');
h_traj = plot3(ax, state(1), state(2), state(3), 'c-', 'LineWidth', 2);

% Set view
axis(ax, [-8000 8000 -8000 8000 -8000 8000]);
view(ax, 45, 30);

% Status panel
status_panel = uipanel('Parent',fig,'Position',[0.7 0.1 0.25 0.8],...
    'BackgroundColor',[0.2 0.2 0.2],'ForegroundColor','w','Title','Status');

% Time display
time_text = uicontrol('Parent',status_panel,'Style','text',...
    'String','Time: 0 s','Position',[10 300 180 30],...
    'FontSize',14,'ForegroundColor','w','BackgroundColor',[0.2 0.2 0.2]);

% Position display
pos_text = uicontrol('Parent',status_panel,'Style','text',...
    'String',sprintf('Position:\nX: %.0f m\nY: %.0f m\nZ: %.0f m',...
    state(1),state(2),state(3)),'Position',[10 200 180 80],...
    'FontSize',12,'ForegroundColor','w','BackgroundColor',[0.2 0.2 0.2]);

% Velocity display
vel_text = uicontrol('Parent',status_panel,'Style','text',...
    'String',sprintf('Velocity:\nVx: %.2f m/s\nVy: %.2f m/s\nVz: %.2f m/s',...
    state(4),state(5),state(6)),'Position',[10 100 180 80],...
    'FontSize',12,'ForegroundColor','w','BackgroundColor',[0.2 0.2 0.2]);

% Distance display
dist_text = uicontrol('Parent',status_panel,'Style','text',...
    'String',sprintf('Distance: %.0f m',norm(state(1:3))),'Position',[10 50 180 30],...
    'FontSize',12,'ForegroundColor','w','BackgroundColor',[0.2 0.2 0.2]);

fprintf('✓ Visualization created\n');
fprintf('🎬 Running simulation...\n');

% Run simulation
for i = 1:60  % 60 steps = 1 hour
    % Propagate state
    state = propagateCWH(state, dt, n);
    t = t + dt;
    
    % Store trajectory
    trajectory(:,end+1) = state(1:3);
    
    % Update visualization
    set(h_deputy, 'XData', state(1), 'YData', state(2), 'ZData', state(3));
    set(h_traj, 'XData', trajectory(1,:), 'YData', trajectory(2,:), 'ZData', trajectory(3,:));
    
    % Update status
    set(time_text, 'String', sprintf('Time: %.0f s (%.1f min)', t, t/60));
    set(pos_text, 'String', sprintf('Position:\nX: %.0f m\nY: %.0f m\nZ: %.0f m',...
        state(1), state(2), state(3)));
    set(vel_text, 'String', sprintf('Velocity:\nVx: %.2f m/s\nVy: %.2f m/s\nVz: %.2f m/s',...
        state(4), state(5), state(6)));
    set(dist_text, 'String', sprintf('Distance: %.0f m', norm(state(1:3))));
    
    % Update title with progress
    title(ax, sprintf('RPO Simulation - RUNNING (%.1f%% complete)', 100*i/60),...
        'Color','w','FontSize',16);
    
    drawnow;
    pause(0.1);  % Animation delay
end

% Final status
title(ax, 'RPO Simulation - COMPLETE ✓', 'Color','g','FontSize',16);
fprintf('✅ Simulation complete!\n');
fprintf('   Final position: [%.0f, %.0f, %.0f] m\n', state(1), state(2), state(3));
fprintf('   Final distance: %.0f m\n', norm(state(1:3)));
fprintf('   Total time: %.0f seconds (%.1f minutes)\n', t, t/60);

% Add completion message
uicontrol('Parent',status_panel,'Style','text',...
    'String','SIMULATION COMPLETE!','Position',[10 10 180 30],...
    'FontSize',14,'FontWeight','bold','ForegroundColor','g','BackgroundColor',[0.2 0.2 0.2]);

fprintf('\n🎯 Demo complete! The simulation is working properly.\n');
fprintf('   You can now run "run_rpo_trainer_simple" for the full interactive version.\n'); 