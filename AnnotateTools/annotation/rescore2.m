% When it processes the boundary, the the length of wScore is reduced because the out-boundary doesn't have valid scores.
% In that case, the weight should be also selected in the same way to keep the consistency between the score and the weight.
% That is the variable weightMask.
% In the old script uses the original weight vector, but it shold use the weightMask vector.
% - Kyung
% 
% rescore2: doesn't exclude negative scores.
function s = rescore2(scores, weights, position)

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
        score = sum(wScore.* weightMask);
    end
end


