%% get cutoff to get the highest avrage accuracy
%
%  parameter:
%   trueLabels
%   scores
%   N: number of bins
%
function [bestCutoff, bestPerform] = getCutoff_BEST(trueLabels, scores, metric, N)

    cutoffs = min(scores):(max(scores)-min(scores))/(N-1):max(scores);
    
    performs = zeros(N, 1);
    
    for i=1:N
        predLabels = double(scores > cutoffs(i));
        allResults = getResults_struct(predLabels, trueLabels, []);
        performs(i) = allResults.(metric);
    end
    
    [bestPerform, maxI] = max(performs);
    bestCutoff = cutoffs(maxI);
end