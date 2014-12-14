function sae = saetrain(sae, x, opts)
    for i = 1 : numel(sae.ae);
        lastL = -1;
        sae.ae{i}.L = 0;
        count = 0;
        
        disp(['Training AE ' num2str(i) '/' num2str(numel(sae.ae))]);
        
        while abs(sae.ae{i}.L - lastL) > 0.000001
            count = count + 1;
            lastL = sae.ae{i}.L;
            sae.ae{i} = nntrain(sae.ae{i}, x, x, opts);
            sprintf('Reapt triaing AE %d times. %f', count, sae.ae{i}.L)
        end
        
        disp(['Finish training AE ' num2str(i) '/' num2str(numel(sae.ae))]);
        t = nnff(sae.ae{i}, x, x);
        x = t.a{2};
        %remove bias term
        x = x(:,2:end);
    end
end
