function result = dt_simulation()
    nSim   = 10;
    nSteps = 200;

    turnsA = NaN(nSim, 1);
    turnsB = NaN(nSim, 1);

    for i = 1:nSim
        [Obs, agents] = dancing_task(nSteps);
        aggregates = aggregate_dancing_task(Obs, agents);

        if isfield(aggregates, 'A')
            turnsA(i) = aggregates.A.turns_until_preferredDistance;
        end

        if isfield(aggregates, 'B')
            turnsB(i) = aggregates.B.turns_until_preferredDistance;
        end
    end

    result.n_simulations = nSim;
    result.n_steps       = nSteps;

    result.A.turns_until_preferredDistance = turnsA;
    result.A.mean_turns_until_preferredDistance = ...
        mean(turnsA, 'omitnan');
    result.A.std_turns_until_preferredDistance = ...
        std(turnsA, 'omitnan');
    result.A.n_reached = sum(~isnan(turnsA));

    result.B.turns_until_preferredDistance = turnsB;
    result.B.mean_turns_until_preferredDistance = ...
        mean(turnsB, 'omitnan');
    result.B.std_turns_until_preferredDistance = ...
        std(turnsB, 'omitnan');
    result.B.n_reached = sum(~isnan(turnsB));

    fprintf('Agent A: Mittelwert = %.2f, SD = %.2f, erreicht = %d/%d\n', ...
        result.A.mean_turns_until_preferredDistance, ...
        result.A.std_turns_until_preferredDistance, ...
        result.A.n_reached, nSim);

    fprintf('Agent B: Mittelwert = %.2f, SD = %.2f, erreicht = %d/%d\n', ...
        result.B.mean_turns_until_preferredDistance, ...
        result.B.std_turns_until_preferredDistance, ...
        result.B.n_reached, nSim);
end