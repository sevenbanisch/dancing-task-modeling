function [Obs_d, Q] = dancing_task_sven(rounds, visualize)

    N = 2;
    pref_mode = "exp";

    % Lernparameter
    alpha = 0.25; % Q learning
    beta = 8; % action selection
    
    % Spielfeld und Start
    d = 10; % distance to other (initial)
    dmax = 22; % maximum distance
    
    % Preference
    % delta = 0; % preferred distance to other
    % deltarange = 2; % tolerance
    delta = [1,12];
    deltarange = 3;

    % Actions
    avoid = 1;
    stay = 2;
    approach = 3;
    actions = [avoid, stay, approach];
    nActions = length(actions);
    moves(approach) = -1; % decrease distance by one step
    moves(stay) = 0;
    moves(avoid) = +1; % increase distance by one step
    
    %% Initialize Q matrix (first dim: agent; here: only S)
    Q = zeros(N, nActions, dmax+1, nActions); 
    % Alternative initial conditions
    % Q = -ones(1, nActions, dmax+1, nActions); 
    
    %% Initial actions
    lastChoices = [stay, stay]; 
    action_other = stay; % The action of the other is fixed to (why not lastChoices(2) ?)

    
    %% Observables
    Obs_d = zeros(rounds, 1);
    Obs_d(1, 1) = d;
    
    % Loop
    for round = 2:rounds

        %% A: Agent choice (random turn taking)
        agentIX = randi(2);
        otherIX = 3-agentIX;
    
        %% B: Action selection
        expQ = exp(beta * Q(agentIX,:,d+1,otherIX));
        %choice = randsample(nActions,1,true,expQ);
        cdfs = cumsum(expQ./sum(expQ,2),2);
        for i = 1:nActions
           choice = find(cdfs(:) >= rand(), 1);
        end
        
        % constrain range
        if d == dmax && choice == avoid % If action would lead out of range...
            choice = stay; % ... change it to stay 
        end
        if d == 0 && choice == approach % If action would exceed maximal closeness...
            choice = stay; % .. change it to stay
        end
    
        %% C: Environment dynamics
        %[d,choice,moves(choice)]
        dOld = d; % Previous distance
        d = d + moves(choice); % Update distance
        
        %feedback_other = -1; % Signaling dissatisfaction
        %feedback_other = 1; % Signaling satisfaction
        %feedback_other = randi(3)-2; % Random Signaling 
    
        %% D: Rewards
        rSelf = preference(0, d, delta(agentIX), deltarange,pref_mode);
        %rOther = feedback_other;

        %mu = 0.5;
        %r = mu * rSelf + (1-mu)*rOther;
        r = rSelf;

      
        %% E: Q-learning
        co = lastChoices(otherIX);
        Q(agentIX, choice, dOld+1,co) = (1-alpha)*Q(agentIX, choice, dOld+1,co) + alpha * r;

        lastChoices(agentIX) = choice;
    
        % Model Observable
        Obs_d(round, 1) = d;
    
        % % "Hack": change distance to other at t=100
        % if((round == 100) && (d == delta))
        %     d = 7;
        % 
        % 
        % end

    end % rounds
    
    disp(squeeze(Q(1, :, :, 1)))

    %% Visualization
    if visualize
        figure(1)
        clf
        
        % -------------------------------
        % Main plot
        % -------------------------------
        ax1 = axes('Position',[0.10 0.11 0.68 0.815]);
        
        plot(ax1, Obs_d, 'LineWidth', 2)
        ylim(ax1, [0 dmax])
        yticks(ax1, 0:1:dmax)
        hold(ax1, 'on')
        yline(ax1, delta(1), 'r--', 'Alice', 'LineWidth', 2)
        yline(ax1, delta(2), 'g--', 'Bob', 'LineWidth', 2)
        hold(ax1, 'off')
        
        legend(ax1, {'Distance'}, 'Location', 'best')
        set(ax1, 'FontSize', 14)
        
        % -------------------------------
        % Calculate rewards
        % -------------------------------
        y = linspace(0, dmax, 400).';
        reward = arrayfun(@(yy) preference(0, yy, delta(1), deltarange,pref_mode), y);
        reward = reward(:);
        reward(~isfinite(reward)) = 0;
        
        % -------------------------------
        % Right axis: small color bar
        % -------------------------------
        ax2 = axes('Position',[0.82 0.11 0.03 0.815]);

        % Reward as vertical color bar
        imagesc(ax2, [0 1], [y(1) y(end)], reward)
        set(ax2, 'YDir', 'normal')
        ylim(ax2, [0 dmax])
        xlim(ax2, [0 1])

        % Diasable labels on these axes
        xticks(ax2, [])
        yticks(ax2, [])
        set(ax2, 'Box', 'on', 'FontSize', 12)
        
        % -------------------------------
        % Colormap: negative = red, 0 = yellow, positive = green
        % -------------------------------
        n = 256;
        half = floor(n/2);
        
        red_to_yellow = [ ...
            ones(half,1), ...
            linspace(0,1,half)', ...
            zeros(half,1)];
        
        yellow_to_green = [ ...
            linspace(1,0,n-half)', ...
            ones(n-half,1), ...
            zeros(n-half,1)];
        
        cmap = [red_to_yellow; yellow_to_green];
        colormap(ax2, cmap)
        
        % Color scale symmetric around 0
        cmax = max(abs(reward));
        if cmax == 0
            cmax = 1;
        end
        clim(ax2, [-cmax cmax])
        
        % -------------------------------
        % Labels right
        % -------------------------------
        labelY = 0:1:dmax;
        labelReward = arrayfun(@(yy) preference(0, yy, delta(1), deltarange,pref_mode), labelY);
        
        for i = 1:numel(labelY)
            text(ax2, 1.15, labelY(i), sprintf('%.2f', labelReward(i)), ...
                'VerticalAlignment', 'middle', ...
                'HorizontalAlignment', 'left', ...
                'FontSize', 11, ...
                'Clipping', 'off');
        end
        
        % Labels
        text(ax2, 3.6, dmax/2, 'Reward', ...
            'Rotation', 90, ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'middle', ...
            'FontSize', 13, ...
            'Clipping', 'off');
        
        % -------------------------------
        % Link axes
        % -------------------------------
        linkaxes([ax1 ax2], 'y')
        
        %set(gcf, 'WindowStyle', 'docked')
    end

end