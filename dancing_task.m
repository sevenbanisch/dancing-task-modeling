function [Obs_distance, agents, aggregates] = dancing_task(rounds, visualize, verbose)
    if nargin < 2
        visualize = 0;
    end

    if nargin < 3
        verbose = 0;
    end

    % -------------------------------
    % Event listeners
    % -------------------------------
    eventListeners = {};

    if verbose
        eventListeners{end+1} = verboseeventlistener();
    end

    % Definition of the environment
    env = struct('dmax', 20);
    
    % Definition of environment-agent-interactions
    moves([agent.avoid, agent.stay, agent.approach]) = [1, 0, -1];

    % Definition of the dyad
    dyad = construct_dyad();

    %'character', "avoidant" "neutral" "anxious" "disorganised"
    
    % Create dyadic agents
    A = dyad.A.index;
    B = dyad.B.index;
    agents{A} = feval(dyad.A.class, dyad.A, env);
    agents{B} = feval(dyad.B.class, dyad.B, env);

    % -------------------------------
    % Aggregates: only for non-bots
    % -------------------------------
    isBotA = isfield(dyad.A, 'class') && endsWith(lower(string(dyad.A.class)), "bot");
    isBotB = isfield(dyad.B, 'class') && endsWith(lower(string(dyad.B.class)), "bot");
    
    aggregates = struct();
    
    if ~isBotA
        aggregates.A = struct( ...
            'name', dyad.A.name, ...
            'sum_reward', 0, ...
            'mean_reward', NaN, ...
            'sum_distance_preference_diff', 0, ...
            'mean_distance_preference_diff', NaN, ...
            'sum_abs_distance_preference_diff', 0, ...
            'mean_abs_distance_preference_diff', NaN, ...
            'turns_until_preferredDistance', NaN, ...
            'n_turns', 0 ...
        );
    end
    
    if ~isBotB
        aggregates.B = struct( ...
            'name', dyad.B.name, ...
            'sum_reward', 0, ...
            'mean_reward', NaN, ...
            'sum_distance_preference_diff', 0, ...
            'mean_distance_preference_diff', NaN, ...
            'sum_abs_distance_preference_diff', 0, ...
            'mean_abs_distance_preference_diff', NaN, ...
            'turns_until_preferredDistance', NaN, ...
            'n_turns', 0 ...
        );
    end

    % Starting conditions
    distance = 10;
    
    % Initial actions
    lastActions(A) = agent.stay;
    lastActions(B) = agent.stay;
    
    % Observables
    nTurns = rounds * 2;
    
    Obs_distance = zeros(nTurns + 1, 1);
    Obs_distance(1) = distance;
    
    obsIndex = 1;

    notify_event(eventListeners, "simulation_started", struct( ...
        'dyad', dyad, ...
        'env', env ...
    ));
    
    
    % Loop
    for round = 1:rounds % Round
        notify_event(eventListeners, "round_started", struct( 'round', round ));
        for doer = [A B] % Turns
            % Agent roles (turn taking)
            if(doer == A)
                doneTo = B;
            else
                doneTo = A;            
            end
            
            % What the acting agent sees
            seenDistance = distance;
            seenOtherAction = lastActions(doneTo);

            % Action selection
            action = agents{doer}.act(distance, lastActions(doneTo));
            actionLabels = agent.actionLabels();
            
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
        
            % -------------------------------
            % Aggregates for non-bot agents
            % -------------------------------
            reward = NaN;
            
            if doer == A && ~isBotA
            
                reward = agents{doer}.preference(distance);
            
                distancePreferenceDiff = distance - dyad.A.delta;
                absDistancePreferenceDiff = abs(distancePreferenceDiff);
            
                aggregates.A.sum_reward = aggregates.A.sum_reward + reward;
                aggregates.A.sum_distance_preference_diff = ...
                    aggregates.A.sum_distance_preference_diff + distancePreferenceDiff;
                aggregates.A.sum_abs_distance_preference_diff = ...
                    aggregates.A.sum_abs_distance_preference_diff + absDistancePreferenceDiff;
            
                aggregates.A.n_turns = aggregates.A.n_turns + 1;
            
                if isnan(aggregates.A.turns_until_preferredDistance) && ...
                        distance == dyad.A.delta % abs(distance - dyad.A.delta) <= dyad.A.deltarange
            
                    aggregates.A.turns_until_preferredDistance = aggregates.A.n_turns;
                end
            
            elseif doer == B && ~isBotB
            
                reward = agents{doer}.preference(distance);
            
                distancePreferenceDiff = distance - dyad.B.delta;
                absDistancePreferenceDiff = abs(distancePreferenceDiff);
            
                aggregates.B.sum_reward = aggregates.B.sum_reward + reward;
                aggregates.B.sum_distance_preference_diff = ...
                    aggregates.B.sum_distance_preference_diff + distancePreferenceDiff;
                aggregates.B.sum_abs_distance_preference_diff = ...
                    aggregates.B.sum_abs_distance_preference_diff + absDistancePreferenceDiff;
            
                aggregates.B.n_turns = aggregates.B.n_turns + 1;
            
                if isnan(aggregates.B.turns_until_preferredDistance) && ...
                        distance == dyad.B.delta % abs(distance - dyad.B.delta) <= dyad.B.deltarange
            
                    aggregates.B.turns_until_preferredDistance = aggregates.B.n_turns;
                end
            
            end

            % Turn-by-turn output only for first agent
            event = struct( ...
                'round', round, ...
                'obsIndex', obsIndex, ...
                'doer', doer, ...
                'doneTo', doneTo, ...
                'env', env, ...
                'dyad', dyad, ...
                'agents', {agents}, ...
                'A', A, ...
                'B', B, ...
                'seenDistance', seenDistance, ...
                'seenOtherAction', seenOtherAction, ...
                'action', action, ...
                'lastDistance', lastDistance, ...
                'distance', distance, ...
                'reward', reward, ...
                'lastActions', lastActions, ...
                'aggregates', aggregates ...
            );
            
            notify_event(eventListeners, "step", event);

            % Reward
            agents{doer}.learn(distance, lastDistance, action, lastActions(doneTo));
        
            lastActions(doer) = action; % last choice of self
        
            % Model Observable
            obsIndex = obsIndex + 1;
            Obs_distance(obsIndex, 1) = distance;
        end % turns
        notify_event(eventListeners, "round_ended", struct( 'round', round));
    end % rounds
    

    notify_event(eventListeners, "simulation_ended", struct());

    %% Visualization
    if visualize
       plot_dancing_task(Obs_distance, dyad, env)
    end

    % -------------------------------
    % Finalize aggregates
    % -------------------------------
    if isfield(aggregates, 'A') && aggregates.A.n_turns > 0
        aggregates.A.mean_reward = ...
            aggregates.A.sum_reward / aggregates.A.n_turns;
    
        aggregates.A.mean_distance_preference_diff = ...
            aggregates.A.sum_distance_preference_diff / aggregates.A.n_turns;
    
        aggregates.A.mean_abs_distance_preference_diff = ...
            aggregates.A.sum_abs_distance_preference_diff / aggregates.A.n_turns;

        
    end
    
    if isfield(aggregates, 'B') && aggregates.B.n_turns > 0
        aggregates.B.mean_reward = ...
            aggregates.B.sum_reward / aggregates.B.n_turns;
    
        aggregates.B.mean_distance_preference_diff = ...
            aggregates.B.sum_distance_preference_diff / aggregates.B.n_turns;
    
        aggregates.B.mean_abs_distance_preference_diff = ...
            aggregates.B.sum_abs_distance_preference_diff / aggregates.B.n_turns;
    end
end

function notify_event(eventListeners, eventName, event)

    if isempty(eventListeners)
        return
    end

    for i = 1:numel(eventListeners)

        listener = eventListeners{i};

        switch string(eventName)

            case "simulation_started"
                listener.simulation_started(event);

            case "simulation_ended"
                listener.simulation_ended(event);

            case "round_started"
                listener.round_started(event);

            case "round_ended"
                listener.round_ended(event);

            case "step"
                listener.step(event);

            otherwise
                warning("Unknown event: %s", eventName);

        end

    end

end