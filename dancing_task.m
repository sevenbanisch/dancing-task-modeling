function [Obs, agents] = dancing_task(rounds, visualize, verbose, dyad)
    if nargin < 2
        visualize = 0;
    end

    if nargin < 3
        verbose = 0;
    end

    % Definition of the dyad
    if nargin < 4 || isempty(dyad)
        dyad = construct_dyad();
    end

    % Definition of the environment
    env = struct('dmax', 20);
    
    % Definition of environment-agent-interactions
    moves([agent.avoid, agent.stay, agent.approach]) = [1, 0, -1];

    % Definition of the dyad
    dyad = construct_dyad();

    % -------------------------------
    % Event listeners
    % -------------------------------
    eventListeners = {};

    if verbose
        eventListeners{end+1} = verboseeventlistener(dyad, env);
    end

    %'character', "avoidant" "neutral" "anxious" "disorganised"
    
    % Create dyadic agents
    A = dyad.A.index;
    B = dyad.B.index;
    agents{A} = feval(dyad.A.class, dyad.A, env);
    agents{B} = feval(dyad.B.class, dyad.B, env);

    % -------------------------------
    % Bot detection: rewards are only computed for non-bots
    % -------------------------------
    isBotA = isfield(dyad.A, 'class') && endsWith(lower(string(dyad.A.class)), "bot");
    isBotB = isfield(dyad.B, 'class') && endsWith(lower(string(dyad.B.class)), "bot");
    
    % Starting conditions
    distance = 10;
    
    % Initial actions
    lastActions(A) = agent.stay;
    lastActions(B) = agent.stay;
    
    % Observables
    nTurns = rounds * 2;
    
    Obs = table( ...
        zeros(nTurns + 1, 1), ...      % round
        zeros(nTurns + 1, 1), ...      % turn
        zeros(nTurns + 1, 1), ...      % distance
        zeros(nTurns + 1, 1), ...      % activeAgentIndex
        NaN(nTurns + 1, 1), ...        % action
        NaN(nTurns + 1, 1), ...        % lastActionOther
        NaN(nTurns + 1, 1), ...        % reward
        'VariableNames', { ...
            'round', ...
            'turn', ...
            'distance', ...
            'activeAgentIndex', ...
            'action', ...
            'lastActionOther', ...
            'reward' ...
        } ...
    );
    
    % Start state
    Obs.round(1) = 0;
    Obs.turn(1) = 0;
    Obs.distance(1) = distance;
    Obs.activeAgentIndex(1) = NaN;
    
    obsIndex = 1;

    notify_event(eventListeners, "simulation_started", Obs, obsIndex);
    
    
    % Loop
    for round = 1:rounds % Round
        notify_event(eventListeners, "round_started");

        for doer = [A B] % Turns
            % Agent roles (turn taking)
            if(doer == A)
                doneTo = B;
                turn = 1;
                actorIsBot = isBotA;
            else
                doneTo = A;            
                turn = 2;
                actorIsBot = isBotB;
            end
            
            % What the acting agent sees
            seenOtherAction = lastActions(doneTo);

            % Action selection
            action = agents{doer}.act(distance, seenOtherAction);
            
            % constrain range
            if distance == env.dmax && action == agent.avoid % If action would lead out of range...
                action = agent.stay; % ... change it to stay 
                % @TODO: counter
            end
            if distance == 0 && action == agent.approach % If action would exceed maximal closeness...
                action = agent.stay; % .. change it to stay
                % @TODO: counter
            end
        
            % Environment dynamics
            lastDistance = distance; % Save previous distance
            distance = distance + moves(action); % Update distance
            
            if ~actorIsBot
                reward = agents{doer}.preference(distance);
            else
                reward = NaN;
            end


            % Reward
            agents{doer}.learn(distance, lastDistance, action, lastActions(doneTo));
        
            lastActions(doer) = action; % last choice of self
        
            % Model Observable
            obsIndex = obsIndex + 1;
            Obs.round(obsIndex) = round;
            Obs.turn(obsIndex) = turn;
            Obs.distance(obsIndex) = distance;
            Obs.activeAgentIndex(obsIndex) = doer;
            Obs.action(obsIndex) = action;
            Obs.lastActionOther(obsIndex) = seenOtherAction;
            Obs.reward(obsIndex) = reward;

            % Step completed: learning and observation update are done
            notify_event(eventListeners, "step", Obs, obsIndex);
        end % turns
        notify_event(eventListeners, "round_ended", Obs, obsIndex);
    end % rounds

    notify_event(eventListeners, "simulation_ended", Obs, obsIndex);

    %% Visualization
    if visualize
       plot_dancing_task(Obs.distance, dyad, env)
    end

end

function notify_event(eventListeners, eventName, Obs, obsIndex)

    if isempty(eventListeners)
        return
    end

    for i = 1:numel(eventListeners)

        listener = eventListeners{i};

        switch string(eventName)

            case "simulation_started"
                listener.simulation_started(Obs, obsIndex);

            case "simulation_ended"
                listener.simulation_ended(Obs, obsIndex);

            case "round_started"
                listener.round_started();

            case "round_ended"
                listener.round_ended(Obs, obsIndex);

            case "step"
                listener.step(Obs, obsIndex);

            otherwise
                warning("Unknown event: %s", eventName);

        end
    end
end