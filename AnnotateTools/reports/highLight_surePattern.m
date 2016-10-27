function [newMap, sureIdx, counts] = highLight_surePattern(userMap, userRange, thresRatio, newValue)

    newMap = userMap;
    thresCount = round(size(userMap, 1) * thresRatio);
    sureIdx = zeros(size(userMap, 2), 1);
	counts = zeros(size(userMap, 2), 1);
    for i = userRange+1:size(userMap, 2)-userRange
        curRange = i-userRange:i+userRange;
		hitCount = sum(sum(userMap(:, curRange)));
		counts(i) = hitCount;
        if hitCount >= thresCount
            labelTemp = userMap(:, curRange);
            labelTemp(labelTemp == 1) = newValue;
            newMap(:, curRange) = labelTemp;
            sureIdx(i) = 1;
        end
    end
end
