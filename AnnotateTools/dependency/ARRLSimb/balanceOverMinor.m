function [samples, labels] = balanceOverMinor(samples, labels)
% Oversample minority class to balance samples (or add 10% if one class)
%
%  Parameters:
%      samples   (I/O) double 2D array with features as the column vectors
%      labels    (I/O) cell array of string labels for the features
%
%  Written by: Kyung-min Su, UTSA, 2016-2017
%  Modified by: Kay Robbins, UTSA, 2017
%

    if isempty(samples) || isempty(labels)
        error('Empty data must provide feature vectors and labels');
    end
    classes = unique(labels);
    if length(classes) == 1
        sampleNumb0 = length(labels);
        sampleNumb1 = 0;
    else
        indexClass0 = find(labels == classes(1));
        indexClass1 = find(labels == classes(2));

        sampleNumb0 = length(indexClass0);
        sampleNumb1 = length(indexClass1);
    end

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
end