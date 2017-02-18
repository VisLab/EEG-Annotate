function annotData = annotate(scoreData, classLabel, params)
%% Estimate annotation score from individual classifier scores
%
%  Parameters:
%      scoreData    structure containing scores from individual classifiers
%      classLabel   string containing class label
%      params       structure containing parameters
%  
%  Parameters relevant to this are:
%     AnnotateWeights
%     AnnotateUseAdapativeShift 
%     AnnotateUseAdaptiveCombine
%
%  Written by: Kyung Mu Su and Kay Robbins 2016-2017, UTSA
%
%% Set the parameters and reporting for the call   
    params = processAnnotateParameters('annotate', nargin, 2, params);
    position = floor(length(params.AnnotateWeights)/2) + 1;
     
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

        if params.AnnotateRescaleBeforeCombine
            nonZeroScore = noNegativeShiftedScores(noNegativeShiftedScores > 0);
            cutMax = prctile(nonZeroScore, 98);     % use percentile to scaling
            normalizedScores = noNegativeShiftedScores;
            normalizedScores(normalizedScores > cutMax) = cutMax;
            normalizedScores = normalizedScores ./ cutMax;  % score range is 0 to 1.
        else 
            normalizedScores = noNegativeShiftedScores;
        end
        %% Calculate sub-window scores and zero-out
        wScores = getWeightedScores(normalizedScores, params.AnnotateWeights); 
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
    wScores = getWeightedScores(theseScores, params.AnnotateWeights);
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