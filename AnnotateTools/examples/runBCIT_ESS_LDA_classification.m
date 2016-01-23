%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%

trainInPath = ''; % path to VEP data set (extracted feature)

%% set path to test set
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\';	% to get file list
featureIn = 'D:\Temp\Data 3\BCIT_ESS\Level2_256Hz_feature\averagePower\';
scoreOut = 'D:\Temp\Data 3\BCIT_ESS\Level2_256Hz_score\LDA\';

% testName = 'Experiment X2 Traffic Complexity'; % 64 channels;
testName = 'Experiment X6 Speed Control'; 
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
LDAparam1 = 'linear';
LDAparam2 = 'empirical'; % 'empirical' | 'uniform'

%% save all scores into one file
testsetNumb = length(filenames); 	% number of test dataset
results = struct('trueLabelBinary', [], 'trueLabelOriginal', [], 'predLabelBinary', [], 'scoreStandard', [], 'scoreOriginal', []);
results.trueLabelBinary = cell(testsetNumb, 1);
results.trueLabelOriginal = cell(testsetNumb, 1);
results.predLabelBinary = cell(testsetNumb, 18);
results.scoreStandard = cell(testsetNumb, 18);
results.scoreOriginal = cell(testsetNumb, 18);

%% go over all test files and estimate scores
for trainSubjID = 1:18
    fileName = ['B_' num2str(trainSubjID, '%02d') '.mat'];
    [trainSamplePool, trainLabelPool] = getTrainingData1(dataPath, fileName, targetClass);
    
    % balance training samples 
    [trainSample, trainLabel] = balanceOverMinor(trainSamplePool, trainLabelPool);
    
    ldaObj = fitcdiscr(trainSample', trainLabel, 'DiscrimType', LDAparam1, 'Prior', LDAparam2);

	for i=1:testsetNumb
		[path, name, ext] = fileparts(filenames{i});
		testset = load([featureIn testName filesep 'session' filesep sessionNumbers{i} filesep 'averagePower_' name '.mat']);
		
        [testSamplePool, testLabelPool, testLabelOriginal] = getTestData(dataPath, fileName, targetClass);
                
        results.trueLabelBinary{testSubjID} = testLabelPool;
        results.trueLabelOriginal{testSubjID} = testLabelOriginal;
        
        [predLabels, scores] = predict(ldaObj, testSamplePool');
        
        results.predLabelBinary{trainSubjID, testSubjID} = predLabels;  % predicted label 0 or 1
        results.scoreOriginal{trainSubjID, testSubjID} = scores;
        % LDA retuns two columns of scores.
        % Each column is the probability to be in each class.
        % Classes = [others target]
        results.scoreStandard{trainSubjID, testSubjID} = scores(: ,2); % score: the probability of the second class
        
        fprintf('trainSubj, %d, testSubj, %d\n', trainSubjID, testSubjID);
	end
end
if ~isdir(scoreOut)   % if the directory is not exist
	mkdir(scoreOut);  % make the new directory
end
save([scoreOut filesep testName '_LDAscore.mat'], 'results', '-v7.3');
