function scoreData = classifyARRLS(dataTest, dataTrain, targetClass, params)
%% Use the ARRLS modified classifier to classify targetClass for dataTrain.
%  
%  Parameters:
%    dataTest         structure with sample and label fields for testing 
%    dataTrain        structure with sample and label fields for training
%    targetClass      string containing the target class (one vs all)
%    params           structure containing parameters to override defaults
%    scoreData        (output) structure containing the scoreData structure
%
% See also getScoreDataStructure
%
%  Written by: Kyung Mu Su and Kay Robbins 2016-2017, UTSA
% 
%% Set the parameters and reporting for the call   
    params = processAnnotateParameters('classifyARRLS', nargin, 3, params);

    %% Initialize return structure
    scoreData = getScoreDataStructure();

    %% Load the data
    [trainSamples, trainLabels] = getTrainingData(dataTrain, targetClass);
    [trainSamples, trainLabels] = balanceOverMinor(trainSamples, trainLabels);
    testSamples = dataTest.samples;
    scoreData.trueLabels = dataTest.labels; % it is not binary label. one sample can have more than one class label.
    [finalScores, finalCutoff, initProbs, initCutoff, trainScores] = ...
        ARRLS(double(trainSamples), double(testSamples), ...
        trainLabels, [], params);
    scoreData.predLabels = (finalScores > finalCutoff);
    scoreData.finalScores = finalScores;
    scoreData.finalCutoff = finalCutoff;
    scoreData.initProbs = initProbs;
    scoreData.initCutoff = initCutoff;
    if params.saveTrainScore
        scoreData.trainLabels = trainLabels;
        scoreData.trainScores = trainScores;
    end
end




