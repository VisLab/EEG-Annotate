function annotData = getSamplesAnnotatedPositive(annotData, samples, ...
                                           labels, classLabel, tolerance)
%% Extracts the positive samples from a classified dataset for reranking
%
%  Parameters:
%     scoreData   structure of classification results (see getScoreDataStructure)
%     classLabel  string with class label
%     tolerance   number of subwindows on either side to consider hit
%     varargin    any name-value pair parameters relevant to annotation
%     
%
%%  Get the samples annotated as positive
    sampleMask = annotData.wmScores > 0;
    [sampleIndex, timeTolerance, nearestEvent] = ...
                getTimingTolerance(sampleMask, labels, classLabel);
    annotData.samples = samples(:, sampleMask);
    labels = cell(length(sampleIndex), 1);
    hitMask = abs(timeTolerance) <= tolerance;
    labels(hitMask) = {classLabel};
    annotData.labels = labels;
    annotData.tolerance = tolerance;
    annotData.sampleIndex = sampleIndex;
    annotData.timeTolerance = timeTolerance;
    annotData.nearestEvent = nearestEvent;