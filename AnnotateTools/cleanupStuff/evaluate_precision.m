%% measure the precision in top N score samples 
% 
function precision = evaluate_precision(trueLabel, score, error, plotLimit)

    hitCount = hitCountInSorted(trueLabel, score, error);
    
    hitCount = hitCount(1:plotLimit);
    hits = hitCount > 0;
    hitCum = cumsum(hits);
    retrieveCum = 1:plotLimit;
    precision = hitCum ./ retrieveCum';
end

% Because the test samples are non-time-locked, they are slightly misaligned from the true event timing. 
% The classification label based metrics such as precision and recall are strict to the exact timing of event.
% That is, the prediction is counted as a fail if it is off from the true timing no matter how close to the true timing. 
% In this script, the new evaluation methods (say, easy precision and recall) that count the prediction as a hit if it is within the window area of the true timing.
function hitCount = hitCountInSorted(trueLabel, scores, inspectWindow)

    [~, sIdx] = sort(scores, 'descend');
    
    N = length(sIdx);
    hitCount = zeros(N, 1);
    
    for h=1:N
        startPos = sIdx(h) - inspectWindow;
        endPos = sIdx(h) + inspectWindow;
        realStart = max(1, startPos);
        realEnd = min(N, endPos);
        
        hitCount(h) = sum(trueLabel(realStart:realEnd));    % 0 mean false negative, it could be more than on
    end
end