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
        error('Targget class must be specified');
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

    fileList_train = dir([inPath_train filesep '*.mat']);
    num_train = length(fileList_train);
    
    scoreData = struct('trueLabelOriginal', [], 'excludeIdx', [], 'predLabelBinary', [], 'scoreStandard', [], 'scoreOriginal', []);
    scoreData.trueLabelOriginal = cell(1, 1);
    scoreData.excludeIdx = cell(1, 1);
    scoreData.predLabelBinary = cell(num_train, 1);
    scoreData.scoreStandard = cell(num_train, 1);
    scoreData.scoreOriginal = cell(num_train, 1);
    scoreData.testName = testName;

    testSamplePool = dataTest.testSamplePool;
    testLabelOriginal = dataTest.testLabelOriginal;
    excludeIdx = dataTest.excludeIdx;

    scoreData.trueLabelOriginal{1} = testLabelOriginal;
    scoreData.excludeIdx{1} = excludeIdx;

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
        [~,predLabels,~,scores] = ARRLSkyung(double(trainSample), double(testSamplePool), trainLabel, testLabeltemp, options);

        scoreData.predLabelBinary{trainIdx} = predLabels - 1;  % predicted label 0 or 1
        scoreData.scoreOriginal{trainIdx} = scores;

        % convert the result formats to the standard format 
        %
        % ARRLS retuns two scores for each class.
        % First it z-scales scores so that they have same scales.
        % Standard scores are defined as the difference of scaled scores.        
        scores = zscore(scores);                % z-normalization scores for each class
        scoreData.scoreStandard{trainIdx} = scores(:, 2) - scores(:, 1);   % score: target score - non-target score

        fprintf('trainSubj, %d, testSubj, %d\n', trainIdx, testSubjID);
    end
end




