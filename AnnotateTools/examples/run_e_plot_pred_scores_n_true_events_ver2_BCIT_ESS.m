%% plot the locations of predicted events and true events
% 
% to reduce the number of hit, zero-out +/- 5 seconds of hit
%

clear; close all;

zeroSec = 5; % remove +/- 5 seconds around the  hit

%% path to raw scores (estimated by classifiers)
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR';	% to get the list of test files
scoreIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb_34_1_6_110_6';    % annotated samples
plotOut = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb_34_1_6_110_6_results';    

% testNames = {'X3 Baseline Guard Duty'; ...
%             'X4 Advanced Guard Duty'; ...
%             'Experiment X2 Traffic Complexity'; ...
%             'Experiment X6 Speed Control'; ...
%             'Experiment XB Baseline Driving'; 
%             'Experiment XC Calibration Driving'; ...
%             'X1 Baseline RSVP'; ...
%             'X2 RSVP Expertise'};
testNames = {'Experiment XB Baseline Driving'};

for t=1:length(testNames)
    testName = testNames{t};
    
    fileListDir = [fileListIn filesep testName]; 

    % Create a level 2 derevied study
    %  To get the list of file names
    derivedXMLFile = [fileListDir filesep level2DerivedFile];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
    [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);
    
    % go over all files and apply a feature extraction function
    for testSubjID=1:length(filenames)
        [path, name, ext] = fileparts(filenames{testSubjID});
        scoreDir = [scoreIn filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
        scoreData = []; % init scoreData
        load([scoreDir filesep name '.mat']);  % load scoreData

        plotEachOut = [plotOut filesep 'plot_pred_scores_n_true_events2' filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
        if ~isdir(plotEachOut)   % if the directory is not exist
            mkdir(plotEachOut);  % make the new directory
        end
        % zero-out +/- 5 seconds
        for dIdx=1:length(scoreData.weightedScore)
            weightedScore = scoreData.weightedScore{dIdx};
            [~, sIdx] = sort(weightedScore, 'descend');
            numbP = sum(weightedScore > 0);
            for i=1:numbP
                if weightedScore(sIdx(i)) > 0
                    beginIdx = sIdx(i) - (zeroSec * 8);
                    if beginIdx < 1 
                        beginIdx = 1;
                    end
                    weightedScore(beginIdx:sIdx(i)-1) = 0;
                    endIdx = sIdx(i) + (zeroSec * 8);
                    if endIdx > length(weightedScore)
                        endIdx = length(weightedScore);
                    end
                    weightedScore(sIdx(i)+1:endIdx) = 0;
                end
            end
            scoreData.weightedScore{dIdx} = weightedScore;
        end
        
        sureCount = plot_pred_scores_n_true_events_marking(scoreData.weightedScore, ...
                        scoreData.trueLabelOriginal{1}, ...
                        plotEachOut, ...
                        [testName ', session '  sessionNumbers{testSubjID}]);
% old style, no marking on sure cases                
%         plot_pred_scores_n_true_events(scoreData.weightedScore, ...
%                         scoreData.trueLabelOriginal{1}, ...
%                         plotEachOut, ...
%                         [testName ', session '  sessionNumbers{testSubjID}]);
        fprintf('session %s, sure %d\n', sessionNumbers{testSubjID}, sureCount);
    end
end







