function [num_TMCs] = prepare_data(time_intervals, data_file)
    input_variables = load(data_file, 'train*');
    time_index = input_variables.train_x(:, 1);
    raw_x = input_variables.train_x(:, 2:end);
    
%     norm_raw_x = raw_x;
    
    %% data normalization (for the whole dataset)
    vec = raw_x;
    maxVec = 100; % find the maximum value of traffic speed
    minVec = 0; % find the minimum value of traffic speed
    norm_raw_x = ((vec - minVec)./(maxVec - minVec));
    
    %% alloc memory size to store training data
    num_intervals = time_intervals / 2;
    num_TMCs = size(norm_raw_x, 2);  % 15 TMCs in F3
    columns = 1 + num_TMCs * num_intervals;   % 6 * 15 = 90 cloumns + time index
    rows = size(norm_raw_x, 1) - num_intervals;
%     train_x = zeros(rows, columns);
%     train_x = zeros(rows - num_intervals, columns);

    train_x = zeros(floor(rows/4), columns);
    
    %% parallel generate training dataset
    parfor i = 1 + num_intervals:floor(rows/4) + num_intervals
        % need add time information, time index (t_0 - 1)
        % put (t_0 - 5, t_0 - 4, t_0 - 3, t_0 - 2, t_0 - 1) into one raw 
        train_x(i - num_intervals, :) = [time_index(i-1, 1), reshape(norm_raw_x(i - num_intervals:i - 1, :), 1, columns - 1)];
    end
    save('./data/training_data.mat', 'train_x');
end