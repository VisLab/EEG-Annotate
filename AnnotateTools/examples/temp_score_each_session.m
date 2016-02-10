%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%
%  Do not exclude boundary (masked) samples
%

% set path to test set
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_HP\';	% to get the list of test files
scoreOut = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_HP_featureA_scoreA\';    % save results

testNames = {'X3 Baseline Guard Duty'; ...
            'X4 Advanced Guard Duty'; ...
            'Experiment X2 Traffic Complexity'; ...
            'Experiment X6 Speed Control'; ...
            'Experiment XB Baseline Driving'; 
            'Experiment XC Calibration Driving'; ...
            'X1 Baseline RSVP'; ...
            'X2 RSVP Expertise'};

for t=1:length(testNames)
    testName = testNames{t};

    fileListDir = [fileListIn testName]; 

    % Create a level 2 derevied study
    %  To get the list of file names
    derivedXMLFile = [fileListDir filesep level2DerivedFile];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
    [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);

    oldScore = load([scoreOut testName '.mat']);
    
    % go over all files and apply a feature extraction function
    for testSubjID=1:length(filenames)
        scoreData = struct('trueLabelOriginal', [], 'excludeIdx', [], 'predLabelBinary', [], 'scoreStandard', [], 'scoreOriginal', []);
        
        scoreData.trueLabelOriginal = cell(1, 1);
        scoreData.excludeIdx = cell(1, 1);
        scoreData.predLabelBinary = cell(18, 1);
        scoreData.scoreStandard = cell(18, 1);
        scoreData.scoreOriginal = cell(18, 1);
        scoreData.testName = testName;
        
        
        scoreData.trueLabelOriginal{1} = oldScore.scoreData.trueLabelOriginal{testSubjID};
        scoreData.excludeIdx{1} = oldScore.scoreData.excludeIdx{testSubjID};
        scoreData.sessionID{1} = oldScore.scoreData.sessionID{testSubjID};
        scoreData.fileName{1} = oldScore.scoreData.fileName{testSubjID};

        for trainSubjID = 1:18
            scoreData.predLabelBinary{trainSubjID} = oldScore.scoreData.predLabelBinary{trainSubjID, testSubjID};  % predicted label 0 or 1
            scoreData.scoreOriginal{trainSubjID} = oldScore.scoreData.scoreOriginal{trainSubjID, testSubjID};
            scoreData.scoreStandard{trainSubjID} = oldScore.scoreData.scoreStandard{trainSubjID, testSubjID};   % score: target score - non-target score

            fprintf('trainSubj, %d, testSubj, %d\n', trainSubjID, testSubjID);
        end
        
        scoreDir = [scoreOut testName filesep 'session' filesep sessionNumbers{testSubjID}];
        
        [path, name, ext] = fileparts(filenames{testSubjID});
        saveFile = [name '.mat'];   % new file name = ['averagePower_' old file name];
        if ~isdir(scoreDir)   % if the directory is not exist
            mkdir(scoreDir);  % make the new directory
        end
        save([scoreDir filesep saveFile], 'scoreData', '-v7.3');
    end    
    fprintf('%s\n', 'Score done\n');
end



