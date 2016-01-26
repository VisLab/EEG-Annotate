%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%

trainInPath = 'Z:\Data 2\Kyung\autoLabeling\data\AveragePower\zeroMean_unitStd\non_time_locked'; % path to VEP data set (extracted feature)

%% set path to test set
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\';	% to get the list of test files
featureIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_feature\averagePower\';
scoreOut = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_score\';

testName = 'Experiment X2 Traffic Complexity'; % 64 channels;
% testName = 'Experiment X6 Speed Control'; 
% testName = 'Experiment XB Baseline Driving'; 
% testName = 'Experiment XC Calibration Driving'; 
% testName = 'X1 Baseline RSVP'; % 256 channels;
% testName = 'X2 RSVP Expertise'; 
% testName = 'X3 Baseline Guard Duty'; 
% testName = 'X4 Advanced Guard Duty'; 

fileListDir = [fileListIn testName]; 
featureDir = [featureIn testName]; 
scoreOutDir = [scoreOut testName]; 

%% Create a level 2 derevied study
%  To get the list of file names
derivedXMLFile = [fileListDir filesep level2DerivedFile];
obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
[filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);

%%  classification parameter
targetClass = '35';
% ARRLS option
options.p = 10;             % keep default
options.sigma = 0.1;        % keep default
options.lambda = 10.0;      % keep default
options.gamma = 1.0;        % [0.1,10]
options.ker = 'linear';        % 'rbf' | 'linear'

%% save all scores into one file
testsetNumb = length(filenames); 	% number of test dataset
results = struct('trueLabelOriginal', [], 'excludeIdx', [], 'predLabelBinary', [], 'scoreStandard', [], 'scoreOriginal', []);
results.trueLabelOriginal = cell(1, testsetNumb);
results.excludeIdx = cell(1, testsetNumb);
results.predLabelBinary = cell(18, testsetNumb);
results.scoreStandard = cell(18, testsetNumb);
results.scoreOriginal = cell(18, testsetNumb);

%% go over all test files and estimate scores
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
            results.trueLabelOriginal{testSubjID} = testLabelOriginal;
            results.excludeIdx{testSubjID} = excludeIdx;
        end
        
        testLabeltemp = zeros(size(testSamplePool, 2), 1);    % for temporary, use all zero labels.
        
        % ARRLS calculates scores for each labels. If there are five labels, it will calculates 5 scores.
        % So make sure that there are only two labels in [trainLabel testLabel]
        [~,predLabels,~,scores] = ARRLSkyung(double(trainSample), double(testSamplePool), trainLabel, testLabeltemp, options);
        
        results.predLabelBinary{trainSubjID, testSubjID} = predLabels - 1;  % predicted label 0 or 1
        results.scoreOriginal{trainSubjID, testSubjID} = scores;
        
        % convert the result formats to the standard format 
        %
        % ARRLS retuns two scores for each class.
        % First it z-scales scores so that they have same scales.
        % Standard scores are defined as the difference of scaled scores.        
        scores = zscore(scores);                % z-normalization scores for each class
        results.scoreStandard{trainSubjID, testSubjID} = scores(:, 2) - scores(:, 1);   % score: target score - non-target score
        
        fprintf('trainSubj, %d, testSubj, %d\n', trainSubjID, testSubjID);
	end
end
if ~isdir(scoreOut)   % if the directory is not exist
	mkdir(scoreOut);  % make the new directory
end
save([scoreOut filesep testName '_ARRLS.mat'], 'results', '-v7.3');
