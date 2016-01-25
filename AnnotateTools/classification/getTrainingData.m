%% get training samples 
%
% The non-target samples do not overlap with the target samples.
% 
function [samples, labels] = getTrainingData(dataPath, fileName, targetClass)
    
    load([dataPath filesep fileName]);
    
    targetIdx = zeros(length(labels), 1);
    for i=1:length(labels)
        for j=1:length(labels{i})
            if strcmp(labels{i}{j}, targetClass)
                targetIdx(i) = 1;
            end
        end
    end
    targetSample = samples(:, targetIdx==1);
    
    % exclude overlapped samples with the target samples
    targetIdx = find(targetIdx);
    
    excludeIdx = targetIdx;
    
    pickIdx = [];
    for offset = -7:7
        pickIdx = cat(2, pickIdx, excludeIdx+offset);
    end
    
    pickIdx = pickIdx(:);
    pickIdx(pickIdx < 1) = [];
    pickIdx(pickIdx > size(samples, 2)) = [];
    nonTargetSample = samples;
    nonTargetSample(:, pickIdx) = [];

    samples = [nonTargetSample targetSample ];
    labels = [zeros(size(nonTargetSample, 2), 1); ones(size(targetSample, 2), 1)];  % targetClass is 1, other is 0
end