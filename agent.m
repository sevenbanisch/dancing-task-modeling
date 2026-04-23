classdef agent < handle
    properties
        identity % Name of agent

        delta % Preferred distance
        deltarange % Tolerance window
        
        Q % Q-matrix
        beta = 8  % Action selection (Exploration)
        alpha = 0.5 % Q-learning (Geschwindigkeit der Anpassung an reward)
    end
    
    % Only actions
    properties (Constant)
        avoid = 1;
        stay = 2;
        approach = 3;
    end

    methods (Static)
        function actions = actions()
            actions = [agent.avoid, agent.stay, agent.approach];
        end

        function labels = actionLabels()
            labels = ["avoid", "stay", "approach"];
        end
    end

    methods
        % Constructor
        function obj = agent(individual, env)
            obj.identity = individual.name;
            obj.delta = individual.delta;
            obj.deltarange = individual.deltarange;
            obj.Q = zeros(length(agent.actions), env.dmax + 1, length(agent.actions)); 
        end

        % Returns a Gaussian reward for how close the distance between two points is to a desired value.
        % TODO: refactor preference function into this method
        function reward = preference(obj, distance)
            reward = preference(0, distance, obj.delta, obj.deltarange);
        end
        
        % Behavior
        function action = act(obj, distance, action_other)
            % Action selection
            expQ = exp(obj.beta * obj.Q(:, distance + 1, action_other)); % Note: distance+1 -> map distance to array index (distance=0 -> index=1)
            
            edges = cumsum(expQ)/sum(expQ);
            action = sum(rand > edges) + 1;
        end

        % Learning
        function learn(obj, distance, distance_previous, action_self, action_other) 
            % Reward
            r = obj.preference(distance); 
        
            % Q-learning
            obj.Q(action_self, distance_previous + 1, action_other) = (1 - obj.alpha) * obj.Q(action_self, distance_previous + 1, action_other) + obj.alpha * r;
        end

        % HELPER FUNCTIONS
        function displayQ(obj, action_other)
            % Set default values if arguments are not provided
            if nargin < 2
                action_other = agent.stay;
            end
        
            % Extract the matrix and transpose it
            A = squeeze(obj.Q(:, :, action_other))';
        
            % Create index column: 0, 1, 2, ...
            idx = (0:size(A,1)-1)';
        
            % Create table with column names
            T = array2table([idx A], ...
                'VariableNames', [{'#'}, cellstr(obj.actionLabels)]);
        
            % Display the result
            disp(T)
        
        end
    end
end