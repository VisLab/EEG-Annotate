%% This script computes pairwise LDA classification for directories of test and training


%% Set the directories for test and training data
trainDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
testDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSMod';
targetClasses = {'34', '35'};

%% Get the full paths of test and training files
trainPaths = getFiles('FILES', trainDir, '.mat');
testPaths = getFiles('FILES', testDir, '.mat');
rng('default'); % to reproduce results, keep use the same random seed

%% Perform the classification 
for k = 1:length(targetClasses)
  outPath = [outPathBase '_' targetClasses{k}]; 
  batchClassifyARRLSMod(testPaths, trainPaths, outPath, targetClasses{k});
end
