%% This script computes pairwise LDA classification for directories of test and training


%% Set the directories for test and training data
trainDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
testPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
targetClasses = {'34', '35'};
baseClassifiers = {'LDA', 'ARRLS', 'ARRLSMod', 'ARRLSimb'};
targetClassifier = 'ARRLSMod';
params = struct();
params.balanceTrain = true;

%% Get the full paths of training files
trainPaths = getFiles('FILES', trainDir, '.mat');
rng('default'); % to reproduce results, keep use the same random seed

%% Perform the classification
for n = 1:length(baseClassifiers)
    for k = 1:length(targetClasses)
       testDir =  [testPathBase '_' baseClassifiers{n} '_positive_' targetClasses{k}];
       testPaths = getFiles('FILES', testDir, '.mat');
       outPath = [outPathBase '_' baseClassifiers{n} '_reranked_' ...
                  targetClassifier '_' targetClasses{k}]; 
       batchRerank(testPaths, trainPaths, outPath, ...
                    targetClasses{k}, targetClassifier, params);
    end
end