%% balancing samples by over-sampling minor class
%
function [samples, labels] = balanceOverMinor_imb(samples, labels)
	
    if ~isempty(samples) && ~isempty(labels)
        classes = unique(labels);
        
        indexClass0 = find(labels == classes(1));
        indexClass1 = find(labels == classes(2));

        sampleNumb0 = length(indexClass0);
        sampleNumb1 = length(indexClass1);

        % if only one class is given, add 10% of samples randomly
        if (sampleNumb0 == 0) || (sampleNumb1 == 0) 
            warning('only one class');
            sampleNumb = sampleNumb0 + sampleNumb1;
            numAdd = round(sampleNumb / 10);
            addIndex = randsample(sampleNumb, numAdd, true);
        else
            if sampleNumb0 < sampleNumb1
                numAdd = sampleNumb1 - sampleNumb0;
                addIndex = indexClass0(randsample(sampleNumb0, numAdd, true));
            else
                numAdd = sampleNumb0 - sampleNumb1;
                addIndex = indexClass1(randsample(sampleNumb1, numAdd, true));
            end
        end

        samples = cat(2, samples, samples(:, addIndex));
        labels = cat(1, labels, labels(addIndex));
    else
        error('empty data is given');
    end
end
