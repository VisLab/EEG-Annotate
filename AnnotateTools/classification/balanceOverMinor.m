function [samples, labels] = balanceOverMinor(samples, labels)
	
    if ~isempty(samples) && ~isempty(labels)
        indexClass0 = find(labels == 0);
        indexClass1 = find(labels == 1);

        sampleNumb0 = length(indexClass0);
        sampleNumb1 = length(indexClass1);

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

        %pickIndex = [indexClass0; indexClass1; addIndex];

        %samples = samples(:, pickIndex);
        %labels = labels(pickIndex);
        samples = cat(2, samples, samples(:, addIndex));
        labels = cat(1, labels, labels(addIndex));
    end
end
