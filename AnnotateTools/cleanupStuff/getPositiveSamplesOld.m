function [labels, samples, sampleIndex, timeTolerance, nearestEvent] = ...
           getPositiveSamples(scoreData, classLabel, tolerance, varargin)
%% Extracts the positive samples from a classified dataset for reranking
%
%  Parameters:
%     scoreData   structure of classification results (see getScoreDataStructure)
%     classLabel  string with class label
%     tolerance   number of subwindows on either side to consider hit
%     varargin    any name-value pair parameters relevant to annotation
%     
%
%
%%  Handle override of adaptiveCutoff2   
    argMask = strcmpi(varargin, 'adaptiveCutoff2');
    if isempty(argMask) || sum(argMask) == 0
        varargin = [{'adaptiveCutoff2', false}, varargin{:}];
    end
    data = load(scoreData(1).testFileName);
    annotData = annotate(scoreData, classLabel, varargin{:});
    sampleMask = annotData.wmScores > annotData.combinedCutoff;
    [sampleIndex, timeTolerance, nearestEvent] = ...
        getTimingTolerance(sampleMask, data.labels, classLabel);
    samples = data.samples(:, sampleMask);
    labels = cell(length(sampleIndex), 1);
    hitMask = abs(timeTolerance) <= tolerance;
    labels(hitMask) = {classLabel};