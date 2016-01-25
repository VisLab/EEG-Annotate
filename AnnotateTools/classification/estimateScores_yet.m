function [scores, predLabels] = estimateScores(testSample, trainPath, trainName, targetClass, options)

    scores = cell(length(trainName), 1);
    predLabels = cell(length(trainName), 1);

    rng('default');               % random seed for reproducing the same results

    for trainID = 1:length(trainName)
        fileName = trainName{trainID};
        [trainSamplePool, trainLabelPool] = getTrainingData2(trainPath, fileName, targetClass);

        % balance training samples 
        [trainSample, trainLabel] = balanceOverMinor(trainSamplePool, trainLabelPool);

        tempLabel = zeros(size(testSample, 2), 1);

        % ARRLS calculates scores for each labels. If there are five labels, it will calculates 5 scores.
        % So make sure that there are only two labels in [trainLabel testLabel]
        [~,predLabelOriginal,~,scoreOriginal] = ARRLSkyung(double(trainSample),double(testSample),trainLabel,tempLabel,options);

        predLabels{trainID} = predLabelOriginal - 1;  % originalLabel is 1 or 2 ==> convert them to 0 or 1
        % ARRLS retuns two scores for each class.
        % convert scores to the standard format 
        scores{trainID} = zscore(scoreOriginal(:, 2) - scoreOriginal(:, 1));   % score: target score - non-target score

        fprintf('ARRLS trainSubj, %d, done\n', trainID);
    end
end
