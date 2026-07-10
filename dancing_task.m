function [Obs_distance, agents, aggregates] = dancing_task(rounds, visualize, verbose)
    if nargin < 2
        visualize = 0;
    end

    if nargin < 3
        verbose = 0;
    end

    % Definition of the environment
    env = struct('dmax',  20);

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
            'steps_until_preferredDistance', NaN, ...
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
            'steps_until_preferredDistance', NaN, ...
            'n_turns', 0 ...
        );
    end

    % Starting conditions
    distance = 10;
    
    % Initial actions
    lastActions(A) = agent.stay;
    lastActions(B) = agent.stay;
    
    % Observables
    Obs_distance = zeros(rounds, 1);
    Obs_distance(1) = distance;

    if verbose
        fprintf('\nTurn-by-turn trace for first agent: %s\n', char(dyad.A.name));
        fprintf('--------------------------------------------------------------------------------------\n');
        fprintf('%-6s %-12s %-14s %-14s %-14s %-14s %-12s\n', ...
            'Round', 'Agent', 'Sees dist', 'Sees other', 'Final', 'New dist', 'Reward');
        fprintf('--------------------------------------------------------------------------------------\n');
    end
    
    % Loop
    for round = 2:rounds % Round
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

            % Reward of the acting agent at the new distance
            reward = agents{doer}.preference(distance);
        
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
            
                if isnan(aggregates.A.steps_until_preferredDistance) && ...
                        distance == dyad.A.delta % abs(distance - dyad.A.delta) <= dyad.A.deltarange
            
                    aggregates.A.steps_until_preferredDistance = aggregates.A.n_turns;
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
            
                if isnan(aggregates.B.steps_until_preferredDistance) && ...
                        distance == dyad.A.delta % abs(distance - dyad.B.delta) <= dyad.B.deltarange
            
                    aggregates.B.steps_until_preferredDistance = aggregates.B.n_turns;
                end
            
            end

            % Turn-by-turn output only for first agent
            if verbose && doer == A
                fprintf('%-6d %-12s %-14d %-14s %-14s %-14d %-12.4f', ...
                    round, ...
                    char(dyad.A.name), ...
                    seenDistance, ...
                    actionLabels(seenOtherAction), ...
                    actionLabels(action), ...
                    distance, ...
                    reward);
                input('', 's');
            end

            % Reward
            agents{doer}.learn(distance, lastDistance, action, lastActions(doneTo));
        
            lastActions(doer) = action; % last choice of self
        
            % Model Observable
            Obs_distance(round, 1) = distance;
        end % turns
    end % rounds
    

    if verbose
        fprintf('--------------------------------------------------------------------------------------\n\n');
    end

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