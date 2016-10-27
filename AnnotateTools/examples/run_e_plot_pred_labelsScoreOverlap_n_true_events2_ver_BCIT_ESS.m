%% plot the locations of predicted events and true events
% assume that all classifiers detect the same number of samples
% force all pred positive numbers are same
%

clear; close all;

%% path to raw scores (estimated by classifiers)
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 4\annotate\BCIT\BE_256Hz_II_MARA';	% to get the list of test files
scoreIn = 'Z:\Data 4\annotate\BCIT\BE_256Hz_II_MARA_fA_sAi_35_1_6_110_6';    % annotated samples
plotOut = 'Z:\Data 4\annotate\BCIT\BE_256Hz_II_MARA_fA_sAi_35_1_6_110_6_results';    

% testNames = {'X3 Baseline Guard Duty'; ...
%             'X4 Advanced Guard Duty'; ...
%             'Experiment X2 Traffic Complexity'; ...
%             'Experiment X6 Speed Control'; ...
%             'Experiment XB Baseline Driving'; 
%             'Experiment XC Calibration Driving'; ...
%             'X1 Baseline RSVP'; ...
%             'X2 RSVP Expertise'};
testNames = {'EXC'};

for t=1:length(testNames)
    testName = testNames{t};
    
    fileListDir = [fileListIn filesep testName]; 

    % Create a level 2 derevied study
    %  To get the list of file names
    derivedXMLFile = [fileListDir filesep level2DerivedFile];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
    [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);
    
    % go over all files and apply a feature extraction function
    for testSubjID=1:length(filenames) %length(filenames)
        [path, name, ext] = fileparts(filenames{testSubjID});
        scoreDir = [scoreIn filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
        scoreData = []; % init scoreData
        load([scoreDir filesep name '.mat']);  % load scoreData

        plotEachOut = [plotOut filesep 'plot_pred_labelsScoreOverlap_n_true_events2' filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
        if ~isdir(plotEachOut)   % if the directory is not exist
            mkdir(plotEachOut);  % make the new directory
        end

        detectCount = zeros(length(scoreData.predLabelBinary), 1);
        for i=1:length(scoreData.predLabelBinary)
            detectCount(i) = sum(scoreData.predLabelBinary{i});
        end
        medianCount = round(median(detectCount));
        % update predLabelBinary
        for i=1:length(scoreData.predLabelBinary)
            scoreTemp = scoreData.scoreStandard{i};
            [~, sIdx] = sort(scoreTemp, 'descend');
            newLabel = zeros(length(scoreData.predLabelBinary{i}), 1);
            newLabel(sIdx(1:medianCount)) = 1;
            scoreData.predLabelBinary{i} = newLabel;
        end

        sureCount = plot_pred_labelsScoreOverlap_n_true_events_marking(scoreData.predLabelBinary, ...
                        scoreData.weightedScore, ...
                        scoreData.trueLabelOriginal{1}, ...
                        scoreData.excludeIdx{1}, ...
                        plotEachOut, ...
                        [testName ', session '  sessionNumbers{testSubjID}]);
        fprintf('session %s, sure %d\n', sessionNumbers{testSubjID}, sureCount);
    end
end







