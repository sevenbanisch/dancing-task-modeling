classdef bot < agent
    methods
        function obj = agent(individual, ~)
            obj.identity = individual.name;
        end
        
        % Static agent
        function action = act(~, ~, ~)
            action = agent.stay;
        end

        function learn(~, ~, ~, ~, ~) 
        end
    end
end