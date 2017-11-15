function outName = reportComparison(inPath1, inPath2, outName, tolerance)
%% Generate confusion matrix treating inPath1 as ground truth
%
%  Parameters:
%       inPath1:        base path to the annotation scores for ground truth
%       inPath2:        base path for comparison annotation scores
%       outName:        file name for saving the structure
%       tolerance       timing tolerance for this analysis
%
% This report generator calculates the relative confusion matrix for two
% annotations -- inPath1 is treated as ground truth. This function assumes
% that the two annotations follow the same naming convention and are just
% in different directories.
%
% TP = annotation 2 indicates label within timing tolerance of annotation 1
% FP = annotation 2 indicates label but no label from annotation 1
% FN = annotation 1 indicates label but no label from annotation 2
% TN = totalsamples - number of positives from annotation 1
%
%
% Written by: Kay Robbins, UTSA
%

%% Extract all .mat files in the specified directory (should contain annotData)
fileList1 = dir([inPath1 filesep '*.mat']);
numTests = length(fileList1);

%% Define a structure to hold the data
compareStruct(numTests) = struct('fileName1', NaN, 'fileName2', NaN, ...
              'timingTolerance', NaN,  'totalSamples', NaN, ...
              'positives1', NaN, 'positives2', NaN, ...
              'TP', NaN, 'FP', NaN, 'FN', NaN);
          
for k = 1:numTests
    %% Set up the file names to read
    testFile1 = [inPath1 filesep fileList1(k).name];
    testFile2 = [inPath2 filesep fileList1(k).name];
    compareStruct(k).fileName1 = testFile1;
    compareStruct(k).fileName2 = testFile2;
    compareStruct(k).timingTolerance = tolerance;
    
    %% Read the annotation files
    test1 = load(testFile1); % load annotData
    if ~isfield(test1, 'annotData') || isempty(test1.annotData)
        warning('%s: has no annotData\n', testFile1);
        continue;
    end
    
    test2 = load(testFile2); % load annotData
    if ~isfield(test2, 'annotData') || isempty(test2.annotData)
        warning('%s: has no annotData\n', testFile2);
        continue;
    end
    %% Extract the annotations
    wmScores1 = test1.annotData.wmScores;
    classIndex1 = 1:length(wmScores1);
    classIndex1 = classIndex1(wmScores1 >= test1.annotData.combinedCutoff)';
    wmScores2 = test2.annotData.wmScores;
    classIndex2 = 1:length(wmScores2);
    classIndex2 = classIndex2(wmScores2 >= test2.annotData.combinedCutoff)';
    if length(wmScores1) ~= length(wmScores2)
        error('%s and %s do not have same number of samples', ...
            annotData1.testFileName, annotData2.testFileName);
    end
    compareStruct(k).positives1 = length(classIndex1);
    compareStruct(k).positives2 = length(classIndex2);
    %% Get the distances between the annotations
    compareStruct(k).totalSamples = length(wmScores1);
    targetDist1 = getSampleTiming(classIndex1, classIndex2);
    targetDist2 = getSampleTiming(classIndex2, classIndex1);
    compareStruct(k).TP = sum(abs(targetDist1) <= tolerance);
    compareStruct(k).FP = sum(abs(targetDist2) > tolerance);
    compareStruct(k).FN = sum(abs(targetDist1) > tolerance);
end

%% Save the results
save(outName, 'compareStruct', '-v7.3');
