% Returns a Gaussian reward for how close the distance between two points is to a desired value.
function reward = preference(xi, xj, delta, deltarange)
    % xi,xj: positions (scalar or vector)
    % delta: preferred distance
    % deltarange: tolerance (controls width)
    d = norm(xi - xj);

    % original preference function
    %sigma = max(deltarange, eps)/2;          % width
    %reward = exp(-0.5*((d - delta)/sigma).^2);  % in [0,1], peaks at d=delta

    % alternative (linear) preference function
    difference = abs(d - delta);
    reward = 1 - difference ./ deltarange;
end