function scoreData = classifyARRLSimb(dataTest, dataTrain, ...
                                       targetClass, params)
%% Classify test data using the ARRLSimb classifier
%
%  Parameters:
%     dataPathTest   full path name test data
%          samples   an array with feature vectors in the columns
%          labels    cell array of labels corresponding to feature vectors
%                    if unlabeled the cell is empty
%     dataPathTrain  full path name of training data (same format as training)
%     targetClass    string containing target class
%     varargin       name-value pair parameters  (KYUNG PLEASE DOCUMENT)
%
%     scoreData
%
% 
%% Set the parameters and reporting for the call   
    params = processAnnotateParameters('classifyARRLSimb', nargin, 3, params);
    
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
% %% Set the imbalance options
%     optionIMB.BT = true;              
%     if isfield(params, 'IMB_BT')
%         optionIMB.BT = params.IMB_BT;
%     end
%     optionIMB.AC1 = true;        
%     if isfield(params, 'IMB_AC1')
%         optionIMB.AC1 = params.IMB_AC1;
%     end
%     optionIMB.W = [true true false];      
%     if isfield(params, 'IMB_W')
%         optionIMB.W = params.IMB_W;
%     end
%     optionIMB.AC2 = true;        % [0.1,10]
%     if isfield(params, 'IMB_AC2')
%         optionIMB.AC2 = params.IMB_AC2;
%     end
%     fSaveTrainScore = false;
%     if isfield(params, 'fSaveTrainScore')
%         fSaveTrainScore = params.fSaveTrainScore;
%     end
%     pseudoLabels = [];
%     if isfield(params, 'pseudoLabel')
%         pseudoLabels = params.pseudoLabels;
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
    [finalScores, finalCutoff, initProbs, initCutoff, trainScores] = ...
        ARRLSimb(double(trainSamples), double(testSamples), ...
                     trainLabels, params.pseudoLabels, params);   
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




