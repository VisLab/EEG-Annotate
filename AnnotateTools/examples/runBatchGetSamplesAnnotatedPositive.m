%% This script builds the positive training data for use with VEP
% This only needs to be done once for each classifier

%% Set up directories and parameters
inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
targetClasses = {'34', '35'};
targetClassifiers = {'LDA', 'ARRLS', 'ARRLSMod', 'ARRLSimb'};
params = struct();
%% Run batch extraction of positive samples for reranking
for n = 1:length(targetClassifiers)
    for k = 1:length(targetClasses)
        inPath = [inPathBase '_' targetClassifiers{n} '_Annotation_' targetClasses{k}];
        outPath = [outPathBase '_' targetClassifiers{n} '_positive_' targetClasses{k}];
        batchGetSamplesAnnotatedPositive(inPath, outPath, targetClasses{k}, params);
    end
end
