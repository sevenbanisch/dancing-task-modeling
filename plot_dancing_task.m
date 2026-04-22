function plot_dancing_task(Obs_d) % version for only one dynamic agent
    dmax = environment().dmax;
    figure(1)
    clf
    
    % -------------------------------
    % Main plot
    % -------------------------------
    ax1 = axes('Position', [0.10 0.11 0.68 0.815]);
    
    plot(ax1, Obs_d, 'LineWidth', 2, 'Color', dyad().A.color)
    ylim(ax1, [0 dmax])
    yticks(ax1, 0:1:dmax)
    hold(ax1, 'on')
    yline(ax1, dyad().A.delta, 'r--', 'Preferred distance ('+(dyad().A.name)+')', 'LineWidth', 2)
    yline(ax1, dyad().B.delta, 'r--', 'Preferred distance ('+(dyad().B.name)+')', 'LineWidth', 2, 'LabelVerticalAlignment', 'bottom')
    hold(ax1, 'off')
    
    legend(ax1, {'Distance'}, 'Location', 'best')
    set(ax1, 'FontSize', 14)
    
    % -------------------------------
    % Calculate rewards
    % -------------------------------
    y = linspace(0, dmax, 400).';
    reward = arrayfun(@(yy) preference(0, yy, dyad().A.delta, dyad().A.deltarange), y);
    reward = reward(:);
    reward(~isfinite(reward)) = 0;
    
    % -------------------------------
    % Right axis: small color bar
    % -------------------------------
    ax2 = axes('Position', [0.82 0.11 0.03 0.815]);
    
    imagesc(ax2, [0 1], [y(1) y(end)], reward)
    set(ax2, 'YDir', 'normal')
    ylim(ax2, [0 dmax])
    xlim(ax2, [0 1])
    
    % Disable labels on these axes
    xticks(ax2, [])
    yticks(ax2, [])
    set(ax2, 'Box', 'on', 'FontSize', 12)
    
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
    
    cmax = max(abs(reward));
    if cmax == 0
        cmax = 1;
    end
    clim(ax2, [-cmax cmax])
    
    % -------------------------------
    % Labels right
    % -------------------------------
    labelY = 0:1:dmax;
    labelReward = arrayfun(@(yy) preference(0, yy, dyad().A.delta, dyad().A.deltarange), labelY);
    
    for i = 1:numel(labelY)
        text(ax2, 1.15, labelY(i), sprintf('%.2f', labelReward(i)), ...
            'VerticalAlignment', 'middle', ...
            'HorizontalAlignment', 'left', ...
            'FontSize', 11, ...
            'Clipping', 'off');
    end
    
    text(ax2, 3.6, dmax/2, 'Reward', ...
        'Rotation', 90, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontSize', 13, ...
        'Clipping', 'off');
    
    linkaxes([ax1 ax2], 'y')
    set(gcf, 'WindowStyle', 'docked')

end