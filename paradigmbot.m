classdef paradigmbot < bot

    properties
        character = "neutral"   % "neutral", "anxious", "avoidant", "disorganised"
    end

    methods

        function obj = paradigmbot(individual, env)
            obj@bot(individual, env);

            if isfield(individual, "character") && ~isempty(individual.character)
                obj.character = string(individual.character);
            else
                warning("individual.character for paradigmbot not found or empty. Falling back to neutral.");
                obj.character = "neutral";
            end
        end

        function action = act(obj, ~, action_other)

            switch obj.character

                case {"neutral", "reciprocal", "no_bias"}
                    action = action_other;

                case "anxious"
                    switch action_other
                        case agent.approach
                            action = agent.approach;

                        case agent.avoid
                            if rand < 0.7
                                action = agent.approach;
                            else
                                action = agent.avoid;
                            end

                        case agent.stay
                            action = agent.stay;
                    end

                case "avoidant"
                    switch action_other
                        case agent.avoid
                            action = agent.avoid;

                        case agent.approach
                            if rand < 0.7
                                action = agent.avoid;
                            else
                                action = agent.approach;
                            end

                        case agent.stay
                            action = agent.stay;
                    end

                case {"disorganised", "disorganized"}
                    switch action_other
                        case agent.approach
                            if rand < 0.5
                                action = agent.approach;
                            else
                                action = agent.avoid;
                            end

                        case agent.avoid
                            if rand < 0.5
                                action = agent.avoid;
                            else
                                action = agent.approach;
                            end

                        case agent.stay
                            action = agent.stay;
                    end

                otherwise
                    warning("Unknown paradigmbot character '%s'. Falling back to neutral.", obj.character);
                    action = action_other;

            end

        end

        function learn(~, ~, ~, ~, ~)
            % Rule-based bot: no learning.
        end

    end

end