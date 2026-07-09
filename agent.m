classdef agent < handle
    properties
        identity % Name of agent

        delta % Preferred distance
        deltarange % Tolerance window
        pref_mode = "normdif" % mode of the preference function ("exp", "normdif", "abs")
        
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
            obj.pref_mode
            reward = preference(0, distance, obj.delta, obj.deltarange, obj.pref_mode);
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
        
            colWidth = 16;
            idxWidth = 6;
        
            selfActions  = [agent.avoid, agent.stay, agent.approach];
            otherActions = [agent.avoid, agent.stay, agent.approach];
        
            selfLabels  = ["self.avoid", "self.stay", "self.approach"];
            otherLabels = ["other avoid", "other stay", "other approach"];
        
            fmtCell = ['%-' num2str(colWidth) 's'];
            fmtIdx  = ['%-' num2str(idxWidth) 's'];
        
            % ------------------------------------------------------------
            % Case 1: action_other is provided -> old compact table
            % ------------------------------------------------------------
            if nargin >= 2
        
                A = squeeze(obj.Q(:, :, action_other))';
                idx = (0:size(A, 1)-1)';
        
                T = array2table([idx A], ...
                    'VariableNames', [{'#'}, cellstr(["avoid", "stay", "approach"])]);
        
                disp(T)
                return
            end
        
            % ------------------------------------------------------------
            % Case 2: no action_other provided -> grouped display
            % ------------------------------------------------------------
            nDistances = size(obj.Q, 2);
        
            fprintf('\n')
        
            % First header row: other-action groups
            fprintf(fmtIdx, '#')
        
            for o = 1:3
                groupWidth = 3 * colWidth;
                label = char(otherLabels(o));
        
                padding = groupWidth - strlength(label);
                leftPad = floor(padding / 2);
                rightPad = ceil(padding / 2);
        
                fprintf('%s%s%s', ...
                    repmat(' ', 1, leftPad), ...
                    label, ...
                    repmat(' ', 1, rightPad));
            end
        
            fprintf('\n')
        
            % Second header row: self actions
            fprintf(fmtIdx, '')
        
            for o = 1:3
                for s = 1:3
                    fprintf(fmtCell, char(selfLabels(s)))
                end
            end
        
            fprintf('\n')
        
            % Separator
            fprintf('%s\n', repmat('-', 1, idxWidth + 9 * colWidth))
        
            % Data rows
            for d = 1:nDistances
        
                fprintf(fmtIdx, sprintf('%d', d - 1))
        
                for o = 1:3
                    for s = 1:3
        
                        val = obj.Q(selfActions(s), d, otherActions(o));
        
                        % Robust formatting: number -> string -> fixed-width cell
                        fprintf(fmtCell, sprintf('%.4f', val))
        
                    end
                end
        
                fprintf('\n')
            end
        
            fprintf('\n')
        
        end
        %

    end
end