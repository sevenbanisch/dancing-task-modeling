function [Obs_distance, agents] = dancing_task(rounds, visualize, verbose)
    if nargin < 2
        visualize = 0;
    end

    if nargin < 3
        verbose = 0;
    end

    % Definition of the environment
    env = struct('dmax',  22);

    % Definition of environment-agent-interactions
    moves([agent.avoid, agent.stay, agent.approach]) = [1, 0, -1];

    % Definition of the dyad
    dyad = struct( ...
        'A', struct( ...
            'index', 1, ...
            'name', "Alice", ...
            'delta', 1, ...
            'deltarange', 2, ...
            'pref_mode', "normdif", ...
            'color', "b", ...
            'class', 'agent' ...
        ), ...
        'B', struct( ...
            'index', 2, ...
            'name', "Neutral", ...
            'delta', 3, ... 
            'deltarange', 2, ...
            'pref_mode', "normdif", ...
            'color', [0 0.6 0], ...
            'class', 'paradigmbot', ... % Alternatives: bot, paradigmbot, ...
            'character', "neutral" ...
        ) ...
    );
    
    % Create dyadic agents
    A = dyad.A.index;
    B = dyad.B.index;
    agents{A} = feval(dyad.A.class, dyad.A, env);
    agents{B} = feval(dyad.B.class, dyad.B, env);

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
end