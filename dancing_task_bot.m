function [Obs_d] = dancing_task_bot(rounds, visualize)

    % Lernparameter:
    alpha = 0.1; % Q learning
    beta = 8; % action selection
    
    % Spielfeld und Start
    d = 10; % distance to other (initial)
    dmax = 20; % maximum distance
    
    % Preference and Actions
    delta = 3; % preferred distance to other
    deltarange = 1; % tolerance
    actions = [-1, 0, 1]; % avoid, stay, approach (the other)
    nActions = length(actions);
    Q = zeros(1, nActions, dmax+1, nActions); % Initialize Q matrix (first dim: agent; here: only S)
    
    % Initial actions
    lastChoices = [2,2];
    action_other = find(actions == 0); % The action of the other is fixed to 
    
    % Observables
    Obs_d = zeros(rounds,1);
    Obs_d(1,1) = d;
    
    % Loop
    for round = 2:rounds
    
        %action_other = 1;
        %d = d+actions(action_other);
    
        % action selection
        expQ = exp(beta * Q(1,:,d+1,action_other)); % Note: d+1 -> map distance to array index (d=0 -> index=1)
        choice = randsample(nActions,1,true,expQ); % Choose action depending on Q values
    
        % constrain range
        if d >= dmax && actions(choice) == +1 % If action would lead out of range...
            choice = find(actions == 0); % ... change it to stay 
        end
        if d <= 0 && choice == 1 % If action would exceed maximal closeness...
            choice = find(actions == 0); % .. change it to stay
        end
    
        % Environment dynamics
        dOld = d; 
        d = d + actions(choice);
    
        % Reward
        r = 10 * preference(0,d,delta,deltarange) - 5; % Why are those parameters (10, -5) not in the preference function?
        %[d,r]
    
        % Q-learning
        co = action_other;
        Q(1, choice, dOld+1, co) = (1-alpha) * Q(1, choice, dOld+1, co) + alpha * r;
    
        lastChoices(1) = choice; % last choice of self
    
        % Model Observable
        Obs_d(round,1) = d;
    
    
    end % rounds
    
    %% Visualization
    if visualize
    
        figure(10)
        plot(Obs_d,'LineWidth',2)
        ylim([0,dmax])
        legend({'Distance'}, 'Location','best');
        set(gca,'FontSize',14)
    
    end
end