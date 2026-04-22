classdef agent < handle
    properties
        identity % Name of agent

        delta % Preferred distance
        deltarange % Tolerance window
        
        Q % Q-matrix
        beta = 8  % Action selection (Exploration)
        alpha = 0.5 % Q-learning (Geschwindigkeit der Anpassung an reward)
    end

    properties (Constant)
        avoid = 1;
        stay = 2;
        approach = 3;
        actions = [agent.avoid, agent.stay, agent.approach];
        moves = [+1, 0, -1];
    end

    methods
        % Constructor
        function obj = agent(individual)
            obj.identity = individual.name;
            obj.delta = individual.delta;
            obj.deltarange = individual.deltarange;
            obj.Q = zeros(length(agent.actions), environment().dmax + 1, length(agent.actions)); 
        end
        
        % Behavior
        function action = act(obj, distance, action_other)
            % Action selection
            expQ = exp(obj.beta * obj.Q(:, distance + 1, action_other)); % Note: distance+1 -> map distance to array index (distance=0 -> index=1)
            
            edges = cumsum(expQ)/sum(expQ);
            action = sum(rand > edges) + 1;
        end
        
        % Learning
        function learn(obj, distance, distance_old, action_self, action_other) 
            % Reward
            r = preference(0, distance, obj.delta, obj.deltarange); 
        
            % Q-learning
            obj.Q(action_self, distance_old + 1, action_other) = (1 - obj.alpha) * obj.Q(action_self, distance_old + 1, action_other) + obj.alpha * r;
        end
    end
end