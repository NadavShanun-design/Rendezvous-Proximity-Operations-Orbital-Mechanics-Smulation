% RPO_TRAINER_GUI_FIXED.M
% Interactive RPO Trainer with Working GUI

function rpo_trainer_gui_fixed()
    clear; close all; clc;
    
    % Add paths
    addpath('src');
    addpath('scenarios');
    addpath('assets');
    
    % Create main figure
    fig = figure('Name', 'RPO Trainer - Interactive Mission Control', ...
        'NumberTitle', 'off', 'Color', [0.05 0.05 0.1], ...
        'Position', [100 50 1400 800], 'Resize', 'off');
    
    % Initialize data structure
    data = struct();
    data.fig = fig;
    data.n = 0.0011;  % Mean motion (rad/s)
    data.dt = 60;     % Time step (s)
    data.t_max = 3600; % Max time (s)
    data.isRunning = false;
    data.t = 0;
    
    % Default initial state [x, y, z, vx, vy, vz]
    data.initialState = [1000; 500; 0; 0; 0; 0];
    data.state = data.initialState;
    data.trajectory = data.state(1:3);
    
    % Create GUI panels and store ALL elements in data structure
    data = createControlPanel(data);
    data = createVisualizationPanel(data);
    data = createStatusPanel(data);
    
    % Store data in figure
    guidata(fig, data);
    
    % Initialize display
    updateVisualization();
    updateStatus();
    
    % Display ready message
    fprintf('✅ RPO Trainer GUI loaded successfully!\n');
    fprintf('   - Enter initial position and velocity\n');
    fprintf('   - Click "START MISSION" to run simulation\n');
    fprintf('   - Use RESET and STOP buttons to control simulation\n');
end

function data = createControlPanel(data)
    % Main control panel
    controlPanel = uipanel('Parent', data.fig, 'Title', 'Mission Control', ...
        'Position', [0.02 0.55 0.25 0.43], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white', ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % Initial Position Section
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'Initial Position (m)', 'Position', [10 320 200 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'cyan', ...
        'FontSize', 11, 'FontWeight', 'bold');
    
    % X position
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'X:', 'Position', [20 295 20 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white');
    data.xEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', ...
        'String', '1000', 'Position', [45 295 60 22], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white');
    
    % Y position
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'Y:', 'Position', [115 295 20 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white');
    data.yEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', ...
        'String', '500', 'Position', [140 295 60 22], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white');
    
    % Z position
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'Z:', 'Position', [20 270 20 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white');
    data.zEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', ...
        'String', '0', 'Position', [45 270 60 22], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white');
    
    % Initial Velocity Section
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'Initial Velocity (m/s)', 'Position', [10 240 200 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'cyan', ...
        'FontSize', 11, 'FontWeight', 'bold');
    
    % VX velocity
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'VX:', 'Position', [20 215 25 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white');
    data.vxEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', ...
        'String', '0', 'Position', [50 215 60 22], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white');
    
    % VY velocity
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'VY:', 'Position', [120 215 25 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white');
    data.vyEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', ...
        'String', '0', 'Position', [150 215 60 22], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white');
    
    % VZ velocity
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'VZ:', 'Position', [20 190 25 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white');
    data.vzEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', ...
        'String', '0', 'Position', [50 190 60 22], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white');
    
    % Simulation Parameters
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'Simulation Parameters', 'Position', [10 155 200 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'cyan', ...
        'FontSize', 11, 'FontWeight', 'bold');
    
    % Time step
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'Time Step (s):', 'Position', [20 130 80 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white');
    data.dtEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', ...
        'String', '60', 'Position', [105 130 60 22], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white');
    
    % Max time
    uicontrol('Parent', controlPanel, 'Style', 'text', ...
        'String', 'Max Time (s):', 'Position', [20 105 80 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white');
    data.tmaxEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', ...
        'String', '3600', 'Position', [105 105 60 22], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white');
    
    % Control Buttons
    data.runBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '🚀 START MISSION', 'Position', [20 60 170 35], ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.1 0.6 0.1], 'ForegroundColor', 'white', ...
        'Callback', @runSimulation);
    
    data.resetBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '🔄 RESET', 'Position', [20 20 80 30], ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.6 0.3 0.1], 'ForegroundColor', 'white', ...
        'Callback', @resetSimulation);
    
    data.stopBtn = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', ...
        'String', '⏹ STOP', 'Position', [110 20 80 30], ...
        'FontSize', 10, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.6 0.1 0.1], 'ForegroundColor', 'white', ...
        'Callback', @stopSimulation);
end

function data = createVisualizationPanel(data)
    % 3D Visualization panel
    vizPanel = uipanel('Parent', data.fig, 'Title', '3D Orbital Visualization', ...
        'Position', [0.29 0.02 0.68 0.96], ...
        'BackgroundColor', [0.05 0.05 0.1], 'ForegroundColor', 'white', ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % Create 3D axes
    data.ax = axes('Parent', vizPanel, 'Position', [0.05 0.1 0.9 0.85]);
    hold(data.ax, 'on');
    grid(data.ax, 'on');
    axis(data.ax, 'equal');
    set(data.ax, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');
    xlabel(data.ax, 'X (m)', 'Color', 'w', 'FontSize', 12);
    ylabel(data.ax, 'Y (m)', 'Color', 'w', 'FontSize', 12);
    zlabel(data.ax, 'Z (m)', 'Color', 'w', 'FontSize', 12);
    title(data.ax, 'RPO Mission Simulation', 'Color', 'cyan', 'FontSize', 16, 'FontWeight', 'bold');
    
    % Plot Earth
    [X, Y, Z] = sphere(50);
    earthRadius = 6371;
    data.earthPlot = surf(data.ax, X*earthRadius, Y*earthRadius, Z*earthRadius, ...
        'FaceColor', [0.2 0.5 1], 'EdgeColor', 'none', 'FaceAlpha', 0.7);
    
    % Plot satellites
    data.chiefPlot = plot3(data.ax, 0, 0, 0, 'ro', 'MarkerSize', 15, ...
        'MarkerFaceColor', 'red', 'MarkerEdgeColor', 'white', 'LineWidth', 2);
    
    data.deputyPlot = plot3(data.ax, data.state(1), data.state(2), data.state(3), ...
        'bo', 'MarkerSize', 12, 'MarkerFaceColor', 'blue', 'MarkerEdgeColor', 'white', 'LineWidth', 2);
    
    % Plot trajectory
    data.trajPlot = plot3(data.ax, data.state(1), data.state(2), data.state(3), ...
        'c-', 'LineWidth', 3);
    
    % Set view and limits
    view(data.ax, 45, 30);
    axis(data.ax, [-10000 10000 -10000 10000 -10000 10000]);
    
    % Add legend
    legend(data.ax, {'Earth', 'Chief Satellite', 'Deputy Satellite', 'Trajectory'}, ...
        'TextColor', 'white', 'Color', [0.1 0.1 0.2], 'Location', 'northeast');
end

function data = createStatusPanel(data)
    % Status panel
    statusPanel = uipanel('Parent', data.fig, 'Title', 'Mission Status', ...
        'Position', [0.02 0.02 0.25 0.51], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'white', ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % Time display
    uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', 'Mission Time', 'Position', [10 360 200 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'yellow', ...
        'FontSize', 11, 'FontWeight', 'bold');
    
    data.timeDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', '0 s (0.0 min)', 'Position', [10 335 200 25], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white', ...
        'FontSize', 14, 'FontWeight', 'bold');
    
    % Position display
    uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', 'Position (m)', 'Position', [10 300 200 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'yellow', ...
        'FontSize', 11, 'FontWeight', 'bold');
    
    data.posDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', sprintf('X: %.0f\nY: %.0f\nZ: %.0f', data.state(1), data.state(2), data.state(3)), ...
        'Position', [10 240 200 60], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white', ...
        'FontSize', 12, 'HorizontalAlignment', 'left');
    
    % Velocity display
    uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', 'Velocity (m/s)', 'Position', [10 210 200 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'yellow', ...
        'FontSize', 11, 'FontWeight', 'bold');
    
    data.velDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', sprintf('VX: %.2f\nVY: %.2f\nVZ: %.2f', data.state(4), data.state(5), data.state(6)), ...
        'Position', [10 150 200 60], ...
        'BackgroundColor', [0.2 0.2 0.3], 'ForegroundColor', 'white', ...
        'FontSize', 12, 'HorizontalAlignment', 'left');
    
    % Distance and ΔV
    uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', 'Mission Metrics', 'Position', [10 120 200 20], ...
        'BackgroundColor', [0.1 0.1 0.15], 'ForegroundColor', 'yellow', ...
        'FontSize', 11, 'FontWeight', 'bold');
    
    data.distDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', sprintf('Distance: %.0f m', norm(data.state(1:3))), ...
        'Position', [10 95 200 25], ...
        'BackgroundColor', [0.1 0.4 0.1], 'ForegroundColor', 'white', ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    data.dvDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', sprintf('ΔV: %.2f m/s', norm(data.state(4:6))), ...
        'Position', [10 65 200 25], ...
        'BackgroundColor', [0.1 0.4 0.1], 'ForegroundColor', 'white', ...
        'FontSize', 12, 'FontWeight', 'bold');
    
    % Progress bar
    data.progressDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', ...
        'String', 'READY TO START', 'Position', [10 25 200 30], ...
        'BackgroundColor', [0.1 0.1 0.4], 'ForegroundColor', 'cyan', ...
        'FontSize', 12, 'FontWeight', 'bold');
end

% Callback functions - these now work with the shared data structure
function runSimulation(src, ~)
    try
        data = guidata(src);
        fprintf('🚀 Starting simulation...\n');
        
        % Get user inputs and validate
        x = str2double(get(data.xEdit, 'String'));
        y = str2double(get(data.yEdit, 'String'));
        z = str2double(get(data.zEdit, 'String'));
        vx = str2double(get(data.vxEdit, 'String'));
        vy = str2double(get(data.vyEdit, 'String'));
        vz = str2double(get(data.vzEdit, 'String'));
        dt = str2double(get(data.dtEdit, 'String'));
        t_max = str2double(get(data.tmaxEdit, 'String'));
        
        % Validate inputs
        if any(isnan([x, y, z, vx, vy, vz, dt, t_max]))
            error('All input fields must contain valid numbers');
        end
        if dt <= 0 || t_max <= 0
            error('Time step and max time must be positive');
        end
        
        % Update data with user inputs
        data.initialState = [x; y; z; vx; vy; vz];
        data.dt = dt;
        data.t_max = t_max;
        
        % Reset simulation
        data.t = 0;
        data.state = data.initialState;
        data.trajectory = data.state(1:3);
        data.isRunning = true;
        
        fprintf('   Initial state: [%.0f, %.0f, %.0f] m, [%.2f, %.2f, %.2f] m/s\n', ...
            x, y, z, vx, vy, vz);
        fprintf('   Time step: %.0f s, Max time: %.0f s\n', dt, t_max);
        
        % Update button states
        set(data.runBtn, 'String', '🔄 RUNNING...', 'BackgroundColor', [0.6 0.6 0.1]);
        set(data.resetBtn, 'Enable', 'off');
        set(data.stopBtn, 'Enable', 'on');
        
        guidata(src, data);
        
        % Run simulation loop
        numSteps = ceil(data.t_max / data.dt);
        fprintf('   Running %d simulation steps...\n', numSteps);
        
        for i = 1:numSteps
            % Check if simulation was stopped
            data = guidata(src);  % Refresh data in case stop was pressed
            if ~data.isRunning
                fprintf('   Simulation stopped by user.\n');
                break;
            end
            
            % Propagate state
            data.state = propagateCWH(data.state, data.dt, data.n);
            data.t = data.t + data.dt;
            
            % Store trajectory
            data.trajectory(:,end+1) = data.state(1:3);
            
            % Update displays
            updateVisualization();
            updateStatus();
            
            % Update progress
            progress = 100 * i / numSteps;
            set(data.progressDisplay, 'String', sprintf('RUNNING %.1f%%', progress));
            
            guidata(src, data);
            drawnow;
            pause(0.02);  % Faster animation
            
            % Print progress every 10 steps
            if mod(i, 10) == 0
                fprintf('   Progress: %.1f%% (t=%.0f s)\n', progress, data.t);
            end
        end
        
        % Simulation complete
        data.isRunning = false;
        set(data.runBtn, 'String', '🚀 START MISSION', 'BackgroundColor', [0.1 0.6 0.1]);
        set(data.resetBtn, 'Enable', 'on');
        set(data.stopBtn, 'Enable', 'off');
        set(data.progressDisplay, 'String', 'MISSION COMPLETE!', 'BackgroundColor', [0.1 0.6 0.1]);
        guidata(src, data);
        
        fprintf('✅ Simulation complete!\n');
        fprintf('   Final position: [%.0f, %.0f, %.0f] m\n', data.state(1), data.state(2), data.state(3));
        fprintf('   Final distance: %.0f m\n', norm(data.state(1:3)));
        
    catch ME
        fprintf('❌ Error in simulation: %s\n', ME.message);
        % Reset button states on error
        try
            data = guidata(src);
            data.isRunning = false;
            set(data.runBtn, 'String', '🚀 START MISSION', 'BackgroundColor', [0.1 0.6 0.1]);
            set(data.resetBtn, 'Enable', 'on');
            set(data.stopBtn, 'Enable', 'on');
            set(data.progressDisplay, 'String', 'ERROR!', 'BackgroundColor', [0.6 0.1 0.1]);
            guidata(src, data);
        catch
            fprintf('   Additional error occurred while resetting GUI\n');
        end
    end
end

function resetSimulation(src, ~)
    try
        data = guidata(src);
        fprintf('🔄 Resetting simulation...\n');
        
        % Reset to initial values
        data.t = 0;
        data.state = data.initialState;
        data.trajectory = data.state(1:3);
        data.isRunning = false;
        
        % Reset button states
        set(data.runBtn, 'String', '🚀 START MISSION', 'BackgroundColor', [0.1 0.6 0.1]);
        set(data.resetBtn, 'Enable', 'on');
        set(data.stopBtn, 'Enable', 'on');
        set(data.progressDisplay, 'String', 'READY TO START', 'BackgroundColor', [0.1 0.1 0.4]);
        
        guidata(src, data);
        updateVisualization();
        updateStatus();
        
        fprintf('✅ Reset complete!\n');
    catch ME
        fprintf('❌ Error in reset: %s\n', ME.message);
    end
end

function stopSimulation(src, ~)
    try
        data = guidata(src);
        fprintf('⏹ Stopping simulation...\n');
        
        data.isRunning = false;
        set(data.runBtn, 'String', '🚀 START MISSION', 'BackgroundColor', [0.1 0.6 0.1]);
        set(data.resetBtn, 'Enable', 'on');
        set(data.stopBtn, 'Enable', 'on');
        set(data.progressDisplay, 'String', 'STOPPED', 'BackgroundColor', [0.6 0.1 0.1]);
        guidata(src, data);
        
        fprintf('✅ Simulation stopped!\n');
    catch ME
        fprintf('❌ Error in stop: %s\n', ME.message);
    end
end

function updateVisualization()
    data = guidata(gcf);  % Get data from current figure
    
    % Update deputy satellite position
    set(data.deputyPlot, 'XData', data.state(1), 'YData', data.state(2), 'ZData', data.state(3));
    
    % Update trajectory
    if size(data.trajectory, 2) > 1
        set(data.trajPlot, 'XData', data.trajectory(1,:), ...
            'YData', data.trajectory(2,:), 'ZData', data.trajectory(3,:));
    end
    
    % Update title with current time
    title(data.ax, sprintf('RPO Mission - Time: %.1f min', data.t/60), ...
        'Color', 'cyan', 'FontSize', 16, 'FontWeight', 'bold');
end

function updateStatus()
    data = guidata(gcf);  % Get data from current figure
    
    % Update time
    set(data.timeDisplay, 'String', sprintf('%.0f s (%.1f min)', data.t, data.t/60));
    
    % Update position
    set(data.posDisplay, 'String', sprintf('X: %.0f\nY: %.0f\nZ: %.0f', ...
        data.state(1), data.state(2), data.state(3)));
    
    % Update velocity
    set(data.velDisplay, 'String', sprintf('VX: %.2f\nVY: %.2f\nVZ: %.2f', ...
        data.state(4), data.state(5), data.state(6)));
    
    % Update distance and ΔV
    distance = norm(data.state(1:3));
    deltaV = norm(data.state(4:6));
    
    set(data.distDisplay, 'String', sprintf('Distance: %.0f m', distance));
    set(data.dvDisplay, 'String', sprintf('ΔV: %.2f m/s', deltaV));
    
    % Color code distance
    if distance < 1000
        set(data.distDisplay, 'BackgroundColor', [0.1 0.6 0.1]);  % Green - close
    elseif distance < 5000
        set(data.distDisplay, 'BackgroundColor', [0.6 0.6 0.1]);  % Yellow - medium
    else
        set(data.distDisplay, 'BackgroundColor', [0.6 0.1 0.1]);  % Red - far
    end
end 