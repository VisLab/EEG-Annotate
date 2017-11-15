function [sampleIndex, timeTolerance, nearestMatch, nearestClass] = ...
                     getTimingTolerances(labels, targetClasses, sampleMask)
%% Compute the distance to the nearest subwindow containing classLabel
%
%  Parameters:
%      labels       cell array of labels
%      classLabel   label to determine closeness to
%      sampleMask   mask giving all the samples to be considered
%
%  Output:
%      sampleIndex     index of this event in original labels
%      timeTolerance   distance of this event to nearest classLabel
%      nearestMatch    
%      nearestClasses  index of nearest classLabel event
%
% Return the closest event of classLabel in labels

%% Initialize the data structures
    sampleIndex = (1:length(sampleMask))';
    sampleIndex = sampleIndex(sampleMask);
    numClasses = length(targetClasses);
    numSamples = length(sampleIndex);
    timeTolerances = inf(numSamples, numClasses);
    nearest= zeros(numSamples, numClasses);
    for n = 1:numClasses
        [~, classIndex] = getClassMask(labels, targetClasses{n});
        lastIndex = 1;
        for k = 1:length(sampleIndex)
            while lastIndex < length(classIndex) && ...
                    classIndex(lastIndex) < sampleIndex(k)
                lastIndex = lastIndex + 1;
            end
            lastDist = classIndex(lastIndex) - sampleIndex(k);
            if classIndex(lastIndex) == sampleIndex(k) 
                timeTolerances(k, n) = 0;
                nearest(k, n) = classIndex(lastIndex);
            elseif lastIndex == 1 || lastDist < 0
                timeTolerances(k, n) = lastDist;
                nearest(k, n) = classIndex(lastIndex);
            else
                prevDist = classIndex(lastIndex - 1) - sampleIndex(k);
                if abs(lastDist) <= abs(prevDist)
                    timeTolerances(k, n) = lastDist;
                    nearest(k, n) = classIndex(lastIndex);
                else
                    timeTolerances(k, n) = prevDist;
                    nearest(k, n) = classIndex(lastIndex - 1);
                end
            end
        end
    end
    timeTolerance = inf(numSamples, 1);
    nearestClass = zeros(numSamples, 1);
    nearestMatch = zeros(numSamples, 1);
    [~, minIndex] = min(abs(timeTolerances), [], 2);
    for n = 1:numClasses
       thisMask = minIndex == n;
       timeTolerance(thisMask) = timeTolerances(thisMask, n);
       nearestMatch(thisMask) = nearest(thisMask, n);
       nearestClass(thisMask) = n;
    end
end
