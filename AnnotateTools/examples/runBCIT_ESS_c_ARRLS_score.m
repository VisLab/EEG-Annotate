%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%

%  classification parameter
targetClass = '35';

% ARRLS option
options.p = 10;             % keep default
options.sigma = 0.1;        % keep default
options.lambda = 10.0;      % keep default
options.gamma = 1.0;        % [0.1,10]
options.ker = 'linear';        % 'rbf' | 'linear'

% set path to training set
trainInPath = 'Z:\Data 2\Kyung\autoLabeling\data\AveragePower\zeroMean_unitStd\non_time_locked'; % path to VEP data set (extracted feature)

% set path to test set
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\';	% to get the list of test files
featureIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR_featureA\'; % path to extracted features
scoreOut = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR_featureA_scoreA\';    % save results

testNames = {'X3 Baseline Guard Duty'; ...
            'X4 Advanced Guard Duty'; ...
            'Experiment X2 Traffic Complexity'; ...
            'Experiment X6 Speed Control'; ...
            'Experiment XB Baseline Driving'; 
            'Experiment XC Calibration Driving'; ...
            'X1 Baseline RSVP'; ...
            'X2 RSVP Expertise'};

if ~isdir(scoreOut)   % if the directory is not exist
    mkdir(scoreOut);  % make the new directory
end

for t=1:length(testNames)
    testName = testNames{t};

    fileListDir = [fileListIn testName]; 
    featureDir = [featureIn testName]; 

    % Create a level 2 derevied study
    %  To get the list of file names
    derivedXMLFile = [fileListDir filesep level2DerivedFile];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
    [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);

    % save all scores into one file
    testsetNumb = length(filenames); 	% number of test dataset
    scoreData = struct('trueLabelOriginal', [], 'excludeIdx', [], 'predLabelBinary', [], 'scoreStandard', [], 'scoreOriginal', []);
    scoreData.trueLabelOriginal = cell(1, testsetNumb);
    scoreData.excludeIdx = cell(1, testsetNumb);
    scoreData.predLabelBinary = cell(18, testsetNumb);
    scoreData.scoreStandard = cell(18, testsetNumb);
    scoreData.scoreOriginal = cell(18, testsetNumb);
    scoreData.testName = testName;

    % go over all test files and estimate scores
    % In case of LDA, training loop is outer loop to avoid repeating of training classifiers.
    % In case of ARRLS, the loop reading larger dataset is outer loop to reduce the reading overhead.
    for trainSubjID = 1:18
        trainFileName = ['B_' num2str(trainSubjID, '%02d') '.mat'];
        [trainSamplePool, trainLabelPool] = getTrainingData(trainInPath, trainFileName, targetClass);

        % balance training samples 
        [trainSample, trainLabel] = balanceOverMinor(trainSamplePool, trainLabelPool);

        for testSubjID=1:testsetNumb
            [path, name, ext] = fileparts(filenames{testSubjID});

            [testSamplePool, testLabelOriginal, excludeIdx] = getTestData([featureIn testName filesep 'session' filesep sessionNumbers{testSubjID}], ['averagePower_' name '.mat']);

            if (trainSubjID == 1)  % do only one time
                scoreData.trueLabelOriginal{testSubjID} = testLabelOriginal;
                scoreData.excludeIdx{testSubjID} = excludeIdx;
                scoreData.sessionID{testSubjID} = sessionNumbers{testSubjID};
                scoreData.fileName{testSubjID} = filenames{testSubjID};
            end

            testLabeltemp = zeros(size(testSamplePool, 2), 1);    % for temporary, use all zero labels.

            % ARRLS calculates scores for each labels. If there are five labels, it will calculates 5 scores.
            % So make sure that there are only two labels in [trainLabel testLabel]
            [~,predLabels,~,scores] = ARRLSkyung(double(trainSample), double(testSamplePool), trainLabel, testLabeltemp, options);

            scoreData.predLabelBinary{trainSubjID, testSubjID} = predLabels - 1;  % predicted label 0 or 1
            scoreData.scoreOriginal{trainSubjID, testSubjID} = scores;

            % convert the result formats to the standard format 
            %
            % ARRLS retuns two scores for each class.
            % First it z-scales scores so that they have same scales.
            % Standard scores are defined as the difference of scaled scores.        
            scores = zscore(scores);                % z-normalization scores for each class
            scoreData.scoreStandard{trainSubjID, testSubjID} = scores(:, 2) - scores(:, 1);   % score: target score - non-target score

            fprintf('trainSubj, %d, testSubj, %d\n', trainSubjID, testSubjID);
        end
    end
    save([scoreOut filesep testName '.mat'], 'scoreData', '-v7.3');
end
