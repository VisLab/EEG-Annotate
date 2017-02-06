%% This script computes pairwise LDA classification for directories of test and training


%% Set the directories for test and training data
posDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_rankTrain_34';
testDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Annotation_34';
trainDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Annotation_34';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Reranked';
targetClasses = {'34', '35'};

%% Get the full paths of test and training files
trainPaths = getFiles('FILES', trainDir, '.mat');
testPaths = getFiles('FILES', testDir, '.mat');
rng('default'); % to reproduce results, keep use the same random seed

%% Perform the classification 
k = 1;
targetClass = targetClasses{k};
outPath = [outPathBase '_' targetClasses{k}];
if ~exist(outPath, 'dir')
    mkdir(outPath);
end

for n = 1:18
    dataPathTest = testPaths{n};
    scoreData(16) = getScoreDataStructure();
    ldaObjs = cell(16, 1);
    testNumber = sprintf('%02d', n);
    for j = 1:16
        trainName = sprintf('vep_%02d', j);
        dataPathTrain = [posDir filesep trainName '_ex' testNumber '.mat'];
        [scoreData(j), ldaObjs{j}] = classifyLDA(dataPathTest,  ...
                            dataPathTrain, targetClasses{k}); %#ok<SAGROW>
    end;
    save([outPath filesep 'vep_' testNumber '.mat'], ...
         'scoreData', 'ldaObjs', '-v7.3');
end
