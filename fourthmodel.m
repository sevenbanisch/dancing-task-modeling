rounds = 100;
N = 2;
alpha = 0.1;
beta = 8;

d = 10;
dmax = 20;   % how to include that
delta = [1,5];
deltarange = 1;
actions = [-1,0,1];
nActions = length(actions);
Q = zeros(N,nActions,dmax+1,nActions);

lastChoices = [2,2];

Obs = zeros(rounds,1);
Obs(1,1) = d;

for round = 2:rounds

    % agent choice
    agentIX = randi(2);
    otherIX = 3-agentIX;
    %agentIX = 1;

    % action selection
    expQ = exp(beta * Q(agentIX,:,d+1,otherIX));
    choice = randsample(nActions,1,true,expQ);
    %cdfs = cumsum(expQ./sum(expQ,2),2);
    %for i = 1:nActions
    %    choice = find(cdfs(:) >= rand(), 1);
    %end

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
    r = 10*preference(0,d,delta(agentIX),deltarange)-5;
    %[d,r]

    % Q-learning
    co = lastChoices(otherIX);
    Q(agentIX, choice, dOld+1,co) = (1-alpha)*Q(agentIX, choice, dOld+1,co) + alpha * r;

    lastChoices(agentIX) = choice;

    % Model Observable
    Obs(round,1) = d;

end

figure(10)
plot(Obs,'LineWidth',2)
ylim([0,dmax])
legend({'Distance'}, 'Location','best');
set(gca,'FontSize',14)

