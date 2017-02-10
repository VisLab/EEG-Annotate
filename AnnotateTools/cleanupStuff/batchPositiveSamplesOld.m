function [] = batchPositiveSamplesOld(inPath, outPath, classLabel, ...
                                   tolerance, exclude, varargin)

%   Written by: Kyung-min Su, UTSA, 2016
%   Modified by: Kay Robbins, UTSA, 2017
%

%% If the outpath doesn't exist, make the directory  
if ~isdir(outPath)
    mkdir(outPath);
end

%% Create new training or test set from samples annotated with classLabel
fileList = dir([inPath filesep '*.mat']);
for k = 1:length(fileList)
    scoreFileName = [inPath filesep fileList(k).name];
    load(scoreFileName);
    testNames = {scoreData.testFileName};
    trainNames = {scoreData.trainFileName};
    exMask = strcmpi(testNames, trainNames);
    scoreData = scoreData(~exMask);
    [~, theName, ~] = fileparts(testNames{k});
    [labels, samples, sampleIndex, timeTolerance, nearestEvent] = ...
            getPositiveSamples(scoreData, classLabel, tolerance, varargin);  %#ok<NASGU,ASGLU>
    fileName = sprintf('%s_%s_positive.mat', theName, classLabel);
    save([outPath filesep fileName], 'classLabel', 'samples', 'labels', ...
            'timeTolerance', 'sampleIndex', 'nearestEvent', '-v7.3')
    if exclude
        if sum(strcmpi(testNames, testNames{1})) ~= length(testNames)
           warning('%d: %s classifications do not have same test file, skipping...', ...
                   k, scoreFileName);
        continue;
        end
        for j = 1:length(scoreData)
            thisScoreData = scoreData;
            thisScoreData(j) = [];
            [labels, samples, sampleIndex, timeTolerance, nearestEvent] = ...
                getPositiveSamples(thisScoreData, classLabel, tolerance, varargin);  %#ok<NASGU,ASGLU>
            [~, thisName, ~] = fileparts(testNames{j});
            fileName = sprintf('%s_%s_positive_ex_%s.mat', theName, classLabel, thisName);
            save([outPath filesep fileName], 'classLabel', 'samples', 'labels', ...
                'timeTolerance', 'sampleIndex', 'nearestEvent', '-v7.3')
        end
    end
end