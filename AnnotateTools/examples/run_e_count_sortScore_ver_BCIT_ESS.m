%% plot annotated samples
% 

clear; close all;

%% parameter
timingTolerance = 3;
detailedPlotHeight = 300; % negative (-1) to turn off plotting details
offPast = 40;
offFuture = 80;

% 5 events
tickLabels = {'Valid', ...          % 1
                'Not valid', ...    % 2
                'Allow', ...        % 3
                'Deny', ...         % 4
                'No event', ...     % 5
                'Low score'};       % 6    ==> zero-out score

cmap = [0.2, 0.3, 1.0       % Blue:  'Valid'
        0.0, 0.0, 0.0       % Black: 'Not Valid'  
        0.0, 1.0, 0.0       % Green: 'Allow'  
        1.0, 0.0, 0.0];       % Red:  'Deny'  
            
%% path to raw scores (estimated by classifiers)
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR';	% to get the list of test files
scoreIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreAexcludeOn';    % annotated samples
countOut = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreAexcludeOn_results';    

% testNames = {'X3 Baseline Guard Duty'; ...
%             'X4 Advanced Guard Duty'; ...
%             'Experiment X2 Traffic Complexity'; ...
%             'Experiment X6 Speed Control'; ...
%             'Experiment XB Baseline Driving'; 
%             'Experiment XC Calibration Driving'; ...
%             'X1 Baseline RSVP'; ...
%             'X2 RSVP Expertise'};
testNames = {'X3 Baseline Guard Duty'; ...
            'X4 Advanced Guard Duty'};

eventNumb = length(tickLabels)-1;        
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

        countEachOut = [countOut filesep 'count_sortScore_event' num2str(eventNumb) '_tolerance' num2str(timingTolerance) '_offset_' num2str(offPast) '_' num2str(offFuture) filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
        if ~isdir(countEachOut)   % if the directory is not exist
            mkdir(countEachOut);  % make the new directory
        end
        count_sortScore(scoreData.combinedScore{1}, ...
                        scoreData.trueLabelOriginal{1}, ...
                        timingTolerance, ...
                        detailedPlotHeight, ...
                        tickLabels, ...
                        cmap, ...
                        offPast, offFuture, ...
                        countEachOut, ...
                        [testName ', session '  sessionNumbers{testSubjID}]);
    end
end
