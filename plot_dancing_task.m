function plot_dancing_task(Obs_d, dyad, env) % version for only one dynamic agent
    figure(1)
    clf

    pref_mode = "normdif";
    
    % -------------------------------
    % Main plot
    % -------------------------------
    ax1 = axes('Position', [0.10 0.11 0.64 0.815]);
    
    plot(ax1, Obs_d, 'LineWidth', 2, 'Color', [0.5 0.5 0.5])
    ylim(ax1, [0 env.dmax])
    yticks(ax1, 0:1:env.dmax)
    hold(ax1, 'on')
    
    if dyad.A.delta == dyad.B.delta
        ls = '-';
    else
        ls = '--';
    end
    yline(ax1, dyad.A.delta, ls, ...
        ['Preferred distance (' char(dyad.A.name) ')'], ...
        'LineWidth', 2, ...
        'Color', dyad.A.color)
    
    yline(ax1, dyad.B.delta, '--', ...
        ['Preferred distance (' char(dyad.B.name) ')'], ...
        'LineWidth', 2, ...
        'LabelVerticalAlignment', 'bottom', ...
        'LabelHorizontalAlignment', 'left', ...
        'Color', dyad.B.color)
    
    
    hold(ax1, 'off')
    
    legend(ax1, {'Distance'}, 'Location', 'best')
    set(ax1, 'FontSize', 14)
    
    % -------------------------------
    % Calculate rewards
    % -------------------------------
    y = linspace(0, env.dmax, 400).';
    
    rewardA = arrayfun(@(yy) preference(0, yy, dyad.A.delta, dyad.A.deltarange,dyad.A.pref_mode), y);
    rewardA = rewardA(:);
    rewardA(~isfinite(rewardA)) = 0;
    
    rewardB = arrayfun(@(yy) preference(0, yy, dyad.B.delta, dyad.B.deltarange,dyad.B.pref_mode), y);
    rewardB = rewardB(:);
    rewardB(~isfinite(rewardB)) = 0;
    
    % gemeinsame Farbskalierung
    cmax = max(abs([rewardA; rewardB]));
    if cmax == 0
        cmax = 1;
    end
    
    % -------------------------------
    % Right side: two color bars
    % -------------------------------
    ax2 = axes('Position', [0.79 0.11 0.025 0.815]); % A
    imagesc(ax2, [0 1], [y(1) y(end)], rewardA)
    set(ax2, 'YDir', 'normal')
    ylim(ax2, [0 env.dmax])
    xlim(ax2, [0 1])
    xticks(ax2, [])
    yticks(ax2, [])
    set(ax2, 'Box', 'on', 'FontSize', 12)
    clim(ax2, [-cmax cmax])
    
    ax3 = axes('Position', [0.83 0.11 0.025 0.815]); % B
    imagesc(ax3, [0 1], [y(1) y(end)], rewardB)
    set(ax3, 'YDir', 'normal')
    ylim(ax3, [0 env.dmax])
    xlim(ax3, [0 1])
    xticks(ax3, [])
    yticks(ax3, [])
    set(ax3, 'Box', 'on', 'FontSize', 12)
    clim(ax3, [-cmax cmax])
    
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
    colormap(ax2, cmap)
    colormap(ax3, cmap)
    
    % -------------------------------
    % Labels above bars
    % -------------------------------
    text(ax2, 0.5, env.dmax + 0.6, char(dyad.A.name), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 11, ...
        'FontWeight', 'bold', ...
        'Color', dyad.A.color, ...
        'Clipping', 'off');
    
    text(ax3, 0.5, env.dmax + 0.6, char(dyad.B.name), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', ...
        'FontSize', 11, ...
        'FontWeight', 'bold', ...
        'Color', dyad.B.color, ...
        'Clipping', 'off');
    

    
    % -------------------------------
    % Link axes
    % -------------------------------
    linkaxes([ax1 ax2 ax3], 'y')
    %set(gcf, 'WindowStyle', 'docked')

end