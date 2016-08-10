%% print results using many metrics
%
%  parameters
%  -predLabel : predicted labels
%  -trueLabel : true labels
%  -resultTitle: prefix of output strings
%
function results = getResults_struct(predLabel, trueLabel, resultTitle)

    results = struct('TP', [], 'FN', [], 'FP', [], 'TN', [], 'accuracy', [], 'precision', [], 'recall', [], 'f1score', [], 'gmean', [], 'N_predN', [], 'N_predP', [], 'avrAcc', []); 

    %  true classes : class labels (negative, positive)
    classes = unique(trueLabel, 'sorted');
    predC = unique(predLabel, 'sorted');
    if predC(1) ~= classes(1) && predC(1) ~= classes(2)
        error('class labels are not matched');
    end
    if length(predC) == 2 && predC(2) ~= classes(2)
        error('class labels are not matched');
    end

    idx_predN  = (predLabel == classes(1));
    idx_predP  = (predLabel == classes(2));

    TP = sum(trueLabel(idx_predP) == classes(2));
    FN = sum(trueLabel == classes(2)) - TP;
    TN = sum(trueLabel(idx_predN) == classes(1));
    FP = sum(trueLabel == classes(1)) - TN;

    accuracy = (TP + TN) / (TP + FN + FP + TN);
    precision = TP / (TP + FP);
    recall = TP / (TP + FN);
    f1score = (2 * recall * precision) / (precision + recall);
    gmean = sqrt(precision * recall);
    avrAcc = ((TN / (TN + FP)) + (TP / (TP + FN)))/2;

    if ~isempty(resultTitle)
        fprintf('%s, TP, %d, FN, %d, FP, %d, TN, %d, Accuracy, %f, Precision, %f, Recall, %f, F1score, %f, Gmean, %f, avrAcc, %f\n', ...
            resultTitle, TP, FN, FP, TN, accuracy, precision, recall, f1score, gmean, avrAcc);
    end
    
    results.TP = TP;
    results.FN = FN;
    results.FP = FP;
    results.TN = TN;
    results.accuracy = accuracy;
    results.precision = precision;
    results.recall = recall;
    results.f1score = f1score;
    results.gmean = gmean;
    results.N_predN = sum(idx_predN);
    results.N_predP = sum(idx_predP);
    results.avrAcc = avrAcc;
end
