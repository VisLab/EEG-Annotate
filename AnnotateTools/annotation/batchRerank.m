function outputFileNames = batchRerank(testPaths, trainPaths, outPath, ...
                                     targetClass, targetClassifier, params)
%% Estimate classification scores of samples using the ARRLS classifier
%  
%  Parameters:
%       inPat: the pash to the data (samples and classes)
%       outPath: the path to the place where estimated scores are saved
%
    %% Set up the defaults and process the input arguments
    params = processAnnotateParameters('batchRerank', nargin, 5, params);

    %% Make sure that the outPath exists, if not make the directory
    if ~exist(outPath, 'dir')
      mkdir(outPath);
    end

    %% Process the training-test set pairs using the LDA classifier
    numTests = length(testPaths);
    numTrain = length(trainPaths);
    outputFileNames = cell(numTests, 1);
    for k = 1:numTests
        if params.verbose
            fprintf('%s class:%s test set: %s\n', targetClassifier, ...
                targetClass, testPaths{k});
        end
        scoreData(numTrain) = getScoreDataStructure(); %#ok<AGROW>
        
        %% Load the test data
        dataRead = load(testPaths{k});
        dataTest.labels = dataRead.annotData.labels;
        dataTest.samples = dataRead.annotData.samples;
        annotData = dataRead.annotData; 
        [~, baseName, ~] = fileparts(annotData.testFileName);
        [~, testName, ~] = fileparts(testPaths{k});
        selfMask = false(length(numTrain), 1);
        for i = 1:numTrain
            if params.verbose
                fprintf('   train set: %s\n', trainPaths{i});
            end
            dataTrain = load(trainPaths{i});
            if params.rerankPositive
                dataTrain.samples = dataTrain.annotData.samples;
                dataTrain.labels = dataTrain.annotData.labels;
            end
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
            [~, trainName, ~] = fileparts(trainPaths{i});
            selfMask(i) = strcmpi(trainName, baseName);
        end
        rankScoreData = scoreData(~selfMask);
        rankCounts = rankScoreData(1).finalScores > rankScoreData(1).finalCutoff;
        for n = 2:length(rankScoreData)
            rankCounts = rankCounts + ...
                (rankScoreData(n).finalScores > rankScoreData(n).finalCutoff);
        end
        annotData.rankCounts = rankCounts;
        outputFileNames{k} = [outPath filesep testName '_' targetClass];
        save(outputFileNames{k}, 'scoreData', 'annotData', '-v7.3');
    end
end
            