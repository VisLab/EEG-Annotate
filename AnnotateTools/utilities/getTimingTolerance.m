function [sampleIndex, timeTolerance, nearestEvent] = ...
                     getTimingTolerance(labels, classLabel, sampleMask)
%% Compute the distance to the nearest subwindow containing classLabel
%
%  Parameters:
%      labels        cell array of labels
%      classLabel   label to determine closeness to
%      sampleMask   mask giving all the samples to be considered
%
%  Output:
%      sampleIndex   index of this event in original labels
%      timeTolerance distance of this event to nearest classLabel
%      nearestEvent  index of nearest classLabel event.
% Return the closest event of classLabel in labels

%% Initialize the data structures
    sampleIndex = (1:length(sampleMask))';
    sampleIndex = sampleIndex(sampleMask);
    timeTolerance = inf(size(sampleIndex));
    eventType = cell(size(sampleIndex));
    nearestEvent = zeros(size(sampleIndex));
    [~, classIndex] = getClassMask(labels, classLabel);
    lastIndex = 1;
    for k = 1:length(sampleIndex)
        while lastIndex < length(classIndex) && ...
                classIndex(lastIndex) < sampleIndex(k)
            lastIndex = lastIndex + 1;
        end
        lastDist = classIndex(lastIndex) - sampleIndex(k);
        if classIndex(lastIndex) == sampleIndex(k)
            timeTolerance(k) = 0;
            nearestEvent(k) = classIndex(lastIndex);
        elseif lastIndex == 1 || lastDist < 0
            timeTolerance(k) = lastDist;
            nearestEvent(k) = classIndex(lastIndex);
        else
            prevDist = classIndex(lastIndex - 1) - sampleIndex(k);
            if abs(lastDist) <= abs(prevDist)
                timeTolerance(k) = lastDist;
                nearestEvent(k) = classIndex(lastIndex);
            else
                timeTolerance(k) = prevDist;
                nearestEvent(k) = classIndex(lastIndex - 1);
            end
        end
    end
end
