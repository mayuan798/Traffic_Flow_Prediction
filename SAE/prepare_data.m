function [num_TMCs] = prepare_data(time_intervals, data_file)
    input_variables = load(data_file, 'train*');
    raw_x = input_variables.train_x(:, 2:end);
    
    %% do data normalization
    vec = raw_x;
    maxVec = max(max(vec));
    minVec = min(min(vec));
    norm_raw_x = ((vec - minVec)./(maxVec - minVec));
    
    %% alloc memory size to store training data
    num_intervals = time_intervals / 2;
    num_TMCs = size(norm_raw_x, 2);  % 15 TMCs in F3
    columns = num_TMCs * num_intervals;   % 6 * 15 = 90 cloumns
    rows = size(norm_raw_x, 1) - num_intervals;
%     train_x = zeros(rows, columns);
    train_x = zeros(rows, columns);
    
    %% parallel generate training dataset
    parfor i = 1 + num_intervals:rows
        train_x(i - num_intervals, :) = reshape(norm_raw_x(i - num_intervals:i - 1, :), 1, columns);
    end
    save('./data/training_data.mat', 'train_x');
end