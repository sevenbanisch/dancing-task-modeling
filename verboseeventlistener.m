classdef verboseeventlistener < eventlistener

    properties
        dyad
        env
    end

    methods

        function obj = verboseeventlistener(dyad, env)
            obj.dyad = dyad;
            obj.env = env;
        end

        function simulation_started(obj, ~, ~)

            fprintf('\nTurn-by-turn trace for first agent: %s\n', ...
                char(obj.dyad.A.name));

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

        function step(obj, Obs, obsIndex)

            row = Obs(obsIndex, :);

            % Only first agent
            if row.activeAgentIndex ~= obj.dyad.A.index
                return
            end

            actionLabels = agent.actionLabels();

            seenDistance = Obs.distance(obsIndex - 1);
            seenOtherAction = row.lastActionOther;
            action = row.action;
            reward = row.reward;

            fprintf('%-6d %-12s %-14d %-14s %-14s %-14d %-12.4f', ...
                row.round, ...
                char(obj.dyad.A.name), ...
                seenDistance, ...
                actionLabels(seenOtherAction), ...
                actionLabels(action), ...
                row.distance, ...
                reward);

            input('', 's');

        end

        function simulation_ended(~, ~, ~)

            fprintf('--------------------------------------------------------------------------------------\n\n');

        end

    end

end