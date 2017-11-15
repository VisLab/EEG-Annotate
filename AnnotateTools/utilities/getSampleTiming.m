function [targetDist, nearestEvent] = getSampleTiming(classInd1, classInd2)
%% Compute the distance to the nearest subwindow containing classLabel
%
%  Parameters:
%      classInd1        array with the indices of the target class in data1
%      classInd2        array with the indices of the target class in data2
%      targetDist       array with the distances of closest target in data2
%
%
% Written by: Kay Robbins, UTSA
%

%% Find the distance of samples from class 1 to class 2.
    targetDist = inf(length(classInd1), 1);
    nearestEvent = inf(length(classInd1), 1);
    nextIndex = 1;
    for k = 1:length(classInd1)
        while nextIndex < length(classInd2) && ...
                classInd2(nextIndex) < classInd1(k)
            nextIndex = nextIndex + 1;
        end
        nextDist = classInd2(nextIndex) - classInd1(k);
        if nextDist == 0
            targetDist(k) = 0;
            nearestEvent(k) = classInd2(nextIndex);
        elseif nextIndex == 1 || nextDist < 0
            targetDist(k) = nextDist;
            nearestEvent(k) = classInd2(nextIndex);
        else
            prevDist = classInd2(nextIndex - 1) - classInd1(k);
            if abs(nextDist) <= abs(prevDist)
                targetDist(k) = nextDist;
                nearestEvent(k) = classInd2(nextIndex);
            else
                targetDist(k) = prevDist;
                nearestEvent(k) = classInd2(nextIndex - 1);
            end
        end
    end
end