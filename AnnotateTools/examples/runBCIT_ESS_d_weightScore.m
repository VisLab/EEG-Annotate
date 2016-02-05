%% add weighting and zero-out scores to score data structure
% 
%  - do mask scores and zero-out scores
%  - use the fixed weight vectors
%  - assume VEP training dataset ==> 18 training sets
%

% weights 
position = 8;
weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5];

%% path to raw scores (estimated by classifiers)
scorePath = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR_featureA_scoreL\';	% path to estimated scores

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
    
    load([scorePath testName '.mat']);  % load scoreData

    % go over all test sets and estimate scores
    testsetNumb = length(scoreData.trueLabelOriginal);
    trainsetNumb = size(scoreData.scoreStandard, 1);
    
    for testSubjID=1:testsetNumb
        testSampleNumb = length(scoreData.trueLabelOriginal{testSubjID});
        excludeIdx = scoreData.excludeIdx{testSubjID};
        
        for trainSubjID = 1:trainsetNumb
            rawScore = zeros(1, testSampleNumb);
            rawScore(excludeIdx == 0) = scoreData.scoreStandard{trainSubjID, testSubjID};

            % calculate weighted scores
            s = rescore3(rawScore, weights, position, excludeIdx);
            
            % Use a greedy algorithm to take best scores
            sNew = maskScores2(s, 7);  % zero out 15 elements         
            
            % weighted score. note that it has the same length to true labels    
            scoreData.weightedScore{trainSubjID, testSubjID} = sNew;
            
            fprintf('trainSubj, %d, testSubj, %d\n', trainSubjID, testSubjID);
        end
    end
    save([scorePath filesep testName '.mat'], 'scoreData', '-v7.3');
end
