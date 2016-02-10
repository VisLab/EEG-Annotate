%% get test samples 
% test samples is non_time_locked samples.
% Note that it doesn't return the binary labels because we don't know what is the target label.
% It just returns the orignal labels for further analysis.
%
function [samples, labelsOriginal, excludeIdx] = getTestData_noExclude(dataPath, fileName)
    
    load([dataPath filesep fileName]);
    
    samples = data.samples;
    labelsOriginal = data.labels;
    
    excludeIdx = zeros(1, length(data.mask.indexOverlapBoundary));
end