classdef rpoController < handle
    %RPOCONTROLLER Controller class for RPO simulation
    
    properties (Access = private)
        % Simulation parameters
        MeanMotion
        CurrentTime
        TimeStep
        
        % State variables
        CurrentState
        Waypoints
        TotalDeltaV
        
        % Control parameters
        StationKeepingEnabled
        Kp
        Kd
    end
    
    methods
        function obj = rpoController(meanMotion)
            % Constructor
            obj.MeanMotion = meanMotion;
            obj.CurrentTime = 0;
            obj.TimeStep = 60;  % 1 minute
            obj.TotalDeltaV = 0;
            obj.StationKeepingEnabled = false;
            obj.Kp = 0.01;
            obj.Kd = 0.1;
        end
        
        function setInitialState(obj, initialState)
            % Set initial state
            obj.CurrentState = initialState;
        end
        
        function setWaypoints(obj, waypoints)
            % Set waypoints
            obj.Waypoints = waypoints;
        end
        
        function [state, deltaV] = propagateStep(obj)
            % Propagate state one time step
            
            % Get current waypoint
            currentWP = obj.getCurrentWaypoint();
            
            if ~isempty(currentWP)
                % Calculate required deltaV to reach waypoint
                [dV1, dV2] = twoImpulseCWH(obj.CurrentState, currentWP, obj.TimeStep, obj.MeanMotion);
                
                % Apply first impulse
                obj.CurrentState(4:6) = obj.CurrentState(4:6) + dV1;
                deltaV = norm(dV1);
                
                % Propagate state
                obj.CurrentState = propagateCWH(obj.CurrentState, obj.TimeStep, obj.MeanMotion);
                
                % Apply second impulse
                obj.CurrentState(4:6) = obj.CurrentState(4:6) + dV2;
                deltaV = deltaV + norm(dV2);
            else
                % Natural motion
                obj.CurrentState = propagateCWH(obj.CurrentState, obj.TimeStep, obj.MeanMotion);
                deltaV = 0;
            end
            
            % Apply station keeping if enabled
            if obj.StationKeepingEnabled
                u = forcedMotion(obj.CurrentState, obj.MeanMotion, obj.Kp, obj.Kd);
                obj.CurrentState(4:6) = obj.CurrentState(4:6) + u * obj.TimeStep;
                deltaV = deltaV + norm(u * obj.TimeStep);
            end
            
            % Update time and total deltaV
            obj.CurrentTime = obj.CurrentTime + obj.TimeStep;
            obj.TotalDeltaV = obj.TotalDeltaV + deltaV;
            
            % Return current state and deltaV
            state = obj.CurrentState;
        end
        
        function waypoint = getCurrentWaypoint(obj)
            % Get current waypoint based on time
            if isempty(obj.Waypoints)
                waypoint = [];
                return;
            end
            
            % Find waypoint with time closest to current time
            [~, idx] = min(abs(obj.Waypoints(:,4) - obj.CurrentTime));
            waypoint = obj.Waypoints(idx,1:3)';
        end
        
        function enableStationKeeping(obj, enabled)
            % Enable/disable station keeping
            obj.StationKeepingEnabled = enabled;
        end
        
        function setControlGains(obj, kp, kd)
            % Set PD control gains
            obj.Kp = kp;
            obj.Kd = kd;
        end
        
        function reset(obj)
            % Reset controller
            obj.CurrentTime = 0;
            obj.TotalDeltaV = 0;
        end
    end
end 