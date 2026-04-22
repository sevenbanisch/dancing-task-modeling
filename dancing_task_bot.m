function [Obs_distance] = dancing_task_bot(rounds, visualize)
    if nargin < 2
        visualize = 0;
    end

    % Create dyadic agents
    A = dyad().A.index;
    B = dyad().B.index;
    agents{A} = agent(dyad().A);
    agents{B} = bot(dyad().B);

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
            if distance == environment().dmax && action == agent.avoid % If action would lead out of range...
                action = agent.stay; % ... change it to stay 
            end
            if distance == 0 && action == agent.approach % If action would exceed maximal closeness...
                action = agent.stay; % .. change it to stay
            end
        
            % Environment dynamics
            lastDistance = distance; % Save previous distance
            distance = distance + agent.moves(action); % Update distance
        
            % Reward
            agents{doer}.learn(distance, lastDistance, action, lastActions(doneTo));
        
            lastActions(doer) = action; % last choice of self
        
            % Model Observable
            Obs_distance(round, 1) = distance;
        end % turns
    end % rounds
    
    %% Visualization
    if visualize
       plot_dancing_task(Obs_distance)
    end
end