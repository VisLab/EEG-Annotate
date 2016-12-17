%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%
%  Do not exclude boundary (masked) samples
%
function scoreData = classify_LDAs(dataTest, inPath_train, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    if isfield(params, 'targetClass')
        targetClass = params.targetClass;
    else
        error('Target class must be specified');
    end
    % LDA option
    DiscrimType = 'linear';             % default
    if isfield(params, 'DiscrimType')
        DiscrimType = params.DiscrimType;
    end
    Prior = 'empirical';        % default
    if isfield(params, 'Prior')
        Prior = params.Prior;
    end
    fTrainBalance = false;
    if isfield(params, 'fTrainBalance')
        fTrainBalance = params.fTrainBalance;
    end

    fileList_train = dir([inPath_train filesep '*.mat']);
    num_train = length(fileList_train);
    
    scoreData = struct('testLabel', [], ...
                        'predLabel', [], ...
                        'testFinalScore', [], 'testFinalCutoff', [], ...        % shift LDA init score so that it has zero cutoff. (for compatibility with ARRLS)
                        'testInitProb', [], 'testInitCutoff', []);              % LDA's score
    scoreData.testLabel = cell(1, 1);
    scoreData.predLabel = cell(num_train, 1);
    scoreData.testFinalScore = cell(num_train, 1);
    scoreData.testFinalCutoff = zeros(num_train, 1);
    scoreData.testInitProb = cell(num_train, 1);
    scoreData.testInitCutoff = zeros(num_train, 1);

    testSample = dataTest.samples;
    scoreData.testLabel = dataTest.labels; % it is not binary label. one sample can have more than one class label.
    % go over all test files and estimate scores
    for trainIdx = 1:num_train
        trainFileName = fileList_train(trainIdx).name;
        [trainSample, trainLabel] = getTrainingData(inPath_train, trainFileName, targetClass);

        if fTrainBalance == true
            [trainSample, trainLabel] = balanceOverMinor(trainSample, trainLabel);
        end
        
        ldaObj = fitcdiscr(trainSample', trainLabel, 'DiscrimType', DiscrimType, 'Prior', Prior);
    
        [predLabels, scores] = predict(ldaObj, testSample');
        
        scoreData.predLabel{trainIdx} = (predLabels == 1);  
        scoreData.testInitProb{trainIdx} = scores(: ,2);
        scoreData.testInitCutoff(trainIdx) = 0.5;
        % LDA retuns two columns of scores.
        % Each column is the probability to be in each class.
        scoreData.testFinalScore{trainIdx} = scores(: ,2) - 0.5;  % score (the probability of the second class), shift so that it has zero cutoff
        scoreData.testFinalCutoff(trainIdx) = 0;

        fprintf('LDA done, trainID, %d\n', trainIdx);
    end
end




