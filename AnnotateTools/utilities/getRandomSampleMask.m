function [sampleMask, actualNumSamples] = ...
          getRandomSampleMask(numLabels, numSamples, subwindowRange)
% Produce a random annotated sample of a certain size
%
%  Parameters:
%    numLabels       total number of samples to simulate
%    numSamples      number of random samples required
%    subwindowRange  number of subwindows on either side to mask out
%
%  Output:
%    sampleMask      mask of numLabels length giving selected samples
%    actualNumSamples  number of samples actually generated
%
%  Written by:  Kay Robbins, UTSA, 2017
%
%  This function is used for getting p values for accuracy
%
%% Set up the data
sampleMask = false(numLabels, 1);
availableLabels = true(numLabels, 1);
actualNumSamples = 0;
sampleIndices = 1:numLabels;

%% Select the samples one at a time
for k = 1:numSamples
    theseSamples = sampleIndices(availableLabels);
    if isempty(theseSamples)
        warning('Not enough samples available');
        break;
    end
    thisIndex = randi(length(theseSamples));
    thisPos = theseSamples(thisIndex);
    sampleMask(thisPos) = true;
    availableLabels(max(1, thisPos - subwindowRange): ...
                    min(thisPos + subwindowRange, numLabels)) = false;
    actualNumSamples = actualNumSamples + 1;
end