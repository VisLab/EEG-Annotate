% %% Rerank the positive samples using an LDA classifier
% 
% 
%% Set the directories for test and training data
trainDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
testDirBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSimb_Positive';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSimb_Positive_LDAReranked';
targetClasses = {'34', '35'};

%% Get the full paths of test and training files
trainPaths = getFiles('FILES', trainDir, '.mat');

rng('default'); % to reproduce results, keep use the same random seed

% %% Perform the classification 
for k = 1%:length(targetClasses)
    %annotData = []' scoreData = [];
    testDir = [testDirBase '_' targetClasses{k}];
    testPaths = getFiles('FILES', testDir, '.mat');
    outPath = [outPathBase '_' targetClasses{k}];
    for n = 1%:length(testPaths)
       outFileNames = batchClassifyLDA(testPaths(n), trainPaths, outPath, targetClasses{k});
       testData = load(testPaths{n});
       
    end
end

%% 

% 
%     numberSamples = length(outData.scoreData(1).trueLabels);
%     numberTrain = 17;
%     scores = zeros(numberSamples, numberTrain);
%     for m = 1:numberTrain
%         scores(:, m) = scoreData(m).finalScores;
%     end
%     rankedScores = mean(scores, 2);
    
% end
