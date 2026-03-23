function displayQ(Q, agent, otherAction)

    % Set default values if arguments are not provided
    if nargin < 2
        agent = 1;
    end
    if nargin < 3
        otherAction = 2;
    end

    % Extract the matrix and transpose it
    A = squeeze(Q(agent, :, :, otherAction))';

    % Create index column: 0, 1, 2, ...
    idx = (0:size(A,1)-1)';

    % Create table with column names
    T = array2table([idx A], ...
        'VariableNames', {'#','avoid','stay','approach'});

    % Display the result
    disp(T)

end