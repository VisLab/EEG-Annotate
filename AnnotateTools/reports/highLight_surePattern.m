function [newMap, sureIdx] = highLight_surePattern(userMap, userRange, newValue)

    for i = 3:size(allPredLabels, 2)-2
        if sum(sum(allPredLabels(:, i-2:i+2))) >= size(allPredLabels, 1)
            labelTemp = allPredLabels(:, i-2:i+2);
            labelTemp(labelTemp == 1) = 0.75;
            allPredLabels(:, i-2:i+2) = labelTemp;
            sureCount = sureCount + 1;
        end
    end
end
