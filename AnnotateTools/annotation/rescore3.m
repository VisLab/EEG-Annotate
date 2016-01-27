%% rescore version3
% 
% revision
%   - rule out excluded samples from weighting. (Jan. 27, 2016)
%
function s = rescore3(scores, weights, position, excludeIdx)

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
        
        excludeMask = excludeIdx(realStart:realEnd); % the index of excluded samples
        wScore = wScore(excludeMask==0);
        weightMask = weightMask(excludeMask==0);
        
        score = sum(wScore.* weightMask);
    end
end


