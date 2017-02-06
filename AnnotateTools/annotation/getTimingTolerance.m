%  dataDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
%  annotDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_Annotation_34';
%  
% data = load([dataDir filesep 'vep_01.mat']);
% load([annotDir filesep 'vep_01_34.mat']);
function [sampleIndex, timeTolerance, nearestEvent] = ...
        getTimingTolerance(sampleMask, labels, classLabel)
% Return the closest event of classLabel in labels

%% Initialize the data structures
    sampleIndex = (1:length(sampleMask))';
    sampleIndex = sampleIndex(sampleMask);
    timeTolerance = inf(size(sampleIndex));
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
