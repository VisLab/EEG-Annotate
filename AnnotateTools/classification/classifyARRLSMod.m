function scoreData = classifyARRLSMod(dataTest, dataTrain, targetClass, params)
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
    params = processAnnotateParameters('classifyARRLSMod', nargin, 3, params);

% %% Set ARRLS options
%     optionARRLS.p = 10;             
%     if isfield(params, 'ARRLS_p')
%         optionARRLS.p = params.ARRLS_p;
%     end
%     optionARRLS.sigma = 0.1;         
%     if isfield(params, 'ARRLS_sigma')
%         optionARRLS.sigma = params.ARRLS_sigma;
%     end
%     optionARRLS.lambda = 10.0;       
%     if isfield(params, 'ARRLS_lambda')
%         optionARRLS.lambda = params.ARRLS_lambda;
%     end
%     optionARRLS.gamma = 1.0;        % [0.1,10]
%     if isfield(params, 'ARRLS_gamma')
%         optionARRLS.gamma = params.ARRLS_gamma;
%     end
%     optionARRLS.ker = 'linear';     % 'rbf' | 'linear'
%     if isfield(params, 'ARRLS_ker')
%         optionARRLS.ker = params.ARRLS_ker;
%     end
%     
%     fSaveTrainScore = false;
%     if isfield(params, 'fSaveTrainScore')
%         fSaveTrainScore = params.fSaveTrainScore;
%     end
%% Initialize return structure
    scoreData = getScoreDataStructure();

%% Load the data
    [trainSamples, trainLabels] = getTrainingData(dataTrain, targetClass);
    testSamples = dataTest.samples;
    scoreData.trueLabels = dataTest.labels; % it is not binary label. one sample can have more than one class label.
    % go over all test files and estimate scores
    % In case of LDA, training loop is outer loop to avoid repeating of training classifiers.
    % In case of ARRLS, the loop reading larger dataset is outer loop to reduce the reading overhead. 
    
    %% Compute pseudolabels by training a logistic regression classifier
      tempTestLabels = zeros(size(testSamples, 2), 1);
      [Xtmp, Ytmp] = balanceOverMinor(sparse(double(trainSamples)), trainLabels);
      model = train(Ytmp, sparse(Xtmp'), '-s 0 -c 1 -q 1');
      [~, ~, initProbs] = predict(tempTestLabels, sparse(testSamples'), model, '-b 1');
      initProbs = initProbs(:, 2);
      pseudoLabels = double(initProbs > 0.5) + 1; % Positive class is 2
      [finalScores, finalCutoff, initProbs, initCutoff, trainScores] = ...
          ARRLS(double(trainSamples), double(testSamples), ...
                trainLabels, pseudoLabels, params);   
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




