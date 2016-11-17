%% measure the mean average precision (MAP) for the retrieval system
% 
function AP = evaluate_AP(trueLabel, score, error)
    % error: ditance range 0 ~ 7, 8 means the fail of retrieval
    
    trueNumb = sum(trueLabel);
    [~, si] = sort(score, 'descend');

    Ps = zeros(trueNumb, 1);        % precisions
    hitNumb = 0;
    for i=1:length(si)
        idx = si(i);

        iBegin = idx-error;
        iEnd = idx+error;
        iBegin = max(iBegin, 1);
        iEnd = min(length(si), iEnd);
        if sum(trueLabel(iBegin:iEnd)) > 0
            hitNumb = hitNumb + 1;
            Ps(hitNumb) = hitNumb / i;
        end
        if hitNumb == trueNumb
            break;
        end
    end
    AP = mean(Ps);
end

