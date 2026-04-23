function [Obs_distance, agents] = dancing_task_bot(rounds, visualize)
    if nargin < 2
        visualize = 0;
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
            'delta', 3, ...
            'deltarange', 2, ...
            'color', "b", ...
            'class', 'agent' ...
        ), ...
        'B', struct( ...
            'index', 2, ...
            'name', "Bob", ...
            'delta', NaN, ... % Bot
            'deltarange', NaN, ... %Bot
            'color', [0 0.6 0], ...
            'class', 'bot' ...
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
    
    % Loop
    for round = 2:rounds % Round
        for doer = [A B] % Turns
            % Agent roles (turn taking)
            if(doer == A)
                doneTo = B;
            else
                doneTo = A;            
            end
            
            % Action selection
            action = agents{doer}.act(distance, lastActions(doneTo));
            
            % constrain range
            if distance == env.dmax && action == agent.avoid % If action would lead out of range...
                action = agent.stay; % ... change it to stay 
            end
            if distance == 0 && action == agent.approach % If action would exceed maximal closeness...
                action = agent.stay; % .. change it to stay
            end
        
            % Environment dynamics
            lastDistance = distance; % Save previous distance
            distance = distance + moves(action); % Update distance
        
            % Reward
            agents{doer}.learn(distance, lastDistance, action, lastActions(doneTo));
        
            lastActions(doer) = action; % last choice of self
        
            % Model Observable
            Obs_distance(round, 1) = distance;
        end % turns
    end % rounds
    
    %% Visualization
    if visualize
       plot_dancing_task(Obs_distance, dyad, env)
    end
end