function plot_action_powerlaw(actionSeq, nGramSize)
    if nargin < 2
        nGramSize = 4;
    end
    
    % Flatten Obs_actions: [A1, B1, A2, B2, ...] -> single sequence
    %actionSeq = reshape(Obs_actions', 1, []);
    nActions = length(actionSeq);
    
    nGrams = containers.Map('KeyType', 'char', 'ValueType', 'any');
    
    % Only consider grams starting at odd positions (Agent A turns)
    for i = 1:2:(nActions - nGramSize + 1)
        gram = sprintf('%d', actionSeq(i:i+nGramSize-1));
        
        if isKey(nGrams, gram)
            nGrams(gram) = nGrams(gram) + 1;
        else
            nGrams(gram) = 1;
        end
    end
    
    grams = keys(nGrams);
    frequencies = cell2mat(values(nGrams));
    
    [sortedFreq, idx] = sort(frequencies, 'descend');
    sortedGrams = grams(idx);
    
    fprintf('\nTop 10 most frequent %d-grams:\n', nGramSize);
    fprintf('-----------------------------\n');
    for i = 1:min(10, length(sortedFreq))
        fprintf('%s: %d\n', sortedGrams{i}, sortedFreq(i));
    end
    fprintf('-----------------------------\n\n');
    
    frequencies = sortedFreq;
    ranks = 1:length(frequencies);
    
    figure(2);
    subplot(1,2,1)
    loglog(ranks, frequencies, 'o-', 'LineWidth', 1.5, 'MarkerSize', 4);
    xlabel('Rank', 'FontSize', 12);
    ylabel('Frequency', 'FontSize', 12);
    title(sprintf('%d-gram Action Frequencies (Power Law)', nGramSize), 'FontSize', 14);
    grid on;
    set(gca, 'FontSize', 14);
    
    hold on;
    p = polyfit(log(ranks'), log(frequencies'), 1);
    fitted = exp(p(2)) * ranks.^p(1);
    loglog(ranks, fitted, 'r--', 'LineWidth', 2);
    legend('Data', sprintf('Power law fit (\\alpha = %.2f)', -p(1)), 'FontSize', 10);
    hold off;

    for i = 1:min(6, length(sortedFreq))
        text(i, sortedFreq(i), sprintf(' %s', sortedGrams{i}), ...
            'VerticalAlignment', 'bottom', 'FontSize', 12);
    end

    subplot(1,2,2)
    plot(ranks, frequencies, 'o-', 'LineWidth', 1.5, 'MarkerSize', 4);
    xlabel('Rank', 'FontSize', 12);
    ylabel('Frequency', 'FontSize', 12);
    title(sprintf('%d-gram Action Frequencies', nGramSize), 'FontSize', 14);
    grid on;
    set(gca, 'FontSize', 14);

    for i = 1:min(6, length(sortedFreq))
        text(i, sortedFreq(i), sprintf(' %s', sortedGrams{i}), ...
            'VerticalAlignment', 'bottom', 'FontSize', 12);
    end
    


end
