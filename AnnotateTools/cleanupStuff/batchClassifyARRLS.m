%% Estimate classification scores of samples using the ARRLS classifier (original version)
%  
%  Parameters:
%       inPat: the pash to the data (samples and classes)
%       outPath: the path to the place where estimated scores are saved
%
function outPath = batchClassifyARRLS(testPaths, trainPaths, outPath, targetClass, varargin)

    %% Setup the parameters and reporting for the call     
    if ~isdir(outPath)    
        mkdir(outPath);   
    end

   %% Process the training and test sets
    numTests = length(testPaths);
    numTrain = length(trainPaths);
    for k = 1:numTests
        testData = load(testPaths{k});
        scoreData(numTrain) = getScoreDataStructure(); %#ok<AGROW>
        [~, testName, ~] = fileparts(testPaths{k});
        for i = 1:numTrain
           trainData = load(trainPaths{i});
           scoreData(i) = classifyARRLS(testData, trainData, ...
                                       targetClass, varargin{:}); 
           scoreData(i).testFileName =  testPaths{k};                   
           scoreData(i).trainFileName = trainPaths{i};
        end
        save([outPath filesep testName '_' targetClass], 'scoreData', '-v7.3');
        fprintf('ARRLS done train:%s\n       test: %s\n', trainPaths{i}, testPaths{k});
    end
      
     
end
