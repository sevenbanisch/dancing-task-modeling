function y = randsample(n, k, replace, weights)
%RANDSAMPLE Toolbox-free replacement (partial)
%   y = randsample(n, k, replace, weights)
%
% Supports:
%   - scalar n → sample from 1:n
%   - with/without replacement
%   - optional weights (only for replace = true)

    if nargin < 3
        replace = false;
    end

    if nargin < 4 || isempty(weights)
        weights = [];
    end

    % population = 1:n
    population = 1:n;

    % --- No weights ---
    if isempty(weights)
        if replace
            y = population(randi(n, k, 1));
        else
            if k > n
                error('Sample size exceeds population without replacement.');
            end
            idx = randperm(n, k);
            y = population(idx);
        end
        return;
    end

    % --- With weights (only with replacement supported) ---
    if ~replace
        error('Weighted sampling without replacement not implemented.');
    end

    w = weights(:);
    if numel(w) ~= n
        error('Weights must have length n.');
    end

    s = sum(w);
    if s == 0
        % fallback to uniform
        y = population(randi(n, k, 1));
        return;
    end

    w = w / s;
    edges = cumsum(w);

    r = rand(k,1);
    y = zeros(k,1);

    for i = 1:k
        y(i) = find(r(i) <= edges, 1);
    end
end