function [samples, labels, indices] = getTrainingData(data, targetClass)
%% Get training target and non-target samples from dataPath, excluding overlaps
%
%   Parameters:
%       dataPath     fullpath of file containing samples and labels
%       targetClass  label of the target class
%       samples      relevant samples for training for target class
%       labels       cell array of labels of the relevant training samples
%       indices      vector containing indices of training samples
%
%   Non-target samples do not overlap with target samples.


%% Extract the target samples
    dataIndices = (1:length(data.labels))';
    targetIdx = zeros(length(data.labels), 1);
    for i=1:length(data.labels)
        if ~iscell(data.labels{i}) && strcmpi(data.labels{i}, targetClass)
            targetIdx(i) = 1;
        else
            for j=1:length(data.labels{i})
                if strcmpi(data.labels{i}{j}, targetClass)
                    targetIdx(i) = 1;
                end
            end
        end
    end
    targetSample = data.samples(:, targetIdx==1);
    targetIndices = dataIndices(targetIdx == 1);
    
%% Exclude non-target samples that overlap with the target samples
    targetIdx = find(targetIdx);  
    excludeIdx = targetIdx;
    
    pickIdx = [];
    for offset = -7:7
        pickIdx = cat(2, pickIdx, excludeIdx+offset);
    end
    
    pickIdx = pickIdx(:);
    pickIdx(pickIdx < 1) = [];
    pickIdx(pickIdx > size(data.samples, 2)) = [];
    nonTargetSample = data.samples;
    nonTargetSample(:, pickIdx) = [];
    nonTargetIndices = dataIndices(~pickIdx);
    samples = [nonTargetSample targetSample ];
    if size(nonTargetSample, 2) == 0 
        warning('Data has no non-target samples');
    end
    if size(targetSample, 2) == 0 
        warning('Data has no target samples');
    end
    labels = [zeros(size(nonTargetSample, 2), 1); ones(size(targetSample, 2), 1)];  % targetClass is 1, other is 0
    indices = [targetIndices; nonTargetIndices];
end