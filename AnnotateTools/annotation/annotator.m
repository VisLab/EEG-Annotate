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
    adaptiveCutoff1 = false;   % default: fixed cutoff 0.0 
    if isfield(params, 'adaptiveCutoff1')
        adaptiveCutoff1 = params.adaptiveCutoff1;
    end
    adaptiveCutoff2 = false;   % default: fixed cutoff 0.0 
    if isfield(params, 'adaptiveCutoff2')
        adaptiveCutoff2 = params.adaptiveCutoff2;
    end
    rescaleBeforeCombining = true;  
    if isfield(params, 'rescaleBeforeCombining')
        rescaleBeforeCombining = params.rescaleBeforeCombining;
    end
    position = 8;     
    if isfield(params, 'position')
        position = params.position;
    end
    weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5];    
    if isfield(params, 'weights')
        weights = params.weights;
    end

    trainsetNumb = length(scoreData.testFinalScore); 
    
    for trainIdx = 1:trainsetNumb
        if (excludeSelf == true) && (selfIdx == trainIdx)
            continue;
        end
        rawScore = scoreData.testFinalScore{trainIdx};

        if adaptiveCutoff1 == true
            cutoff = getCutoff_FL(rawScore, 30, 0.0);   % adaptive cutoff
        else
            cutoff = 0.0;
        end
        
        shiftedScore = rawScore - cutoff;       % now the score has zero cutoff

        noNegativeShiftedScore = shiftedScore;
        noNegativeShiftedScore(shiftedScore < 0) = 0;   % remove everything below zero

        if rescaleBeforeCombining == true
            nonZeroScore = noNegativeShiftedScore(noNegativeShiftedScore > 0);
            cutMax = prctile(nonZeroScore, 98);             % use percentile to scaling

            normalizedScore = noNegativeShiftedScore;
            normalizedScore(normalizedScore > cutMax) = cutMax;
            normalizedScore = normalizedScore ./ cutMax;              % score range is 0 to 1.
        else 
            normalizedScore = noNegativeShiftedScore;
        end
        
        wScore = getWeightedScore(normalizedScore, weights, position); % calculate weighted sub-windows scores

        cutoff = 0;

        mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements         

        scoreData.wmScore{trainIdx} = mScore; % weighted and mask-out score
    end
    
    allScores = [];
    for trainIdx = 1:trainsetNumb
        if (excludeSelf == true) && (selfIdx == trainIdx)
            continue;
        end
        
        wmScore = scoreData.wmScore{trainIdx};

        allScores = cat(2, allScores, wmScore);
    end
    scoreData.allScores = allScores;
    
    theseScores = mean(allScores, 2);   % average of sub-window scores
    if sum(isnan(theseScores)) > 0
        error('nan score');
    end
    % Make up a weighting and calculate weighted scores
    wScore = getWeightedScore(theseScores, weights, position);% don't exclude negative scores

    cutoff = 0.0; 
    
    % Use a greedy algorithm to take best scores
    mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements         

    scoreData.combinedScore = mScore;
    
    if adaptiveCutoff2 == true
        cutoff = getCutoff_FL(mScore(mScore > 0), 30, 0.0);     % cutoff estiamted from non-zero scores
    else
        cutoff = 0.0;
    end

    scoreData.combinedCutoff = cutoff;
    
    annotData = scoreData;
end




