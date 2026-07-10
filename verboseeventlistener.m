classdef verboseeventlistener < eventlistener

    methods

        function simulation_started(~, event)

            fprintf('\nTurn-by-turn trace for first agent: %s\n', ...
                char(event.dyad.A.name));

            fprintf('--------------------------------------------------------------------------------------\n');

            fprintf('%-6s %-12s %-14s %-14s %-14s %-14s %-12s\n', ...
                'Round', ...
                'Agent', ...
                'Sees dist', ...
                'Sees other', ...
                'Final', ...
                'New dist', ...
                'Reward');

            fprintf('--------------------------------------------------------------------------------------\n');

        end

        function step(~, event)

            % Turn-by-turn output only for first agent
            if event.doer == event.A

                actionLabels = agent.actionLabels();

                fprintf('%-6d %-12s %-14d %-14s %-14s %-14d %-12.4f', ...
                    event.round, ...
                    char(event.dyad.A.name), ...
                    event.seenDistance, ...
                    actionLabels(event.seenOtherAction), ...
                    actionLabels(event.action), ...
                    event.distance, ...
                    event.reward);

                input('', 's');

            end

        end

        function simulation_ended(~, ~)

            fprintf('--------------------------------------------------------------------------------------\n\n');

        end

    end

end