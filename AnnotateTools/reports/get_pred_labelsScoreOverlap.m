function predMap = get_pred_labelsScoreOverlap(predLabels, predScores, excludeIdx)

    predMap = zeros(length(predLabels), length(predScores{1}));
    for i=1:length(predLabels)
        pred_temp1 = zeros(1, length(predScores{1}));
        pred_temp1(excludeIdx==0) = predLabels{i};
        pred_temp2 = (predScores{i} > 0);
        predMap(i, :) = (pred_temp1 & pred_temp2);
    end
end