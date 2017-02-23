function [] = batchGetSamplesAnnotatedPositive(inPath, outPath, ...
                                   classLabel, params)
%% Create training sets of positive samples for iterative reranking
%   
%   Parameters:
%      inPath  string containing directory of the classified samples
%      outPath string containing directory to write positive test files
%      classLabel  label of the positive class
%      params   structure containing the parameters for the algorithm
%
%   This program reads in an annotData structure and updates 
%   samples and labels fields. Where labels are the original true labels.
%   
%   Written by: Kyung-min Su, UTSA, 2016
%   Modified by: Kay Robbins, UTSA, 2017
%


    %% Set up the defaults and process the input arguments
    params = processAnnotateParameters('batchGetSamplesAnnotatedPositive', ...
                                        nargin, 3, params);
%% If the outpath doesn't exist, make the directory  
    if ~isdir(outPath)
        mkdir(outPath);
    end

    testPathBase = [];
%% Create new test set from samples annotated with classLabel
fileList = dir([inPath filesep '*.mat']);
for k = 1:length(fileList)
    annotData = [];
    annotDataFileName = [inPath filesep fileList(k).name];
    fprintf('Processing %s:\n', annotDataFileName);
    load(annotDataFileName);
    [~, testName, testExt] = fileparts(annotData.testFileName);
    if isempty(annotData)
        warning('%k: %s has no annotated data', k, annotDataFileName);
        continue;
    end
    
    %% Handle case where results are in different directory than original
    if ~isempty(testPathBase)
        testFile = [testPathBase filesep testName testExt];
    else
        testFile = annotData.testFileName;
    end
    testData = load(testFile);
    annotData = getSamplesAnnotatedPositive(annotData, ...
                                    testData.samples, testData.labels, ...
                                    classLabel, params); %#ok<NASGU>
    outFileName = [outPath filesep testName '_positive_' classLabel testExt]; 
    save(outFileName, 'annotData', '-v7.3');
end