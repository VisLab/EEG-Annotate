%% Estimate classification scores of samples using the ARRLS classifier
%  
%  Parameters:
%       inPat: the pash to the data (samples and classes)
%       outPath: the path to the place where estimated scores are saved
%
function outputFileNames = batchClassifyLDA(testPaths, trainPaths, ...
                                           outPath, targetClass, varargin)
   %% Make sure that the outPath exists, if not make the directory
   if ~exist(outPath, 'dir')
       mkdir(outPath);
   end
   
   %% Process the training-test set pairs using the LDA classifier
    numTests = length(testPaths);
    numTrain = length(trainPaths);
    outputFileNames = cell(numTrain*numTests, 1);
    nextFile = 1;
    for k = 1:numTests
        scoreData(numTrain) = getScoreDataStructure(); %#ok<AGROW>
     
        %% Load the test data
        dataTest = load(testPaths{k});
        [~, testName, ~] = fileparts(testPaths{k});
        for i = 1:numTrain
            dataTrain = load(trainPaths{i});
            scoreData(i) = classifyLDA(dataTest, dataTrain, ...
                                      targetClass, varargin{:});       
            scoreData(i).testFileName = testPaths{k};
            scoreData(i).trainFileName = trainPaths{i};
        end
        outputFileNames{nextFile} = [outPath filesep testName '_' targetClass];
        save(outputFileNames{nextFile}, 'scoreData', '-v7.3');
        nextFile = nextFile + 1;
    end
end