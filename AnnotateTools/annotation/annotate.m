function annotData = annotate(scoreData, classLabel, params)
%% Estimate annotation score from individual classifier scores
%
%  Parameters:
%      scoreData    structure containing scores from individual classifiers
%      classLabel   string containing class label
%      
%  Name-value pair parameters:
%
%                    'adaptiveCutoff1', true, ...
%                    'adaptiveCutoff2', true, ...
%                    'rescaleBeforeCombining', true, ...
%                    
%     'weights'     window filter vector with odd number of elements 
%                   default: [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]
%% Set the parameters and reporting for the call   
    params = processAnnotateParameters('annotate', nargin, 2, params);
%     params = vargin2struct(varargin);  
%     adaptiveCutoff1 = true;  
%     if isfield(params, 'adaptiveCutoff1')
%         adaptiveCutoff1 = params.adaptiveCutoff1;
%     else
%         params.adaptiveCutoff1 = adaptiveCutoff1;
%     end
%     adaptiveCutoff2 = true;   
%     if isfield(params, 'adaptiveCutoff2')
%         adaptiveCutoff2 = params.adaptiveCutoff2;
%     else
%         params.adaptiveCutoff2 = adaptiveCutoff2;
%     end
%     rescaleBeforeCombining = true;  
%     if isfield(params, 'rescaleBeforeCombining')
%         rescaleBeforeCombining = params.rescaleBeforeCombining;
%     else
%         params.rescaleBeforeCombining = rescaleBeforeCombining;
%     end

%     weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5];    
%     if isfield(params, 'weights')
%         weights = params.weights;
%     else
%         params.weights = weights;
%     end
    position = floor(length(params.weights)/2) + 1;
     
    %% Initialize the annotation structure
    annotData = getAnnotDataStructure();
    annotData.params = params;
    annotData.classLabel = classLabel;
    annotData.testFileName = scoreData(1).testFileName;
    annotData.trueLabels = scoreData(1).trueLabels;
    numTestSamples = length(scoreData(1).trueLabels);               
    numTrain = length(scoreData); 
    
    allScores = nan(numTestSamples, numTrain);
    trainFileNames = cell(numTrain, 1);
    initialCutoffs = zeros(numTrain, 1);
    for k = 1:numTrain
        trainFileNames{k} = scoreData(k).trainFileName;
        rawScores = scoreData(k).finalScores;
        if params.AnnotateUseAdapativeShift
            cutoff = getCutoffFL(rawScores, 30, 0.0);   % adaptive cutoff
        else
            cutoff = 0.0;
        end 
        initialCutoffs(k) = cutoff;
        shiftedScores = rawScores - cutoff;       % now score has zero cutoff
        noNegativeShiftedScores = shiftedScores;
        noNegativeShiftedScores(shiftedScores < 0) = 0;   % remove everything below zero

        if paramsAnnotateRescaleBeforeCombine
            nonZeroScore = noNegativeShiftedScores(noNegativeShiftedScores > 0);
            cutMax = prctile(nonZeroScore, 98);     % use percentile to scaling
            normalizedScores = noNegativeShiftedScores;
            normalizedScores(normalizedScores > cutMax) = cutMax;
            normalizedScores = normalizedScores ./ cutMax;  % score range is 0 to 1.
        else 
            normalizedScores = noNegativeShiftedScores;
        end
        %% Calculate sub-window scores and zero-out
        wScores = getWeightedScores(normalizedScores, weights); 
        mScores = getMaskOutScores(wScores, position - 1, 0);   
        allScores(:, k) = mScores;
    end    
    annotData.trainFileNames = trainFileNames;
    annotData.initialCutoffs = initialCutoffs;    
    theseScores = mean(allScores, 2);   % average of sub-window scores
    if sum(isnan(theseScores)) > 0
        error('nan score');
    end
    
    %% Make up a weighting and calculate weighted scores
    wScores = getWeightedScores(theseScores, weights);
    annotData.wScores = wScores;
    
    %% Use a greedy zero-out algorithm to take best scores
    wmScores = getMaskOutScores(wScores, position - 1, 0);         
    annotData.wmScores = wmScores; 
    if params.AnnotateUseAdaptiveCombine
        cutoff = getCutoffFL(wmScores(wmScores > 0), 30, 0.0);     % cutoff estiamted from non-zero scores
    else
        cutoff = 0.0;
    end
    annotData.combinedCutoff = cutoff;
end




