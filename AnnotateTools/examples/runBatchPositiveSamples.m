%% This script builds the positive training data for use with VEP
% This only needs to be done once for each classifier

%% Set up the directories and parameters
% inPaths = {'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34'};
% outPaths = {'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_rankTrain1_34'};
pathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
classifierName = 'LDA';
targetClasses = {'34'; '35'};
tolerance = 2;

%% Run batch extraction of positive samples for reranking
for k = 1:length(targetClasses)
    inPath = [pathBase '_' classifierName '_' targetClasses{k}];
    outPath = [pathBase '_' classifierName '_positive_' targetClasses{k} ];
    batchPositiveSamples(inPath, outPath, targetClasses{k}, tolerance, true)
end