%% rescore version3
% 
function s = getWeightedScores(scores, weights)

    if mod(length(weights), 2) ~= 1
        error('Weights vector must have an odd number of elements');
    end
    position = floor(length(weights)/2) + 1;
    s = zeros(size(scores));
    for k = 1:length(scores)
        s(k) = getScore(k);
    end

    function score = getScore(current)
        startPos = current - position + 1;
        endPos = current + length(weights) - position;
        realStart = max(1, startPos);
        realEnd = min(length(scores), endPos);
        wScore = scores(realStart:realEnd);
        
        %wScore = wScore(:)';
        weightStart = max(1, realStart - startPos + 1);
        weightEnd = weightStart + realEnd - realStart;
        weightMask = weights(weightStart:weightEnd);
        
        score = weightMask * wScore;
    end
end


