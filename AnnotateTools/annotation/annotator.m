%% Estimate scores of test samples using a classifer
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%
%  Do not exclude boundary (masked) samples
%
function annotData = annotator(scoreData, selfIdx, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    excludeSelf = true;     % when training data and test data are same
    if isfield(params, 'excludeSelf')
        excludeSelf = params.excludeSelf;
    end
    fHighRecall = false;    
    if isfield(params, 'fHighRecall')
        fHighRecall = params.fHighRecall;
    end
    position = 8;     
    if isfield(params, 'position')
        position = params.position;
    end
    weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5];    
    if isfield(params, 'weights')
        weights = params.weights;
    end

    trainsetNumb = length(scoreData.scoreStandard); 
    testSampleNumb = length(scoreData.trueLabelOriginal{1});
    excludeIdx = scoreData.excludeIdx{1};
    
    allScores = [];
    for trainIdx = 1:trainsetNumb
        if (excludeSelf == true) && (selfIdx == trainIdx)
            continue;
        end
        rawScore = zeros(1, testSampleNumb);
        rawScore(excludeIdx == 0) = scoreData.scoreStandard{trainIdx};

        % calculate weighted scores
        s = rescore3(rawScore, weights, position, excludeIdx);

        % Use a greedy algorithm to take best scores
        sNew = maskScores3(s, 7, fHighRecall);  % zero out 15 elements         

        % weighted score. note that it has the same length to true labels    
        scoreData.weightedScore{trainIdx} = sNew;

        cutPrecentage = 95; cutMax = 0;
        while (cutMax == 0)
            cutMax = prctile(sNew, cutPrecentage);
            cutPrecentage = cutPrecentage + 1;
        end
        sNew(sNew > cutMax) = cutMax;
        sNew = sNew ./ cutMax;
        allScores = cat(1, allScores, sNew);

        fprintf('annotate, trainSubj, %d\n', trainIdx);
    end
    theseScores = sum(allScores, 1);   % sum of sub-window scores
    if sum(isnan(theseScores)) > 0
        error('nan score');
    end
    % Make up a weighting and calculate weighted scores
    s = rescore3(theseScores, weights, position, excludeIdx);% don't exclude negative scores

    % Use a greedy algorithm to take best scores
    sNew = maskScores3(s, 7, fHighRecall);  % zero out 15 elements

    scoreData.combinedScore{1} = sNew;
    
    annotData = scoreData;
end




