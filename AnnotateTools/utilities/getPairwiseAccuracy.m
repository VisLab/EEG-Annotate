function [pairwiseAccuracy, selfAccuracy] = getPairwiseAccuracy(fileList, targetClass)
%% Calculate pairwise balanced accuracy
%
%  Parameters:
%     inPath       directory of files containing scoreData structures
%     targetClass  label of class to analyze
%     accuracy     (output) array with pairwise balance accuracies
%                    k-th row contains predictions of k-th file
%                    a -1 indicates it is the same file.
%
% Written by: Kyung-min Su, Kay Robbins, UTSA, 2016-2017

%% Calculate the accuracies for the specified directory
    numFiles = length(fileList);    
    pairwiseAccuracy = -ones(numFiles, numFiles);
    selfAccuracy = zeros(numFiles, 1);
    for k = 1:numFiles
        [~, testName, ~] = fileparts(fileList{k});
        thisTest = load(fileList{k});
        trueLabels = thisTest.scoreData(k).trueLabels;
        trueLabelMask = getClassMask(trueLabels, targetClass);
 
        for n = 1:numFiles
            [~, trainName, ~] = fileparts(fileList{n});
            if strcmpi(testName, trainName)
                continue;
            end
            predLabelMask = thisTest.scoreData(n).finalScores >= ...
                            thisTest.scoreData(n).finalCutoff;
            TP = sum(predLabelMask & trueLabelMask);
            FN = sum(~predLabelMask & trueLabelMask);
            TN = sum(~predLabelMask & ~trueLabelMask);
            FP = sum(predLabelMask & ~trueLabelMask);
            accuracy = 0.5 * (TP/(TP+FN) + TN/(TN+FP));
            if strcmpi(testName, trainName)
                selfAccuracy = accuracy;
            else
                pairwiseAccuracy(k, n) = accuracy;
            end
        end
    end
end