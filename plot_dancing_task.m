function plot_dancing_task(Obs_d, dyad, env) % version for only one dynamic agent
    figure(1)
    clf

    % -------------------------------
    % Detect bots
    % -------------------------------
    isBotA = isfield(dyad.A, 'class') && endsWith(lower(string(dyad.A.class)), "bot");
    isBotB = isfield(dyad.B, 'class') && endsWith(lower(string(dyad.B.class)), "bot");

    % -------------------------------
    % Preference mode fallback
    % -------------------------------
    defaultPrefMode = "normdif";

    if isfield(dyad.A, 'pref_mode') && ~isempty(dyad.A.pref_mode)
        prefModeA = dyad.A.pref_mode;
    else
        prefModeA = defaultPrefMode;
    end

    if isfield(dyad.B, 'pref_mode') && ~isempty(dyad.B.pref_mode)
        prefModeB = dyad.B.pref_mode;
    else
        prefModeB = defaultPrefMode;
    end

    % -------------------------------
    % Main plot
    % -------------------------------
    ax1 = axes('Position', [0.10 0.11 0.64 0.815]);

    plot(ax1, Obs_d, 'LineWidth', 2, 'Color', [0.5 0.5 0.5])
    ylim(ax1, [0 env.dmax])
    yticks(ax1, 0:1:env.dmax)
    hold(ax1, 'on')

    % Preferred distance A: only if A is not a bot
    if ~isBotA
        if ~isBotB && dyad.A.delta == dyad.B.delta
            lsA = '-';
        else
            lsA = '--';
        end

        yline(ax1, dyad.A.delta, lsA, ...
            ['Preferred distance (' char(dyad.A.name) ')'], ...
            'LineWidth', 2, ...
            'Color', dyad.A.color)
    end

    % Preferred distance B: only if B is not a bot
    if ~isBotB
        yline(ax1, dyad.B.delta, '--', ...
            ['Preferred distance (' char(dyad.B.name) ')'], ...
            'LineWidth', 2, ...
            'LabelVerticalAlignment', 'bottom', ...
            'LabelHorizontalAlignment', 'left', ...
            'Color', dyad.B.color)
    end

    hold(ax1, 'off')

    legend(ax1, {'Distance'}, 'Location', 'best')
    set(ax1, 'FontSize', 14)

    % -------------------------------
    % Calculate rewards only for non-bots
    % -------------------------------
    y = linspace(0, env.dmax, 400).';

    rewards = {};
    names = {};
    colors = {};

    if ~isBotA
        rewardA = arrayfun(@(yy) preference( ...
            0, yy, dyad.A.delta, dyad.A.deltarange, prefModeA), y);

        rewardA = rewardA(:);
        rewardA(~isfinite(rewardA)) = 0;

        rewards{end+1} = rewardA;
        names{end+1} = char(dyad.A.name);
        colors{end+1} = dyad.A.color;
    end

    if ~isBotB
        rewardB = arrayfun(@(yy) preference( ...
            0, yy, dyad.B.delta, dyad.B.deltarange, prefModeB), y);

        rewardB = rewardB(:);
        rewardB(~isfinite(rewardB)) = 0;

        rewards{end+1} = rewardB;
        names{end+1} = char(dyad.B.name);
        colors{end+1} = dyad.B.color;
    end

    % -------------------------------
    % Colormap
    % -------------------------------
    n = 256;
    half = floor(n/2);

    red_to_yellow = [ ...
        ones(half,1), ...
        linspace(0,1,half)', ...
        zeros(half,1)];

    yellow_to_green = [ ...
        linspace(1,0,n-half)', ...
        ones(n-half,1), ...
        zeros(n-half,1)];

    cmap = [red_to_yellow; yellow_to_green];

    % -------------------------------
    % Right side: preference bars only for non-bots
    % -------------------------------
    linkedAxes = ax1;

    if ~isempty(rewards)

        allRewards = vertcat(rewards{:});
        cmax = max(abs(allRewards));

        if cmax == 0
            cmax = 1;
        end

        barX0 = 0.79;
        barWidth = 0.025;
        barGap = 0.04;

        for i = 1:numel(rewards)

            axBar = axes('Position', ...
                [barX0 + (i-1)*barGap 0.11 barWidth 0.815]);

            imagesc(axBar, [0 1], [y(1) y(end)], rewards{i})
            set(axBar, 'YDir', 'normal')
            ylim(axBar, [0 env.dmax])
            xlim(axBar, [0 1])
            xticks(axBar, [])
            yticks(axBar, [])
            set(axBar, 'Box', 'on', 'FontSize', 12)
            clim(axBar, [-cmax cmax])
            colormap(axBar, cmap)

            text(axBar, 0.5, env.dmax + 0.6, names{i}, ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'bottom', ...
                'FontSize', 11, ...
                'FontWeight', 'bold', ...
                'Color', colors{i}, ...
                'Clipping', 'off');

            linkedAxes = [linkedAxes axBar];

        end
    end

    % -------------------------------
    % Link axes
    % -------------------------------
    linkaxes(linkedAxes, 'y')
    set(gcf, 'WindowStyle', 'docked')

end