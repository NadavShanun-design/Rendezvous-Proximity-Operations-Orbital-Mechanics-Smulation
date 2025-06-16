% RUN_RPO_TRAINER_SIMPLE.M
% Simple, working RPO Trainer - functionality first!

% Clear everything
clear; close all; clc;

% --- Error Checking ---
try
    addpath('src');
    addpath('scenarios');
    addpath('assets');
    
    % Check required files
    requiredFiles = {'cwhSTM.m','propagateCWH.m','twoImpulseCWH.m','nmcInit.m','forcedMotion.m','rpoController.m'};
    for k = 1:length(requiredFiles)
        if ~exist(fullfile('src',requiredFiles{k}),'file')
            error(['Missing required file: src/' requiredFiles{k}]);
        end
    end
    if ~exist(fullfile('scenarios','lesson_1.mat'),'file')
        error('Missing required scenario: scenarios/lesson_1.mat');
    end
    
    fprintf('✓ All required files found!\n');
catch ME
    fprintf('ERROR: %s\n', ME.message);
    return;
end

% --- Load Lesson Data ---
load(fullfile('scenarios','lesson_1.mat'),'LessonData');
fprintf('✓ Lesson data loaded!\n');

% --- Global Variables for Callbacks ---
global g_handles g_state g_LessonData g_x_hist g_t

% Store data globally
g_LessonData = LessonData;
g_state = LessonData.initialState;
g_t = 0;
g_x_hist = g_state;

% --- Create Figure ---
g_handles.fig = figure('Name','RPO Trainer - Simple Version','NumberTitle','off',...
    'Color',[0.1 0.1 0.1],'Position',[100 100 1200 700]);
movegui(g_handles.fig,'center');

% --- 3D Visualization ---
g_handles.ax = axes('Parent',g_handles.fig,'Position',[0.05 0.25 0.5 0.7]);
hold(g_handles.ax,'on'); 
grid(g_handles.ax,'on'); 
axis(g_handles.ax,'equal'); 
view(g_handles.ax,45,30);
set(g_handles.ax,'Color','k','XColor','w','YColor','w','ZColor','w');
xlabel(g_handles.ax,'X (m)','Color','w','FontSize',12); 
ylabel(g_handles.ax,'Y (m)','Color','w','FontSize',12); 
zlabel(g_handles.ax,'Z (m)','Color','w','FontSize',12);
title(g_handles.ax,'RPO Simulation','Color','w','FontSize',14,'FontWeight','bold');

% Plot Earth (simple blue sphere)
[X,Y,Z] = sphere(50);
earthRadius = 6371;
g_handles.earth = surf(g_handles.ax, X*earthRadius, Y*earthRadius, Z*earthRadius, ...
    'FaceColor', [0.2 0.5 1], 'EdgeColor', 'none', 'FaceAlpha', 0.8);

% Plot Chief Satellite (red dot at origin)
g_handles.chief = plot3(g_handles.ax, 0, 0, 0, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r');

% Plot Deputy Satellite (blue dot)
depPos = g_state(1:3);
g_handles.deputy = plot3(g_handles.ax, depPos(1), depPos(2), depPos(3), ...
    'bo', 'MarkerSize', 10, 'MarkerFaceColor', 'b');

% Plot Trajectory (cyan line)
g_handles.trajectory = plot3(g_handles.ax, depPos(1), depPos(2), depPos(3), ...
    'c-', 'LineWidth', 2);

% Set axis limits
axis(g_handles.ax, [-15000 15000 -15000 15000 -15000 15000]);

% --- UI Controls ---
% Time slider
uicontrol('Style','text','Parent',g_handles.fig,'String','Time (seconds):',...
    'Units','normalized','Position',[0.6 0.85 0.15 0.05],...
    'FontSize',12,'ForegroundColor','w','BackgroundColor',[0.1 0.1 0.1]);

g_handles.timeSlider = uicontrol('Style','slider','Parent',g_handles.fig,...
    'Min',0,'Max',3600,'Value',0,'Units','normalized',...
    'Position',[0.6 0.8 0.3 0.04],'Callback',@timeSliderCallback);

% Time display
g_handles.timeDisplay = uicontrol('Style','text','Parent',g_handles.fig,...
    'String','0 s','Units','normalized','Position',[0.91 0.8 0.08 0.04],...
    'FontSize',12,'ForegroundColor','w','BackgroundColor',[0.2 0.2 0.2]);

% Control buttons
g_handles.runBtn = uicontrol('Style','pushbutton','Parent',g_handles.fig,...
    'String','▶ Run','Units','normalized','Position',[0.6 0.7 0.08 0.06],...
    'FontSize',12,'Callback',@runCallback);

g_handles.resetBtn = uicontrol('Style','pushbutton','Parent',g_handles.fig,...
    'String','⟲ Reset','Units','normalized','Position',[0.7 0.7 0.08 0.06],...
    'FontSize',12,'Callback',@resetCallback);

% ΔV Display
g_handles.dvDisplay = uicontrol('Style','text','Parent',g_handles.fig,...
    'String','ΔV: 0.00 m/s','Units','normalized','Position',[0.8 0.7 0.15 0.06],...
    'FontSize',12,'ForegroundColor','w','BackgroundColor',[0.1 0.5 0.1]);

% Waypoint table
g_handles.waypointTable = uitable('Parent',g_handles.fig,...
    'Data',LessonData.waypoints,'ColumnName',{'X (m)','Y (m)','Z (m)','Time (s)'},...
    'Units','normalized','Position',[0.6 0.45 0.35 0.2],'FontSize',10);

% Narrative text
uicontrol('Style','text','Parent',g_handles.fig,'String','Lesson 1: Introduction to RPO',...
    'Units','normalized','Position',[0.6 0.4 0.35 0.04],...
    'FontSize',14,'FontWeight','bold','ForegroundColor','w','BackgroundColor',[0.1 0.1 0.1]);

g_handles.narrative = uicontrol('Style','edit','Parent',g_handles.fig,...
    'String',LessonData.narrative,'Units','normalized',...
    'Position',[0.6 0.05 0.35 0.35],'FontSize',11,'Max',10,...
    'BackgroundColor',[0.9 0.9 0.9],'HorizontalAlignment','left');

fprintf('✓ UI created!\n');

% --- Callback Functions ---
function timeSliderCallback(src, ~)
    global g_handles g_state g_LessonData g_x_hist g_t
    
    g_t = get(src, 'Value');
    set(g_handles.timeDisplay, 'String', sprintf('%.0f s', g_t));
    
    % Propagate to current time
    [g_state, g_x_hist] = propagateToTime(g_t, g_LessonData.initialState);
    updateVisualization();
end

function runCallback(~, ~)
    global g_handles g_state g_LessonData g_x_hist g_t
    
    % Animate from 0 to 1 hour
    for t = 0:60:3600
        g_t = t;
        set(g_handles.timeSlider, 'Value', t);
        set(g_handles.timeDisplay, 'String', sprintf('%.0f s', t));
        
        [g_state, g_x_hist] = propagateToTime(t, g_LessonData.initialState);
        updateVisualization();
        
        pause(0.05);  % Small delay for animation
        drawnow;
    end
end

function resetCallback(~, ~)
    global g_handles g_state g_LessonData g_x_hist g_t
    
    g_t = 0;
    g_state = g_LessonData.initialState;
    g_x_hist = g_state;
    
    set(g_handles.timeSlider, 'Value', 0);
    set(g_handles.timeDisplay, 'String', '0 s');
    
    updateVisualization();
end

function updateVisualization()
    global g_handles g_state g_x_hist
    
    % Update deputy satellite position
    set(g_handles.deputy, 'XData', g_state(1), 'YData', g_state(2), 'ZData', g_state(3));
    
    % Update trajectory
    if size(g_x_hist, 2) > 1
        set(g_handles.trajectory, 'XData', g_x_hist(1,:), 'YData', g_x_hist(2,:), 'ZData', g_x_hist(3,:));
    end
    
    % Update ΔV display
    dv = norm(g_state(4:6));
    set(g_handles.dvDisplay, 'String', sprintf('ΔV: %.2f m/s', dv));
    
    % Color code ΔV
    if dv < 50
        set(g_handles.dvDisplay, 'BackgroundColor', [0.1 0.5 0.1]);  % Green
    elseif dv < 100
        set(g_handles.dvDisplay, 'BackgroundColor', [0.5 0.5 0.1]);  % Yellow
    else
        set(g_handles.dvDisplay, 'BackgroundColor', [0.5 0.1 0.1]);  % Red
    end
end

function [state, x_hist] = propagateToTime(t_target, x0)
    n = 0.0011;  % Mean motion (rad/s)
    t_step = 60;  % Time step (s)
    t_curr = 0;
    state = x0;
    x_hist = state;
    
    while t_curr < t_target
        state = propagateCWH(state, t_step, n);
        x_hist(:,end+1) = state;
        t_curr = t_curr + t_step;
    end
end

% --- Initialize ---
updateVisualization();
fprintf('✓ RPO Trainer ready! Use the controls to explore.\n');
fprintf('  - Move the time slider to scrub through the simulation\n');
fprintf('  - Click "Run" to animate the full trajectory\n');
fprintf('  - Click "Reset" to return to the beginning\n'); 