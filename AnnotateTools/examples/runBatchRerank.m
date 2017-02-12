%% This script computes pairwise LDA classification for directories of test and training


%% Set the directories for test and training data
%trainBase = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
trainBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
testPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
targetClasses = {'34', '35'};
baseClassifiers = {'LDA', 'ARRLS', 'ARRLSMod', 'ARRLSimb'};
targetClassifier = 'ARRLSMod';
params = struct();
params.rerankPositive = true;

%% Get the full paths of training files

rng('default'); % to reproduce results, keep use the same random seed

%% Perform the classification
for n = 1:length(baseClassifiers)
    for k = 1:length(targetClasses)
        if params.rerankPositive
           rankType = '_positive_reranked_';
           trainDir = [trainBase '_' baseClassifiers{n} '_positive_' targetClasses{k}];
        else
           trainDir = trainBase;
           rankType = '_base_reranked_';
        end
       trainPaths = getFiles('FILES', trainDir, '.mat');
       testDir =  [testPathBase '_' baseClassifiers{n} '_positive_' targetClasses{k}];
       testPaths = getFiles('FILES', testDir, '.mat');
       outPath = [outPathBase '_' baseClassifiers{n} rankType ...
                  targetClassifier '_' targetClasses{k}]; 
       batchRerank(testPaths, trainPaths, outPath, ...
                    targetClasses{k}, targetClassifier, params);
    end
end