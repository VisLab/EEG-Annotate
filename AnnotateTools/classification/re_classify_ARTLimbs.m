%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%
%  Do not exclude boundary (masked) samples
%
function scoreData = re_classify_ARTLimbs(dataTest, test_initScore, inPath_train, inPath_train_initScore, testSubjID, varargin)

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
    reRankMethod = [];
    if isfield(params, 'reRankMethod')
        reRankMethod = params.reRankMethod;
    end

    fileList_train = dir([inPath_train filesep '*.mat']);
    num_train = length(fileList_train); % because it exclude the test subject (assuming the test and the training are same VEP dataset)
    
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
    scoreData.highScoreIdx = cell(num_train, 1);

    trainIdxes = 1:18;
    trainIdxes(trainIdxes == testSubjID) = [];
    highScoreTestIdx = getIdxOfHighCombinedScores(test_initScore, trainIdxes, 0);
    
    %scoreData2.highScoreIdx{testSubjID} = highScoreTestIdx;
    testSample = dataTest.samples(:, highScoreTestIdx);
    scoreData.testLabel = dataTest.labels(highScoreTestIdx); % it is not binary label. one sample can have more than one class label.
    fprintf('test set (%d), entire, %d, (%d, %d), positive, %d, (%d, %d)\n', ...
            testSubjID, ...
            length(dataTest.labels), getNumberOfClass(dataTest.labels, targetClass), length(dataTest.labels)-getNumberOfClass(dataTest.labels, targetClass), ...
            sum(highScoreTestIdx), getNumberOfClass(scoreData.testLabel, targetClass), sum(highScoreTestIdx)-getNumberOfClass(scoreData.testLabel, targetClass));
    
    % go over all test files and estimate scores
    % In case of LDA, training loop is outer loop to avoid repeating of training classifiers.
    % In case of ARRLS, the loop reading larger dataset is outer loop to reduce the reading overhead.
    testLabeltemp = zeros(size(testSample, 2), 1);    % for temporary, use all zero labels.
    fileList_train_initScore = dir([inPath_train_initScore filesep '*.mat']);
    if length(fileList_train) ~= length(fileList_train_initScore)
        error('number of files are not matched');
    end
    for trainIdx = 1:num_train
        train_initScore = load([inPath_train_initScore filesep fileList_train_initScore(trainIdx).name]); % load scoreData
        
        trainData = load([inPath_train filesep fileList_train(trainIdx).name]);
        
        if strcmp(reRankMethod, 'rrPositive')
            trainIdxes = 1:18;
            trainIdxes(trainIdxes == testSubjID) = [];  % exclude the scores estimated by test subjects
            trainIdxes(trainIdxes == trainIdx) = [];    % exclude the scores estimated by the self
            highScoreTrainIdx = getIdxOfHighCombinedScores(train_initScore.scoreData, trainIdxes, 0);
        elseif strcmp(reRankMethod, 'rrIterative')
            highScoreTrainIdx = ones(length(trainData.labels), 1)==1;
        else
            error('reranking method is not selected');
        end

        scoreData.highScoreIdx{trainIdx} = highScoreTrainIdx;
        trainSample = trainData.samples(:, highScoreTrainIdx);
        trainLabel = trainData.labels(highScoreTrainIdx);

        fprintf('train set (%d), entire, %d, (%d, %d), positive, %d, (%d, %d)\n', ...
                trainIdx, ...
                length(trainData.labels), getNumberOfClass(trainData.labels, targetClass), length(trainData.labels)-getNumberOfClass(trainData.labels, targetClass), ...
                sum(highScoreTrainIdx), getNumberOfClass(trainLabel, targetClass), sum(highScoreTrainIdx)-getNumberOfClass(trainLabel, targetClass));
        
        trainLabel = convertToBinaryLabel(trainLabel, targetClass);
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

function numberOfClass = getNumberOfClass(labels, classStr)

    binaryLabels = convertToBinaryLabel(labels, classStr);
    numberOfClass = sum(binaryLabels);
end

function binaryLabels = convertToBinaryLabel(labels, targetClass)

    binaryLabels = zeros(length(labels), 1);
    for i1=1:length(labels)
        if ~isempty(labels{i1})
            for i2=1:length(labels{i1})
                if strcmp(labels{i1}{i2}, targetClass)
                    binaryLabels(i1) = 1;
                end
            end
        end
    end
end

function highScoreIdx = getIdxOfHighCombinedScores(scoreData, trainIdxes, highCutOff)

    adaptiveCutoff = true;   % default: fixed cutoff 0.0 
    rescaleBeforeCombining = true;  
    position = 8;     
    weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5];    

    for trainIdx = trainIdxes
        rawScore = scoreData.testFinalScore{trainIdx};

        % calculate weighted sub-windows scores
        wScore = getWeightedScore(rawScore, weights, position);

        if adaptiveCutoff == true
            cutoff = getCutoff_FL(wScore);
        else
            cutoff = 0.0;
        end
                
        % Use a greedy algorithm to take best scores
        mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements         

        scoreData.wmScore{trainIdx} = mScore; % weighted and mask-out score
    end
    
    allScores = [];
    for trainIdx = trainIdxes
        wmScore = scoreData.wmScore{trainIdx};

        if rescaleBeforeCombining == true
            nonZeroScore = wmScore(wmScore > 0);
            cutMax = mean(nonZeroScore); % - (1 * std(nonZeroScore));
          
            wmScore(wmScore > cutMax) = cutMax;
            wmScore = wmScore ./ cutMax;
        end
        allScores = cat(2, allScores, wmScore);
    end
    scoreData.allScores = allScores;
    
    theseScores = mean(allScores, 2);   % sum of sub-window scores
    if sum(isnan(theseScores)) > 0
        error('nan score');
    end
    % Make up a weighting and calculate weighted scores
    wScore = getWeightedScore(theseScores, weights, position);% don't exclude negative scores

    if adaptiveCutoff == true
        cutoff = getCutoff_FL(wScore);
    else
        cutoff = 0.5;
    end
    
    % Use a greedy algorithm to take best scores
    mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements         
    scoreData.combinedScore = mScore;
    highScoreIdx = (mScore > highCutOff);
end