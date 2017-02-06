%% This script computes pairwise LDA classification for directories of test and training


%% Set the directories for test and training data
originalDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
trainPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_positive';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_positive_LDA';
targetClasses = {'34', '35'};

%% Get the full paths of test and training files
originalPaths = getFiles('FILES', originalDir, '.mat')';
testNames = getNames(originalPaths);

%% Perform the classification

for k = 1:length(targetClasses)
    trainDir = [trainPathBase '_' targetClasses{k}];
    trainDataPaths = getFiles('FILES', trainDir, '.mat')';
    trainNames = getNames(trainDataPaths);
    indexRange = (1:length(trainNames))';
    for n = 1:length(testNames)
        baseName = testNames{n};
        baseMask = ~cellfun(@isempty, strfind(trainNames, baseName));
        exMask = ~cellfun(@isempty, strfind(trainNames, ['_ex_' baseName]));
        noExPositions = cellfun(@isempty, strfind(trainNames, '_ex_'));
        trainDataMask = baseMask & exMask;
        testDataMask = baseMask & noExPositions;
        testIndex = indexRange(testDataMask);
        testPath = trainDataPaths(testIndex);
        fprintf('Classifying %s\n', testPath{:});
        trainIndices = indexRange(trainDataMask);
        trainPaths = trainDataPaths(trainIndices);
        outPath = [outPathBase '_' targetClasses{k}];
        batchClassifyLDA(testPath, trainPaths, outPath, targetClasses{k}, ...
            'fSaveTrainScore',  true);
    end
end
