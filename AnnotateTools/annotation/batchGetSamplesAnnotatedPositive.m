function [] = batchGetSamplesAnnotatedPositive(inPath, outPath, ...
                                   classLabel, tolerance, varargin)
%% Create training sets of positive samples for iterative reranking
%
%   
%   Written by: Kyung-min Su, UTSA, 2016
%   Modified by: Kay Robbins, UTSA, 2017
%

%% Set the options for the paths
    params = vargin2struct(varargin); 
    
    %% Set revised test path if data has been moved
    testPathBase = [];
    if isfield(params, 'testPathBase')
        testPathBase = params.testPathBase;
    end
    
%% If the outpath doesn't exist, make the directory  
    if ~isdir(outPath)
        mkdir(outPath);
    end

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
    
    if ~isempty(testPathBase)
        testFile = [testPathBase filesep testName testExt];
    else
        testFile = annotData.testFileName;
    end
    testData = load(testFile);
    annotData = getSamplesAnnotatedPositive(annotData, ...
                                    testData.samples, testData.labels, ...
                                    classLabel, tolerance); %#ok<NASGU>
    outFileName = [outPath filesep testName '_positive_' classLabel testExt]; 
    save(outFileName, 'annotData', '-v7.3');
end