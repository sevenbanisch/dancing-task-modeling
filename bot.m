classdef bot < agent
    methods
        function obj = bot(individual, env)
            obj@agent(individual, env);
        end
        
        % Static agent
        function action = act(~, ~, ~)
            action = agent.stay;
        end

        function learn(~, ~, ~, ~, ~) 
        end
    end
end