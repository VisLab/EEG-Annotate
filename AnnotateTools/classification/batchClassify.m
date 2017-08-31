function outFiles = batchClassify(testPaths, trainPaths, ...
                          outPath, targetClass, targetClassifier, params)
%% Perform a batch classification class for lists of training and test data.
%  
%  Parameters:
%    testPaths        cell array of full path names to test files
%    trainPaths       cell array of full path names to train files
%    outPath          base path name for saving results
%    targetClass      string containing the target class (one vs all)
%    targetClassifier string giving name of classifier
%                     ('lda', 'arrls', 'arrlsimb', 'arrlsmod')
%    params           structure containing parameters to override defaults
%    outFiles         (output) cell array of paths to output results
%
%  The input files contain feature vectors in columns of an array called
%  samples as well as a cell array of labels.
%
%  The output files consist of a scoreData structure containing all of the
%  classification results for a single test file.
%
%  Written by: Kyung Mu Su and Kay Robbins 2016-2017, UTSA
%
    %% Set up the defaults and process the input arguments
    params = processAnnotateParameters('batchClassify', nargin, 5, params);

    %% Make sure that the outPath exists, if not make the directory
    if ~exist(outPath, 'dir')
      mkdir(outPath);
    end

    %% Process the training-test set pairs using the LDA classifier
    numTests = length(testPaths);
    numTrain = length(trainPaths);
    outFiles = cell(numTests, 1);
    for k = 1:numTests
        if params.verbose
            fprintf('%s class:%s test set: %s\n', targetClassifier, ...
                targetClass, testPaths{k});
        end
        scoreData(numTrain) = getScoreDataStructure(); %#ok<AGROW>
        
        %% Load the test data
        dataTest = load(testPaths{k});
        [~, testName, ~] = fileparts(testPaths{k});
        for i = 1:numTrain
            if params.verbose
                fprintf('   train set: %s\n', trainPaths{i});
            end
            dataTrain = load(trainPaths{i});
            switch lower(targetClassifier)
                case 'lda'
                    scoreData(i) = classifyLDA(dataTest, dataTrain, ...
                        targetClass, params);
                case 'arrls'
                    scoreData(i) = classifyARRLS(dataTest, dataTrain, ...
                        targetClass, params);
                case 'arrlsimb'
                    scoreData(i) = classifyARRLSimb(dataTest, dataTrain, ...
                        targetClass, params);
                case 'arrlsmod'
                    scoreData(i) = classifyARRLSMod(dataTest, dataTrain, ...
                        targetClass, params); 
                otherwise
                    error('batchClassify:BadClassifier', ...
                        'Classifier %s is not supported', targetClassifier);
            end
            scoreData(i).testFileName = testPaths{k};
            scoreData(i).trainFileName = trainPaths{i};
        end
        outFiles{k} = [outPath filesep testName '_' targetClass];
        save(outFiles{k}, 'scoreData', '-v7.3');
    end
end
            