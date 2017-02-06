%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%
%  Do not exclude boundary (masked) samples
%
function scoreData = classifyARRLS(dataTest, dataTrain, targetClass, params)

    %% Setup the parameters and reporting for the call
   params = processAnnotateParameters('classifyARRLS', nargin, 3, params);
  
    %% Initialize the return structure
    scoreData = getScoreDataStructure(); 
 
    %% Set up the training data
    testSamples = dataTest.samples;
    scoreData.trueLabels = dataTest.labels;
    [trainSamples, trainLabels] = getTrainingData(dataTrain, targetClass);
    if params.ARRLSBalanceTrain
        [trainSamples, trainLabels] = balanceOverMinor(trainSamples, trainLabels);
    end
    testLabeltemp = zeros(size(testSamples, 2), 1);    % for temporary, use all zero labels.
    [finalScores, finalCutoff, initProbs, initCutoff, trainScores] = ...
        ARRLS(double(trainSamples), double(testSamples), trainLabels, ...
              testLabeltemp, params);
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