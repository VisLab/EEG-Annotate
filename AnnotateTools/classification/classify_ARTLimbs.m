%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%
%  Do not exclude boundary (masked) samples
%
function scoreData = classify_ARTLimbs(dataTest, inPath_train, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    if isfield(params, 'targetClass')
        targetClass = params.targetClass;
    else
        error('Target class must be specified');
    end
    % ARRLS option
    optionARRLS.p = 10;             % default
    if isfield(params, 'ARRLS_p')
        optionARRLS.p = params.ARRLS_p;
    end
    optionARRLS.sigma = 0.1;        % default
    if isfield(params, 'ARRLS_sigma')
        optionARRLS.sigma = params.ARRLS_sigma;
    end
    optionARRLS.lambda = 10.0;      % default
    if isfield(params, 'ARRLS_lambda')
        optionARRLS.lambda = params.ARRLS_lambda;
    end
    optionARRLS.gamma = 1.0;        % [0.1,10]
    if isfield(params, 'ARRLS_gamma')
        optionARRLS.gamma = params.ARRLS_gamma;
    end
    optionARRLS.ker = 'linear';     % 'rbf' | 'linear'
    if isfield(params, 'ARRLS_ker')
        optionARRLS.ker = params.ARRLS_ker;
    end
    % Imbalance option
    optionIMB.BT = true;             % default
    if isfield(params, 'IMB_BT')
        optionIMB.BT = params.IMB_BT;
    end
    optionIMB.AC1 = true;        % default
    if isfield(params, 'IMB_AC1')
        optionIMB.AC1 = params.IMB_AC1;
    end
    optionIMB.W = [true true false];      % default
    if isfield(params, 'IMB_W')
        optionIMB.W = params.IMB_W;
    end
    optionIMB.AC2 = true;        % [0.1,10]
    if isfield(params, 'IMB_AC2')
        optionIMB.AC2 = params.IMB_AC2;
    end
    fSaveTrainScore = false;
    if isfield(params, 'fSaveTrainScore')
        fSaveTrainScore = params.fSaveTrainScore;
    end

    fileList_train = dir([inPath_train filesep '*.mat']);
    num_train = length(fileList_train);
    
    scoreData = struct('testLabel', [], ...
                        'predLabel', [], ...
                        'testFinalScore', [], 'testFinalCutoff', [], ...
                        'testInitProb', [], 'testInitCutoff', [], ...
                        'trainLabel', [], ...
                        'trainScore', []);
    scoreData.testLabel = cell(1, 1);
    scoreData.predLabel = cell(num_train, 1);
    scoreData.testFinalScore = cell(num_train, 1);
    scoreData.testFinalCutoff = zeros(num_train, 1);
    scoreData.testInitProb = cell(num_train, 1);
    scoreData.testInitCutoff = zeros(num_train, 1);
    scoreData.trainLabel = cell(num_train, 1);
    scoreData.trainScore = cell(num_train, 1);

    testSample = dataTest.samples;
    scoreData.testLabel = dataTest.labels; % it is not binary label. one sample can have more than one class label.
    % go over all test files and estimate scores
    % In case of LDA, training loop is outer loop to avoid repeating of training classifiers.
    % In case of ARRLS, the loop reading larger dataset is outer loop to reduce the reading overhead.
    testLabeltemp = zeros(size(testSample, 2), 1);    % for temporary, use all zero labels.
    for trainIdx = 1:num_train
        trainFileName = fileList_train(trainIdx).name;
        [trainSample, trainLabel] = getTrainingData(inPath_train, trainFileName, targetClass);

        [finalScore, finalCutoff, initProb, initCutoff, trainScore] = ARRLS_imb(double(trainSample), double(testSample), trainLabel, testLabeltemp, optionARRLS, optionIMB);        
        
        scoreData.predLabel{trainIdx} = (finalScore > finalCutoff);  
        scoreData.testFinalScore{trainIdx} = finalScore;
        scoreData.testFinalCutoff(trainIdx) = finalCutoff;
        scoreData.testInitProb{trainIdx} = initProb;
        scoreData.testInitCutoff(trainIdx) = initCutoff;

        if fSaveTrainScore == true
            scoreData.trainLabel{trainIdx} = trainLabel;
            scoreData.trainScore{trainIdx} = trainScore;
        end
        
        fprintf('ARRLS done, trainID, %d\n', trainIdx);
    end
end




