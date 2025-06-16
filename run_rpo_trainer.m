% RUN_RPO_TRAINER.M
% Script-based interactive RPO Trainer (no App Designer required)

% --- Error Checking ---
try
    addpath('src');
    addpath('scenarios');
    requiredFiles = {'cwhSTM.m','propagateCWH.m','twoImpulseCWH.m','nmcInit.m','forcedMotion.m','rpoController.m'};
    for k = 1:length(requiredFiles)
        if ~exist(fullfile('src',requiredFiles{k}),'file')
            error(['Missing required file: src/' requiredFiles{k}]);
        end
    end
    if ~exist(fullfile('scenarios','lesson_1.mat'),'file')
        error('Missing required scenario: scenarios/lesson_1.mat');
    end
catch ME
    disp(['ERROR: ' ME.message]);
    return;
end

% --- Load Lesson Data ---
load(fullfile('scenarios','lesson_1.mat'),'LessonData');

% --- Set Up Figure and UI ---
handles.fig = figure('Name','RPO Trainer','NumberTitle','off','Color','w','Position',[100 100 1200 700]);
movegui(handles.fig,'center');

% 3D Axes
handles.ax = axes('Parent',handles.fig,'Position',[0.05 0.25 0.45 0.7]);
hold(handles.ax,'on'); grid(handles.ax,'on'); axis(handles.ax,'equal'); view(handles.ax,135,30);
xlabel(handles.ax,'X (m)'); ylabel(handles.ax,'Y (m)'); zlabel(handles.ax,'Z (m)');
title(handles.ax,'RPO Visualization');

% Plot Earth (blue sphere)
[Xe,Ye,Ze] = sphere(40);
handles.Earth = surf(handles.ax, Xe*6371, Ye*6371, Ze*6371, 'FaceColor', 'blue', 'EdgeColor', 'none', 'FaceAlpha',0.3);

% Plot Chief Satellite (red)
handles.chief = plot3(handles.ax,0,0,0,'ro','MarkerSize',10,'MarkerFaceColor','r');

% Plot Deputy Satellite (blue)
handles.dep = plot3(handles.ax,LessonData.initialState(1),LessonData.initialState(2),LessonData.initialState(3),...
    'bo','MarkerSize',8,'MarkerFaceColor','b');

% Trajectory line
handles.traj = plot3(handles.ax,LessonData.initialState(1),LessonData.initialState(2),LessonData.initialState(3),...
    'b-','LineWidth',2);

% --- UI Controls ---
uicontrol('Style','text','Parent',handles.fig,'String','Time (s)','Units','normalized','Position',[0.55 0.85 0.1 0.05],'FontSize',12);
handles.timeSlider = uicontrol('Style','slider','Parent',handles.fig,'Min',0,'Max',3600,'Value',0,'Units','normalized',...
    'Position',[0.65 0.86 0.25 0.04],'Callback',@(src,evt)sliderCallback(src,evt));
handles.runBtn = uicontrol('Style','pushbutton','Parent',handles.fig,'String','Run Simulation','Units','normalized',...
    'Position',[0.55 0.75 0.15 0.06],'FontSize',12,'Callback',@(src,evt)runCallback(src,evt));
handles.resetBtn = uicontrol('Style','pushbutton','Parent',handles.fig,'String','Reset','Units','normalized',...
    'Position',[0.72 0.75 0.08 0.06],'FontSize',12,'Callback',@(src,evt)resetCallback(src,evt));
handles.dvLamp = uicontrol('Style','text','Parent',handles.fig,'String','ΔV: 0 m/s','Units','normalized',...
    'Position',[0.82 0.75 0.12 0.06],'FontSize',14,'BackgroundColor',[0.7 1 0.7]);
uitable('Parent',handles.fig,'Data',LessonData.waypoints,'ColumnName',{'X','Y','Z','Time'},...
    'Units','normalized','Position',[0.55 0.55 0.39 0.15],'FontSize',11);
uicontrol('Style','text','Parent',handles.fig,'String','Lesson Narrative','Units','normalized',...
    'Position',[0.55 0.48 0.39 0.05],'FontSize',13,'FontWeight','bold','BackgroundColor','w');
handles.narr = uicontrol('Style','edit','Parent',handles.fig,'String',LessonData.narrative,'Units','normalized',...
    'Position',[0.55 0.25 0.39 0.23],'FontSize',11,'Max',2,'BackgroundColor','w','HorizontalAlignment','left');

% --- Simulation State ---
handles.state = LessonData.initialState;
handles.t = 0;
handles.dv_total = 0;
handles.x_hist = handles.state;
handles.LessonData = LessonData;

% --- Callbacks ---
function sliderCallback(src,~)
    handles = guidata(src);
    handles.t = get(handles.timeSlider,'Value');
    [handles.state, handles.x_hist] = propagateToTime(handles.t, handles.LessonData.initialState, handles.LessonData.waypoints);
    updatePlot();
    guidata(src,handles);
end

function runCallback(src,~)
    handles = guidata(src);
    for tt = 0:60:3600
        set(handles.timeSlider,'Value',tt);
        [handles.state, handles.x_hist] = propagateToTime(tt, handles.LessonData.initialState, handles.LessonData.waypoints);
        updatePlot();
        pause(0.05);
    end
    guidata(src,handles);
end

function resetCallback(src,~)
    handles = guidata(src);
    handles.t = 0;
    handles.state = handles.LessonData.initialState;
    handles.x_hist = handles.state;
    set(handles.timeSlider,'Value',0);
    updatePlot();
    guidata(src,handles);
end

function updatePlot()
    set(handles.dep,'XData',handles.state(1),'YData',handles.state(2),'ZData',handles.state(3));
    set(handles.traj,'XData',handles.x_hist(1,:), 'YData',handles.x_hist(2,:), 'ZData',handles.x_hist(3,:));
    dv = norm(handles.state(4:6));
    if dv < 80
        set(handles.dvLamp,'BackgroundColor',[0.7 1 0.7]);
    elseif dv < 150
        set(handles.dvLamp,'BackgroundColor',[1 1 0.5]);
    else
        set(handles.dvLamp,'BackgroundColor',[1 0.7 0.7]);
    end
    set(handles.dvLamp,'String',sprintf('ΔV: %.2f m/s',dv));
end

function [state, x_hist] = propagateToTime(t_target, x0, waypoints)
    n = 0.0011;
    t_step = 60;
    t_curr = 0;
    state = x0;
    x_hist = state;
    while t_curr < t_target
        state = propagateCWH(state, t_step, n);
        x_hist(:,end+1) = state;
        t_curr = t_curr + t_step;
    end
end

guidata(handles.fig,handles);
updatePlot();
