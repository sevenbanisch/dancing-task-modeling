function aggregates = aggregate_dancing_task(Obs, agents)

    aggregates = struct();

    agentIndices = unique(Obs.activeAgentIndex);
    agentIndices = agentIndices(agentIndices > 0); % ignore start row (-1)

    for k = 1:numel(agentIndices)

        agentIndex = agentIndices(k);
        ag = agents{agentIndex};

        % Skip bots
        if isa(ag, 'bot')
            continue
        end

        rows = Obs.activeAgentIndex == agentIndex;
        S = Obs(rows, :);

        if isempty(S)
            continue
        end

        distancePreferenceDiff = S.distance - ag.delta;
        absDistancePreferenceDiff = abs(distancePreferenceDiff);

        reachedPreferredDistance = S.distance == ag.delta;
        firstPreferredIdx = find(reachedPreferredDistance, 1, 'first');

        turnsUntilPreferredDistance = NaN;

        if ~isempty(firstPreferredIdx)
            turnsUntilPreferredDistance = firstPreferredIdx;
        end

        key = agent_key(agentIndex);

        aggregates.(key) = struct( ...
            'index', agentIndex, ...
            'name', get_agent_name(ag), ...
            'sum_reward', sum(S.reward, 'omitnan'), ...
            'mean_reward', mean(S.reward, 'omitnan'), ...
            'sum_distance_preference_diff', sum(distancePreferenceDiff, 'omitnan'), ...
            'mean_distance_preference_diff', mean(distancePreferenceDiff, 'omitnan'), ...
            'sum_abs_distance_preference_diff', sum(absDistancePreferenceDiff, 'omitnan'), ...
            'mean_abs_distance_preference_diff', mean(absDistancePreferenceDiff, 'omitnan'), ...
            'turns_until_preferredDistance', turnsUntilPreferredDistance, ...
            'n_turns', height(S) ...
        );

    end

end


function key = agent_key(agentIndex)

    if agentIndex == 1
        key = 'A';
    elseif agentIndex == 2
        key = 'B';
    else
        key = sprintf('agent%d', agentIndex);
    end

end


function name = get_agent_name(ag)

    if isprop(ag, 'name')
        name = ag.name;
    elseif isprop(ag, 'identity')
        name = ag.identity;
    else
        name = "";
    end

end