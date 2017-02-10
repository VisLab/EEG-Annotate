function outPath = batchIterativeRerankLDA(testPath, trainingPaths, outPath, targetClass, params)
%   batch_annotation() 
%       - estimate annotation scores using the annotator
%       - the annotator uses the Fuzzy voting and adaptive cutoff
%
%   Example:
%       outPath = batch_annotation('.\pathIn');
%       outPath = batch_annotation('.\pathIn', ...
%                    'outPath', '.\pathOut', ...
%                    'excludeSelf', true, ...
%                    'adaptiveCutoff1', true, ...
%                    'adaptiveCutoff2', true, ...
%                    'rescaleBeforeCombining', true, ...
%                    'weights', [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]);
%
%   Inputs:
%       inPath: the pash to the classification scores
%   
%   Optional inputs:
%       'outPath': the path to the place where estimated annotation scores will be saved. (default: '.\temp')
%       'excludeSelf', when we use the same datasets for training and test, 
%                      if this flag is true, the test set is excluded from the training set.
%                      If the flag is false, it uses all training sets for annotaion.
%       'adaptiveCutoff1', option to use the adaptive cutoff on the classfication scores
%       'adaptiveCutoff2', option to use the adaptive cutoff on the combined scores
%       'rescaleBeforeCombining', if true, normalize scores so that they are in 0 to 1 range, before combining
%       'position', the center of re-weighting area
%       'weights',  the weights of scores
%
%   Output:
%       outPath: the path to the place where annotation scores were saved
%
%   Note:
%       It stores estimated classification scores using the annotData structure. 
%       annotData structure has eight fields.
%           testLabel: the cell containing the true labels of test samples
%           predLabel: the cell containing the predicted labels of test samples
%           testInitProb: the cell containing the intial scores 
%           testInitCutoff: the array of intial cutoff
%           testFinalScore: the cell containing the final scores 
%           testFinalCutoff: the array of final cutoff
%           trainLabel: the cell containing the true labels of training samples
%           trainScore: the cell containing the scores of training samples
%           allScores: the 2D matrix containing scores for combining.
%                       scores have been normalized, weighted and mask-outed.
%                       allScores = [number of samples x number of training sets]
%           combinedScore = the array of combined scores
%           combinedCutoff = the cutoff for the combinedScore
%
%   Written by: Kyung-min Su, UTSA, 2016
%   Modified by: Kay Robbins, UTSA, 2017
%

%% If the outpath doesn't exist, make the directory 
    if ~isdir(outPath)    
        mkdir(outPath);   
    end

%% Annotate files by combining score data    
    testData = load(testPath);
    testData = testData.annotData;
    [~, testName, ~] = fileparts(testData.testFileName);
    numTrain = length(trainingPaths);  
    scoreData(numTrain) = getScoreDataStructure(); 
    selfMask = false(numTrain, 1);   
    for i = 1:numTrain
        dataTrain = load(trainingPaths{i});
        [~, trainName, ~] = fileparts(trainingPaths{i});
        if strcmpi(testName, trainName) == 1
            selfMask(i) = true;
        end
        scoreData(i) = classifyLDA(dataTest, dataTrain, targetClass, params);
        scoreData(i).testFileName = testData.testFileName;
        scoreData(i).trainFileName = trainingPaths{i};
    end
    rankedData = struct();
    rankedData.annotData = testData;
    rankedData.scoreData = scoreData;
    rankedData.selfMask = selfMask;
    rankedData.rerankingClassifier = 'LDA';
    numberSamples = length(scoreData(1).trueLabels);
    scores = zeros(numberSamples, numberTrain);
    for m = 1:numberTrain
        scores(:, m) = scoreData(m).finalScores;
    end
    rankedData.rankedScores = mean(scores, 2); %#ok<STRNU>
    outputFileName = [outPath filesep testName '_' targetClass];
    save(outputFileName, 'rankedData', '-v7.3');
end