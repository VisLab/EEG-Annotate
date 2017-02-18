%% measure the recall 
% 
function recall = evaluate_recall(trueLabel, score, error, retrieveNumb)
    % error: ditance range 0 ~ 7, 8 means the fail of retrieval
    
    if retrieveNumb > length(trueLabel)
        retrieveNumb = length(trueLabel);
        warning('too large retrieveNumb');
    end
    [~, si] = sort(score, 'descend');
    predLabel = zeros(length(trueLabel), 1);
    predLabel(si(1:retrieveNumb)) = 1;

    targetIdx = find(trueLabel);
    N = length(targetIdx); % number of target samples
    numbHits = 0;

    for i=1:N
        idx = targetIdx(i);
        iBegin = idx-error;
        iEnd = idx+error;
        iBegin = max(iBegin, 1);
        iEnd = min(length(predLabel), iEnd);
        if sum(predLabel(iBegin:iEnd)) > 0
            numbHits = numbHits + 1;
        end
    end
    recall = numbHits / sum(trueLabel);
end

