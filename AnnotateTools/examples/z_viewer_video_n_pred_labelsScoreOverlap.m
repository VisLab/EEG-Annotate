%% viewer to view avi video with the events
%

clear; close all;

%% path to video and scores
videoFiles = {'Z:\Data 4\annotate\BCIT_Video\', 'XB', 'BCIT.T2.M10.S2003.XB.CC.R3_2013125_124939_2013125_124939.avi'; 
              'Z:\Data 4\annotate\BCIT_Video\', 'XB', 'BCIT.T2.M26.S2009.XB.CC.R2_201389_152023_201389_152023.avi';
              'Z:\Data 4\annotate\BCIT_Video\', 'XB', 'BCIT.T2.M29.S2010.XB.CD.R2_2013812_16248_2013812_16248.avi';
              'Z:\Data 4\annotate\BCIT_Video\', 'XB', 'BCIT.T2.M81.S2027.XB.CA.R3_2013923_15252_2013923_15252.avi';
              'Z:\Data 4\annotate\BCIT_Video\', 'XC', 'BCIT.T2.M64.S2022.XC.C.R1_2013911_144946_2013911_144946.avi';
              'Z:\Data 4\annotate\BCIT_Video\', 'XC', 'BCIT.T2.M70.S2024.XC.C.R1_2013917_14153_2013917_14153.avi';
              'Z:\Data 4\annotate\BCIT_Video\', 'XC', 'BCIT.T2.M82.S2028.XC.C.R1_2013924_14631_2013924_14631.avi';
              'Z:\Data 4\annotate\BCIT_Video\', 'XC', 'BCIT.T2.M108.S2037.XC.C.R1_201486_91225_201486_91225.avi';
              'Z:\Data 4\annotate\BCIT_Video\', 'XC', 'BCIT.T2.M133.S2045.XC.C.R1_2014108_10322_2014108_10322.avi';
              'Z:\Data 4\annotate\BCIT_Video\', 'XC', 'BCIT.T2.M157.S2052.XC.C.R1_20141023_145948_20141023_145948.avi';
              'Z:\Data 4\annotate\BCIT_Video\', 'XC', 'BCIT.T2.M166.S2055.XC.C.R1_20141030_91120_20141030_91120.avi'};
scoreFiles = {'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XB Baseline Driving\session\', '10'; 
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XB Baseline Driving\session\', '15';
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XB Baseline Driving\session\', '16';
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XB Baseline Driving\session\', '31';
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XC Calibration Driving\session\', '38';
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XC Calibration Driving\session\', '40';
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XC Calibration Driving\session\', '44';
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XC Calibration Driving\session\', '53';
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XC Calibration Driving\session\', '60';
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XC Calibration Driving\session\', '67';
              'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreARTLimb\Experiment XC Calibration Driving\session\', '70'};          

%% path to raw scores (estimated by classifiers)
for f = 1:size(videoFiles, 1)
    
    scoreDir = [scoreFiles{f, 1} scoreFiles{f, 2}];
    fileList = dir([scoreDir filesep '*.mat']);
    
    if length(fileList) ~= 1
        warning(['Check data file in ' scoreDir]);
        continue
    end
    
    scoreData = []; % init scoreData
    load([scoreDir filesep fileList(1).name]);  % load scoreData

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

    predMap = get_pred_labelsScoreOverlap(scoreData.predLabelBinary, scoreData.weightedScore, scoreData.excludeIdx{1});
    [~, sureIdx] = highLight_surePattern(predMap, 2, 0.75);
    
    fprintf('%s, sure %d\n', fileList(1).name, sum(sureIdx));
end

% 
% for t=1:length(testNames)
%     testName = testNames{t};
%     
%     fileListDir = [fileListIn filesep testName]; 
% 
%     % Create a level 2 derevied study
%     %  To get the list of file names
%     derivedXMLFile = [fileListDir filesep level2DerivedFile];
%     obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
%     [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);
%     
%     % go over all files and apply a feature extraction function
%     for testSubjID=1:length(filenames) %length(filenames)
%         [path, name, ext] = fileparts(filenames{testSubjID});
%         scoreDir = [scoreIn filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
%         scoreData = []; % init scoreData
%         load([scoreDir filesep name '.mat']);  % load scoreData
% 
%         plotEachOut = [plotOut filesep 'plot_pred_labelsScoreOverlap_n_true_events2' filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
%         if ~isdir(plotEachOut)   % if the directory is not exist
%             mkdir(plotEachOut);  % make the new directory
%         end
% 
%         detectCount = zeros(length(scoreData.predLabelBinary), 1);
%         for i=1:length(scoreData.predLabelBinary)
%             detectCount(i) = sum(scoreData.predLabelBinary{i});
%         end
%         medianCount = round(median(detectCount));
%         % update predLabelBinary
%         for i=1:length(scoreData.predLabelBinary)
%             scoreTemp = scoreData.scoreStandard{i};
%             [~, sIdx] = sort(scoreTemp, 'descend');
%             newLabel = zeros(length(scoreData.predLabelBinary{i}), 1);
%             newLabel(sIdx(1:medianCount)) = 1;
%             scoreData.predLabelBinary{i} = newLabel;
%         end
% 
%         sureCount = plot_pred_labelsScoreOverlap_n_true_events_marking(scoreData.predLabelBinary, ...
%                         scoreData.weightedScore, ...
%                         scoreData.trueLabelOriginal{1}, ...
%                         scoreData.excludeIdx{1}, ...
%                         plotEachOut, ...
%                         [testName ', session '  sessionNumbers{testSubjID}]);
%         fprintf('session %s, sure %d\n', sessionNumbers{testSubjID}, sureCount);
%     end
% end







