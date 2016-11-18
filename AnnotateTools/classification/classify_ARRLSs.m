%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%
%  Do not exclude boundary (masked) samples
%
function scoreData = classify_ARRLSs(dataTest, inPath_train, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    if isfield(params, 'targetClass')
        targetClass = params.targetClass;
    else
        error('Target class must be specified');
    end
    % ARRLS option
    options.p = 10;             % default
    if isfield(params, 'p')
        config.windowLength = params.p;
    end
    options.sigma = 0.1;        % default
    if isfield(params, 'sigma')
        config.windowLength = params.sigma;
    end
    options.lambda = 10.0;      % default
    if isfield(params, 'lambda')
        config.windowLength = params.lambda;
    end
    options.gamma = 1.0;        % [0.1,10]
    if isfield(params, 'gamma')
        config.windowLength = params.gamma;
    end
    options.ker = 'linear';     % 'rbf' | 'linear'
    if isfield(params, 'ker')
        options.ker = params.ker;
    end
    fSaveTrainScore = false;
    if isfield(params, 'fSaveTrainScore')
        fSaveTrainScore = params.fSaveTrainScore;
    end

    fileList_train = dir([inPath_train filesep '*.mat']);
    num_train = length(fileList_train);
    
    scoreData = struct('trueLabelOriginal', [], 'predLabelBinary', [], 'scoreStandard', [], 'scoreOriginal', [],...
                        'trainLabel', [], 'trainScore', [], 'trainOriginalLength', []);
    scoreData.trueLabelOriginal = cell(1, 1);
    scoreData.predLabelBinary = cell(num_train, 1);
    scoreData.scoreStandard = cell(num_train, 1);
    scoreData.scoreOriginal = cell(num_train, 1);
    scoreData.trainLabel = cell(num_train, 1);
    scoreData.trainScore = cell(num_train, 1);
    scoreData.trainOriginalLength = zeros(num_train, 1);

    testSamplePool = dataTest.samples;
    scoreData.trueLabelOriginal = dataTest.labels;
    
    % go over all test files and estimate scores
    % In case of LDA, training loop is outer loop to avoid repeating of training classifiers.
    % In case of ARRLS, the loop reading larger dataset is outer loop to reduce the reading overhead.
    testLabeltemp = zeros(size(testSamplePool, 2), 1);    % for temporary, use all zero labels.
    for trainIdx = 1:num_train
        trainFileName = fileList_train(trainIdx).name;
        [trainSamplePool, trainLabelPool] = getTrainingData(inPath_train, trainFileName, targetClass);

        % balance training samples 
        [trainSample, trainLabel] = balanceOverMinor(trainSamplePool, trainLabelPool);

        % ARRLS calculates scores for each labels. If there are five labels, it will calculates 5 scores.
        % So make sure that there are only two labels in [trainLabel testLabel]
        [~,predLabels,~,scores, trainScore] = ARRLSkyung(double(trainSample), double(testSamplePool), trainLabel, testLabeltemp, options);

        scoreData.predLabelBinary{trainIdx} = predLabels - 1;  % predicted label 0 or 1
        scoreData.scoreOriginal{trainIdx} = scores;

        % convert the result formats to the standard format 
        %
        % ARRLS retuns non-standard scores for each class.
        % Standard scores are defined as the normalized difference.        
        scoreData.scoreStandard{trainIdx} = zscore(scores(:, 2) - scores(:, 1));   % zscores(target score - non-target score)

        if fSaveTrainScore == true
            scoreData.trainLabel{trainIdx} = trainLabel;
            scoreData.trainScore{trainIdx} = trainScore;
            scoreData.trainOriginalLength(trainIdx) = length(trainLabelPool);
        end
        
        fprintf('ARRLS done, trainID, %d\n', trainIdx);
    end
end




