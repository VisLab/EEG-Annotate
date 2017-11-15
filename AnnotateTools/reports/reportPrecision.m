function outPath = reportPrecision(inPath, outPath, targetClasses, ...
                                   targetNum, params)
%% Generate reports using the precision metric for targetNum and for all
%
%  Parameters:
%       inPath:         base path to the annotation scores
%       outPath:        base directory for saving reports
%       targetClasses:  cell array with all of the relevant target names
%       targetNum       position in targetClasses of desired target class
%       params          parameters use (reportTimingTolerances)
%
% This report generator calculates precision for different timing tolerances
%
% Written by: Kay Robbins, UTSA
%
%% Set up the defaults and process the input arguments
params = processAnnotateParameters('reportPrecision', nargin, 4, params);
tolerances = params.reportTimingTolerances;

%% Make sure that the outPath exists, if not make the directory
if ~exist(outPath, 'dir')
    mkdir(outPath);
end

%% Extract all .mat files in the specified directory (should contain annotData)
fileList = dir([inPath filesep '*.mat']);

%% Initialize the variables to save the results
numTests = length(fileList);
numTolerances = length(tolerances);
totalPositives = zeros(numTests, 1);
totalPositivesAll  = zeros(numTests, 1);
totalRetrieved = zeros(numTests, 1);
totalRetrievedAll= zeros(numTests, 1);
precision = zeros(numTests, numTolerances);
precisionAll = zeros(numTests, numTolerances);
recall =  zeros(numTests, numTolerances);
recallAll = zeros(numTests, numTolerances);
averagePrecision = zeros(numTests, numTolerances);
averagePrecisionAll = zeros(numTests, numTolerances);
labels = cell(numTests, 1);
scores = cell(numTests, 1);
sampleMask = cell(numTests, 1);

%% Compute the performance
for k = 1:numTests
    annotData = [];
    testFile = [inPath filesep fileList(k).name];
    load(testFile); % load annotData
    if isempty(annotData)
        warning('%s: has no annotData\n', testFile);
        continue;
    end
    labels{k} = annotData.trueLabels;
    scores{k} = annotData.wmScores;
    sampleMask{k} = annotData.wmScores >= annotData.combinedCutoff;
 
    %% Calculate performance for the targetNum class
    [totalPositives(k), totalRetrieved(k), precision(k, :), ...
     recall(k, :), averagePrecision(k, :)] = getPerformance(labels{k}, ...
         scores{k}, targetClasses(targetNum), tolerances, sampleMask{k});
    
    %% Calculate performance when all targetClasses are considered hits
    [totalPositivesAll(k), totalRetrievedAll(k), precisionAll(k, :), ...
     recallAll(k, :), averagePrecisionAll(k, :)] = getPerformance(labels{k}, ...
        scores{k}, targetClasses, tolerances, sampleMask{k});
end

%% Save the results
save([outPath filesep 'precisionRecall.mat'], 'labels', 'scores', ...
    'targetClasses', 'targetNum', 'tolerances', 'sampleMask', 'totalPositives', ...
    'totalRetrieved', 'precision',  'recall', 'averagePrecision', ...
   'totalPositivesAll',  'totalRetrievedAll', 'precisionAll', ...
   'recallAll', 'averagePrecisionAll', '-v7.3');