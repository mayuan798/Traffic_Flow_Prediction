function sae = saetrain(sae, x, opts)
    fid = fopen('./training_record.txt', 'w');
    error_history = {1, numel(sae.ae)};
    loss_history = {1, numel(sae.ae)};
<<<<<<< HEAD
    eltime = zeros(1, numel(sae.ae));
    num_history_L = opts.batchsize;
=======
    eltime = [1, numel(sae.ae)];
    num_history_L = 100;
>>>>>>> origin/SAE_ver_2.0
    
    for i = 1 : numel(sae.ae);
        last_max = Inf;
        error_array = [];
        loss_array  = [];
        scale = 0;
        num_epochs = 0;
        sae.ae{1,i}.L = 0;
<<<<<<< HEAD
        sae.ae{1,i}.e = Inf;
        history_sae_L = Inf(1, num_history_L);
        
        disp(['Training AE ' num2str(i) '/' num2str(numel(sae.ae))]);

        while sae.ae{1,i}.L < max(history_sae_L)
            tic;
=======
        sae.ae{1,i}.e = 0;
        history_sae_L = Inf(1, num_history_L);
        
        disp(['Training AE ' num2str(i) '/' num2str(numel(sae.ae))]);
        tic;
        
        while last_max >= max(history_sae_L)
>>>>>>> origin/SAE_ver_2.0
            num_epochs = num_epochs + 1;
            last_max = max(history_sae_L);
            sae.ae{i} = nntrain(sae.ae{i}, x, x, opts);
            history_sae_L(1, 1:end - 1) = history_sae_L(1, 2:end);
            history_sae_L(1, end) = sae.ae{1,i}.L;    % sae.ae{1,i}.L is the error of current epochs
            eltime(1, i) = eltime(1, i) + toc;
            
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
<<<<<<< HEAD
                fprintf(fid, 'Layer %d\n%d time training. current loss: %f \t first loss: %f \t average loss: %f \ndifference(times 10^10): %f \tmax/min error %f\n', ...
                    i, num_epochs, sae.ae{1,i}.L, history_sae_L(1,1), mean(history_sae_L), ...
=======
                fprintf(fid, 'Layer %d\n%d time training. current loss: %f \t first loss: %f \t average loss: %f\t minmum error: %f\ndifference(times 10^10): %f \tmax/min error %f\n', ...
                    i, num_epochs, sae.ae{1,i}.L, history_sae_L(1,1), mean(history_sae_L), min(history_sae_L),...
>>>>>>> origin/SAE_ver_2.0
                    10^10 * abs(sae.ae{1,i}.L - mean(history_sae_L)), ...
                    max(abs(max(max(sae.ae{1,i}.e))), abs(min(min(sae.ae{1,i}.e)))));
            end
            
<<<<<<< HEAD
            sprintf('Layer %d\n%d time training. current loss: %f \t first loss: %f \t average loss: %f \ncurrent maximum loss: %f \t last maximum loss: %f\ndifference(times 10^10): %f \tmax/min error %f\n', ...
                    i, num_epochs, sae.ae{1,i}.L, history_sae_L(1,1), mean(history_sae_L), ...
                    max(history_sae_L), last_max, ...
=======
            sprintf('Layer %d\n%d time training. current loss: %f \t first loss: %f \t average loss: %f\t minmum error: %f\ndifference(times 10^10): %f \tmax/min error %f\n', ...
                    i, num_epochs, sae.ae{1,i}.L, history_sae_L(1,1), mean(history_sae_L), min(history_sae_L),...
>>>>>>> origin/SAE_ver_2.0
                    10^10 * abs(sae.ae{1,i}.L - mean(history_sae_L)), ...
                    max(abs(max(max(sae.ae{1,i}.e))), abs(min(min(sae.ae{1,i}.e)))))
        end
        
        % finish calculating ith layer, store the hisotrical data into cell
        % arrary error_history{1,i}.
        error_history{1, i} = error_array;
        loss_history{1, i} = loss_array;
        % debug information
        sprintf('Finish training AE %d/%d, training time is %f, total time is %f\n', ...
                    num2str(i), num2str(numel(sae.ae), num2str(toc), eltime(1, i)))
        fprintf(fid, 'Finish training AE layer %d \t, total number of epochs is %d\t total elapsed time is %f\n', i, num_epochs, eltime(1, i));
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
