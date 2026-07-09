% Returns a Gaussian reward for how close the distance between two points is to a desired value.
function reward = preference(xi, xj, delta, deltarange,mode)
    % xi,xj: positions (scalar or vector)
    % delta: preferred distance
    % deltarange: tolerance (controls width)

    d = norm(xi - xj);

    % original preference function
    if mode == "exp"        
        sigma = max(deltarange, eps)/2;          % width
        reward = 2*exp(-0.5*((d - delta)/sigma).^2)-1;  % in [0,1], peaks at d=delta
    elseif mode == "normdif"    % yet another alternative function, but non-linear
        difference = abs(d - delta);
        normed_difference = difference ./ deltarange;
        reward = (1 - normed_difference) ./ (1 + normed_difference);
    elseif mode == "abs"    % alternative (linear) preference function       
        difference = abs(d - delta);
        reward = 1 - difference ./ deltarange;
    else    
        reward = 0;
    end


    % 
    % difference = abs(d - delta);
    % %reward = 1 - difference ./ deltarange;
    % 
    % 

end