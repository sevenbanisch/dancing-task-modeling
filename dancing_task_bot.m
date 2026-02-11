function [Obs_d] = dancing_task_bot(rounds, visualize)

% Lernparameter:
alpha = 0.1;
beta = 8;

% Spielfeld und Start
d = 10;
dmax = 20;

% Preference and Actions
delta = 3;
deltarange = 1;
actions = [-1,0,1];
nActions = length(actions);
Q = zeros(1,nActions,dmax+1,nActions);

lastChoices = [2,2];

Obs_d = zeros(rounds,1);
Obs_d(1,1) = d;

action_other = 2;

for round = 2:rounds

    %action_other = 1;
    %d = d+actions(action_other);

    % action selection
    expQ = exp(beta * Q(1,:,d+1,action_other));
    choice = randsample(nActions,1,true,expQ);

    % constrain range
    if d >= dmax && choice == 3
        choice = 2;
    end
    if d <= 0 && choice == 1
        choice = 2;
    end

    % Environment dynamics
    dOld = d;
    d = d+actions(choice);

    % Reward
    r = 10*preference(0,d,delta,deltarange)-5;
    %[d,r]

    % Q-learning
    co = action_other;
    Q(1, choice, dOld+1,co) = (1-alpha)*Q(1, choice, dOld+1,co) + alpha * r;

    lastChoices(1) = choice;

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