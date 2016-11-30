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
    adaptiveCutoff = false;   % default: fixed cutoff 0.0 
    if isfield(params, 'adaptiveCutoff')
        adaptiveCutoff = params.adaptiveCutoff;
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

        % calculate weighted sub-windows scores
        wScore = getWeightedScore(rawScore, weights, position);

        if adaptiveCutoff == true
            cutoff = getCutoff_FL(wScore);
        else
            cutoff = 0.0;
        end
                
        % Use a greedy algorithm to take best scores
        mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements         

        scoreData.wmScore{trainIdx} = mScore; % weighted and mask-out score
    end
    
    allScores = [];
    for trainIdx = 1:trainsetNumb
        if (excludeSelf == true) && (selfIdx == trainIdx)
            continue;
        end
        
        wmScore = scoreData.wmScore{trainIdx};

        if rescaleBeforeCombining == true
            % How to scale scores?
            % 1) 2)
%             cutPrecentage = 95; cutMax = 0;
%             while (cutMax == 0)
%                 cutMax = prctile(wmScore, cutPrecentage);
%                 cutPrecentage = cutPrecentage + 1;
%             end

            % 3) 4)
%             cutPrecentage = 95; cutMax = 0;
%             nonZeroScore = wmScore(wmScore > 0);
%             while (cutMax == 0)
%                 cutMax = prctile(nonZeroScore, cutPrecentage);
%                 cutPrecentage = cutPrecentage + 1;
%             end
            
            % 5-8)
            nonZeroScore = wmScore(wmScore > 0);
            cutMax = mean(nonZeroScore); % - (1 * std(nonZeroScore));
          
            wmScore(wmScore > cutMax) = cutMax;
            wmScore = wmScore ./ cutMax;

            % 9)
%             wmScore(wmScore > 0) = 1;
            
        end
        allScores = cat(2, allScores, wmScore);
    end
    scoreData.allScores = allScores;
    
    theseScores = mean(allScores, 2);   % sum of sub-window scores
    if sum(isnan(theseScores)) > 0
        error('nan score');
    end
    % Make up a weighting and calculate weighted scores
    wScore = getWeightedScore(theseScores, weights, position);% don't exclude negative scores

    if adaptiveCutoff == true
        cutoff = getCutoff_FL(wScore);
    else
        cutoff = 0.5;
    end
    
    % Use a greedy algorithm to take best scores
    mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements         

    scoreData.combinedScore = mScore;
    
    annotData = scoreData;
end




