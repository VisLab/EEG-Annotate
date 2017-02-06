function [] = batchClassifyARRLSMod(testPaths, trainPaths, ...
                                         outPath, targetClass, varargin)
%% Classify using the ARRLS classifier (original version + pseudolabels)
%  
%  Parameters:
%       inPat: the pash to the data (samples and classes)
%       outPath: the path to the place where estimated scores are saved
%
    %Setup the parameters and reporting for the call   
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    %% Process the training and test sets
    numTests = length(testPaths);
    numTrain = length(trainPaths);
    for k = 1:numTests
        scoreData(numTrain) = getScoreDataStructure(); %#ok<AGROW>
        [~, testName, ~] = fileparts(testPaths{k});
        for i = 1:numTrain
           scoreData(i) = classifyARRLSMod(testPaths{k}, ...
                               trainPaths{i}, targetClass, varargin{:}); 
        end
        save([outPath filesep testName '_' targetClass], 'scoreData', '-v7.3');
    end
end