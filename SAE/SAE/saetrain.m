function sae = saetrain(sae, x, opts)
    fid = fopen('./training_record.txt', 'w');
    error_history = {1, numel(sae.ae)};
    loss_history = {1, numel(sae.ae)};
    eltime = [1, numel(sae.ae)];
    num_history_L = 100;
    for i = 1 : numel(sae.ae);
        % initialize the parameter to store the historical eror
        error_array = [];
        loss_array  = [];
        scale = 0;
        num_epochs = 0;
        
        sae.ae{1,i}.L = 0;
        repeat = 0; % not necessary
        history_sae_L = Inf(1, num_history_L);
        
        disp(['Training AE ' num2str(i) '/' num2str(numel(sae.ae))]);
        tic;
        
        while history_sae_L(1, 1) >= mean(history_sae_L)
            num_epochs = num_epochs + 1;
            sae.ae{1,i} = nntrain(sae.ae{1,i}, x, x, opts);
            history_sae_L(1, 1:end - 1) = history_sae_L(1, 2:end);
            history_sae_L(1, end) = sae.ae{1,i}.L;    % sae.ae{1,i}.L is the error of current epochs
            %% take down current error
            % dynamically alloc new memory to store historical data
            if 0 == mod(num_epochs, 10^scale)
                scale = scale + 1;
                error_array = [error_array; zeros(1, 9)];
                loss_array = [loss_array; zeros(1, 9)];
            end
            % store specific data (1 to 9 times 10^scale)
            if 0 == mod(num_epochs, 10^(scale-1))        % a kind of redundance
                index = floor(num_epochs / 10^(scale-1));
                % only record the error, number of epochs can be calculated using the position information
                loss_array(scale, index) = sae.ae{1,i}.L;
                error_array(scale, index) = max(abs(max(max(sae.ae{1,i}.e))), abs(min(min(sae.ae{1,i}.e))));
                % calculate the inequality equnation to see if the result meet the termination standard
                % write debug information into file. Don't forget to give
                % input file handle into fprintf function.
                fprintf(fid, 'Layer %d\n%d time training. current loss: %f \t average loss: %f \t difference(times 10^10): %f \nmax/min error %f\n', ...
                    i, num_epochs, sae.ae{1,i}.L, mean(history_sae_L), ...
                    10^10 * abs(sae.ae{1,i}.L - mean(history_sae_L)), ...
                    max(abs(max(max(sae.ae{1,i}.e))), abs(min(min(sae.ae{1,i}.e)))));
            end
            
            % display debug information on the command window
%             sprintf('Layer %d \n%d time training. current loss: %f \t average loss: %f \t difference(times 10^10): %f \nmax/min error %f', ...
%                 i, num_epochs, sae.ae{1,i}.L, mean(history_sae_L), ...
%                 10^10 * abs(sae.ae{1,i}.L - mean(history_sae_L)), ...
%                 max(abs(max(max(sae.ae{1,i}.e))), abs(min(min(sae.ae{1,i}.e)))))
            
        end
        % finish calculating ith layer, store the hisotrical data into cell
        % arrary error_history{1,i}.
        eltime(1, i) = toc;
        error_history{1, i} = error_array;
        loss_history{1, i} = loss_array;
        disp(['Finish training AE ' num2str(i) '/' num2str(numel(sae.ae)) 'training time is ' num2str(toc)]); % debug information
        fprintf(fid, 'Finish training AE layer %d \t, elapsed time is %f\n', i, eltime(1, i));
        % put input into trained layer get the output of current layer as the input to the next layer.
        t = nnff(sae.ae{1,i}, x, x);
        x = t.a{2};
        %remove bias term
        x = x(:,2:end); % dynamically updated x, which will be used as input to the next layer.
    end
    
    fclose(fid);
    save('./output/error_history.mat', 'error_history');
    save('./output/loss_history.mat', 'loss_history');
    save('./output/running_time.mat', 'eltime');
end
