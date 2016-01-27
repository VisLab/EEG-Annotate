%% annotate samples 
% 
%  - do mask scores and zero-out scores
%  - use the fixed weight vectors
%  - assume VEP training dataset ==> 18 training sets
%

% weights 
position = 8;
weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5];

classifierName = 'LDA'; % 'ARRLS'

%% path to raw scores (estimated by classifiers)
scoreIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_score\';	% path to estimated scores
annotationOut = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_annotate\';    % save results

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
            'Experiment X6 Speed Control'};

if ~isdir(annotationOut)   % if the directory is not exist
    mkdir(annotationOut);  % make the new directory
end
        
for t=1:length(testNames)
    testName = testNames{t};
    
    load([scoreIn testName '_' classifierName '.mat']);  % load results

    %     results = struct('trueLabelOriginal', [], 'excludeIdx', [], 'predLabelBinary', [], 'scoreStandard', [], 'scoreOriginal', []);
    %     results.trueLabelOriginal = cell(1, testsetNumb);
    %     results.excludeIdx = cell(1, testsetNumb);
    %     results.predLabelBinary = cell(18, testsetNumb);
    %     results.scoreStandard = cell(18, testsetNumb);
    %     results.scoreOriginal = cell(18, testsetNumb);

    %% go over all test sets and estimate scores
    testsetNumb = length(results.trueLabelOriginal);

    annotation = struct('trueLabel', [], 'excludeIdx', [], 'aScore', []);  
    % aScore: annotation score. note that it has the same length to true labels    
    
    annotation.trueLabel = cell(1, testsetNumb);
    annotation.excludeIdx = cell(1, testsetNumb);
    annotation.aScore = cell(18, testsetNumb);
    
    for testSubjID=1:testsetNumb
        annotation.trueLabel{testSubjID} = results.trueLabelOriginal{testSubjID};
        annotation.excludeIdx{testSubjID} = results.excludeIdx{testSubjID};
        
        testSampleNumb = length(annotation.trueLabel{testSubjID});
        excludeIdx = annotation.excludeIdx{testSubjID};
        for trainSubjID = 1:18
            rawScore = zeros(1, testSampleNumb);
            rawScore(excludeIdx == 0) = results.scoreStandard{trainSubjID, testSubjID};

            % calculate weighted scores
            s = rescore3(rawScore, weights, position, excludeIdx);
            
            % Use a greedy algorithm to take best scores
            sNew = maskScores2(s, 7);  % zero out 15 elements         
            
            annotation.aScore{trainSubjID, testSubjID} = sNew;
            
            fprintf('trainSubj, %d, testSubj, %d\n', trainSubjID, testSubjID);
        end
    end
    save([annotationOut filesep testName '_annotation_each.mat'], 'annotation', '-v7.3');
end
