%% plot the locations of predicted events and true events

clear; close all;

%% path to raw scores (estimated by classifiers)
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR';	% to get the list of test files
scoreIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb';    % annotated samples
plotOut = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb_results';    

% testNames = {'X3 Baseline Guard Duty'; ...
%             'X4 Advanced Guard Duty'; ...
%             'Experiment X2 Traffic Complexity'; ...
%             'Experiment X6 Speed Control'; ...
%             'Experiment XB Baseline Driving'; 
%             'Experiment XC Calibration Driving'; ...
%             'X1 Baseline RSVP'; ...
%             'X2 RSVP Expertise'};
testNames = {'Experiment XC Calibration Driving'};

for t=1:length(testNames)
    testName = testNames{t};
    
    fileListDir = [fileListIn filesep testName]; 

    % Create a level 2 derevied study
    %  To get the list of file names
    derivedXMLFile = [fileListDir filesep level2DerivedFile];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
    [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);
    
    % go over all files and apply a feature extraction function
    for testSubjID=2:length(filenames)
        [path, name, ext] = fileparts(filenames{testSubjID});
        scoreDir = [scoreIn filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
        scoreData = []; % init scoreData
        load([scoreDir filesep name '.mat']);  % load scoreData

        plotEachOut = [plotOut filesep 'plot_pred_labels_n_true_events' filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
        if ~isdir(plotEachOut)   % if the directory is not exist
            mkdir(plotEachOut);  % make the new directory
        end
        
        plot_pred_labels_n_true_events(scoreData.predLabelBinary, ...
                        scoreData.trueLabelOriginal{1}, ...
                        scoreData.excludeIdx{1}, ...
                        plotEachOut, ...
                        [testName ', session '  sessionNumbers{testSubjID}]);
    end
end







