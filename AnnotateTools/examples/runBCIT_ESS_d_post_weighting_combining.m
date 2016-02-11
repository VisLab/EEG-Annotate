%% add weighting and zero-out scores to score data structure
% 
%  - do mask scores and zero-out scores
%  - use the fixed weight vectors
%  - assume 18 training sets (VEP training dataset)
%

% weights 
position = 8;
weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5];

%% path to raw scores (estimated by classifiers)
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\';	% to get the list of test files
scoreBase = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR_featureA_scoreAexcludeOn\';	% path to estimated scores

% testNames = {'X3 Baseline Guard Duty'; ...
%             'X4 Advanced Guard Duty'; ...
%             'Experiment X2 Traffic Complexity'; ...
%             'Experiment X6 Speed Control'; ...
%             'Experiment XB Baseline Driving'; 
%             'Experiment XC Calibration Driving'; ...
%             'X1 Baseline RSVP'; ...
%             'X2 RSVP Expertise'};
testNames = {'X3 Baseline Guard Duty'; ...
            'X4 Advanced Guard Duty'; ...
            'Experiment X2 Traffic Complexity'; ...
            'Experiment X6 Speed Control'; ...
            'X1 Baseline RSVP'};

for t=1:length(testNames)
    testName = testNames{t};
    
    fileListDir = [fileListIn testName]; 

    % Create a level 2 derevied study
    %  To get the list of file names
    derivedXMLFile = [fileListDir filesep level2DerivedFile];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
    [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);
    
    % go over all files and apply a feature extraction function
    for testSubjID=1:length(filenames)
        [path, name, ext] = fileparts(filenames{testSubjID});
        scoreDir = [scoreBase testName filesep 'session' filesep sessionNumbers{testSubjID}];
        load([scoreDir filesep name '.mat']);  % load scoreData
        
        trainsetNumb = size(scoreData.scoreStandard, 1);

        testSampleNumb = length(scoreData.trueLabelOriginal{1});
        excludeIdx = scoreData.excludeIdx{1};
        
        allScores = [];
        for trainSubjID = 1:trainsetNumb
            rawScore = zeros(1, testSampleNumb);
            rawScore(excludeIdx == 0) = scoreData.scoreStandard{trainSubjID};

            % calculate weighted scores
            s = rescore3(rawScore, weights, position, excludeIdx);
            
            % Use a greedy algorithm to take best scores
            sNew = maskScores2(s, 7);  % zero out 15 elements         
            
            % weighted score. note that it has the same length to true labels    
            scoreData.weightedScore{trainSubjID} = sNew;
            
            cutMax = prctile(sNew, 95);
            sNew(sNew > cutMax) = cutMax;
            sNew = sNew ./ cutMax;
            allScores = cat(1, allScores, sNew);
            
            fprintf('trainSubj, %d, testSubj, %d\n', trainSubjID, testSubjID);
        end
        theseScores = sum(allScores, 1);   % sum of sub-window scores
        % Make up a weighting and calculate weighted scores
        s = rescore3(theseScores, weights, position, excludeIdx);% don't exclude negative scores

        % Use a greedy algorithm to take best scores
        sNew = maskScores2(s, 7);  % zero out 15 elements
        
        scoreData.combinedScore{1} = sNew;
        
        save([scoreDir filesep name '.mat'], 'scoreData', '-v7.3');
    end
end







