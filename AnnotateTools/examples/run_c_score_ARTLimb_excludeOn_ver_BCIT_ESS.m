%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%
%  Do not exclude boundary (masked) samples
%

%  classification parameter
targetClass = '34';

% ARRLS option
optionARRLS = struct('ker', 'linear', 'sigma', 0.1, 'lambda', 10.0, 'gamma', 1.0, 'p', 10);
optionIMB = struct('BT', 1, 'AC1', 6, 'W', [1 1 0], 'AC2', 6); % 0 (false, skip), 1 (true, include it)
optionETC = struct('bVerbose', 0);

% set path to training set
trainInPath = 'Z:\Data 4\annotate\VEP\AveragePower\zeroMean_unitStd\non_time_locked'; % path to VEP data set (extracted feature)

% set path to test set
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR\';	% to get the list of test files
featureIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA\'; % path to extracted features
scoreOut = ['Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb_' num2str(targetClass) '_' num2str(optionIMB.BT) '_' num2str(optionIMB.AC1) '_' num2str(optionIMB.W(1)) num2str(optionIMB.W(2)) num2str(optionIMB.W(3)) '_' num2str(optionIMB.AC2)  '\'];    % save results

testNames = {'Experiment XB Baseline Driving'; 
            'Experiment XC Calibration Driving'};
% testNames = {'X3 Baseline Guard Duty'; ...
%             'X4 Advanced Guard Duty'; ...
%             'Experiment X2 Traffic Complexity'; ...
%             'Experiment X6 Speed Control'; ...
%             'Experiment XB Baseline Driving'; 
%             'Experiment XC Calibration Driving'; ...
%             'X1 Baseline RSVP'; ...
%             'X2 RSVP Expertise'};

for t=1:length(testNames)
    testName = testNames{t};

    fileListDir = [fileListIn testName]; 
    featureDir = [featureIn testName]; 

    % Create a level 2 derevied study
    %  To get the list of file names
    derivedXMLFile = [fileListDir filesep level2DerivedFile];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
    [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);

    % go over all files and apply a feature extraction function
    for testSubjID=1:length(filenames)
        
        scoreData = struct('trueLabelOriginal', [], 'excludeIdx', [], 'predLabelBinary', [], 'scoreStandard', [], 'scoreOriginal', []);
        scoreData.trueLabelOriginal = cell(1, 1);
        scoreData.excludeIdx = cell(1, 1);
        scoreData.predLabelBinary = cell(18, 1);
        scoreData.scoreStandard = cell(18, 1);
        scoreData.scoreOriginal = cell(18, 1);
        scoreData.testName = testName;
        
        [path, name, ext] = fileparts(filenames{testSubjID});
        
        [testSamplePool, testLabelOriginal, excludeIdx] = getTestData([featureIn testName filesep 'session' filesep sessionNumbers{testSubjID}], ['averagePower_' name '.mat']);

        scoreData.trueLabelOriginal{1} = testLabelOriginal;
        scoreData.excludeIdx{1} = excludeIdx;
        scoreData.sessionID{1} = sessionNumbers{testSubjID};
        scoreData.fileName{1} = filenames{testSubjID};

        % go over all test files and estimate scores
        % In case of LDA, training loop is outer loop to avoid repeating of training classifiers.
        % In case of ARRLS, the loop reading larger dataset is outer loop to reduce the reading overhead.
        testLabeltemp = zeros(size(testSamplePool, 2), 1);    % for temporary, use all zero labels.
        for trainSubjID = 1:18
            trainFileName = ['B_' num2str(trainSubjID, '%02d') '.mat'];
            [trainSamplePool, trainLabelPool] = getTrainingData(trainInPath, trainFileName, targetClass);

            % balance training samples 
            %[trainSample, trainLabel] = balanceOverMinor(trainSamplePool, trainLabelPool);
 
            % ARRLS calculates scores for each labels. If there are five labels, it will calculates 5 scores.
            % So make sure that there are only two labels in [trainLabel testLabel]
            %[~,predLabels,~,scores] = ARRLSkyung(double(trainSample), double(testSamplePool), trainLabel, testLabeltemp, options);
            
            [~, finalScore, finalCutoff, ~, ~] = ARRLS_imb(trainSamplePool, testSamplePool, trainLabelPool, testLabeltemp, optionARRLS, optionIMB, optionETC);        
            predLabels = (finalScore > finalCutoff);

            scoreData.predLabelBinary{trainSubjID} = predLabels;  % predicted label 0 or 1
            scoreData.scoreOriginal{trainSubjID} = zscore(finalScore);

            % convert the result formats to the standard format 
            %
            % ARRLS retuns two scores for each class.
            % First it z-scales scores so that they have same scales.
            % Standard scores are defined as the difference of scaled scores.        
            %scores = zscore(scores);                % z-normalization scores for each class
            scoreData.scoreStandard{trainSubjID} = zscore(finalScore);   % score: target score - non-target score

            fprintf('trainSubj, %d, testSubj, %d\n', trainSubjID, testSubjID);
        end
        
        scoreDir = [scoreOut testName filesep 'session' filesep sessionNumbers{testSubjID}];
        saveFile = [name '.mat'];   % new file name = ['averagePower_' old file name];
        if ~isdir(scoreDir)   % if the directory is not exist
            mkdir(scoreDir);  % make the new directory
        end
        save([scoreDir filesep saveFile], 'scoreData', '-v7.3');
    end    
    fprintf('%s\n', 'Score done\n');
end



