%% This script builds the positive training data for use with VEP
% This only needs to be done once for each classifier

%% Set up the directories
inDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34';
origDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
outDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_rankTrain_34';
classLabel = '34';

% inDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_35';
% origDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
% outDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_rankTrain_35';
% classLabel = '35';

theTolerance = 1;

if ~exist(outDir, 'dir')
    mkdir(outDir);
end
%% Extract the training samples
indices = 1:18;
for k = 1:18
    thisFile = sprintf('vep_%02d', k);
    load([inDir filesep thisFile '_' classLabel '.mat']);
    theseIndices = indices(indices ~= k);
    data = load([origDir filesep thisFile '.mat']);
    for j = 1:length(theseIndices)
        excludeIndex = theseIndices(j);
        thisScoreData = scoreData;
        thisScoreData([k, j]) = [];
        annotData = annotate(thisScoreData, classLabel, 'adaptiveCutoff2', false);
        sampleMask = annotData.wmScore > annotData.combinedCutoff;
        [sampleIndex, timeTolerance, nearestEvent] = ...
            getTimingTolerance(sampleMask, data.labels, classLabel);
        samples = data.samples(:, sampleMask);
        labels = cell(length(sampleIndex), 1);
        hitMask = abs(timeTolerance) <= theTolerance;
        labels(hitMask) = {classLabel};
        fileName = sprintf('vep_%02d_ex%02d_%s.mat', k, excludeIndex, classLabel);
        save([outDir filesep fileName], 'classLabel', 'samples', 'labels', ...
            'timeTolerance', 'sampleIndex', 'nearestEvent', '-v7.3')
    end  
end