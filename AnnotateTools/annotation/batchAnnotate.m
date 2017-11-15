function outPath = batchAnnotate(inPath, outPath, classLabel, params)
%  Combines scores to annotate
%       - estimate annotation scores using the annotator
%       - the annotator uses the Fuzzy voting and adaptive cutoff
%
%   Example:
%       outPath = batch_annotation('.\pathIn');
%       outPath = batch_annotation('.\pathIn', ...
%                    'outPath', '.\pathOut', ...
%                    'excludeSelf', true, ...
%                    'adaptiveCutoff1', true, ...
%                    'adaptiveCutoff2', true, ...
%                    'rescaleBeforeCombining', true, ...
%                    'weights', [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]);
%
%   Inputs:
%       inPath: the path to the classification scores
%   
%   Optional inputs:
%       'outPath': the path to the place where estimated annotation scores will be saved. (default: '.\temp')
%       'excludeSelf', when we use the same datasets for training and test, 
%                      if this flag is true, the test set is excluded from the training set.
%                      If the flag is false, it uses all training sets for annotaion.
%       'adaptiveCutoff1', option to use the adaptive cutoff on the classfication scores
%       'adaptiveCutoff2', option to use the adaptive cutoff on the combined scores
%       'rescaleBeforeCombining', if true, normalize scores so that they are in 0 to 1 range, before combining
%       'position', the center of re-weighting area
%       'weights',  the weights of scores
%
%   Output:
%       outPath: the path to the place where annotation scores were saved
%
%   Note:
%       It stores estimated classification scores using the annotData structure. 
%       annotData structure has eight fields.
%           testLabel: the cell containing the true labels of test samples
%           predLabel: the cell containing the predicted labels of test samples
%           testInitProb: the cell containing the intial scores 
%           testInitCutoff: the array of intial cutoff
%           testFinalScore: the cell containing the final scores 
%           testFinalCutoff: the array of final cutoff
%           trainLabel: the cell containing the true labels of training samples
%           trainScore: the cell containing the scores of training samples
%           allScores: the 2D matrix containing scores for combining.
%                       scores have been normalized, weighted and mask-outed.
%                       allScores = [number of samples x number of training sets]
%           combinedScore = the array of combined scores
%           combinedCutoff = the cutoff for the combinedScore
%
%   Written by: Kyung-min Su, UTSA, 2016
%   Modified by: Kay Robbins, UTSA, 2017
%

%% If the outpath doesn't exist, make the directory 
    params = processAnnotateParameters('batchAnnotate', nargin, 3, params);
    if ~isdir(outPath)    
        mkdir(outPath);   
    end
    % 'Indices', .
%% Annotate files by combining score data
    fileList = dir([inPath filesep '*.mat']);
    for k = 1:length(fileList)
        thisFile = [inPath filesep fileList(k).name];
        if params.verbose
            fprintf('Annotating %s ...\n', thisFile);
        end
        load(thisFile);

        %% Remove test file  and bad files from the training data if present
        trainFiles = {scoreData.trainFileName};
        trainMask = strcmpi(trainFiles, scoreData(1).testFileName);
        if ~isempty(params.AnnotateBadTrainFiles)
            trainNames = cell(size(trainMask));
            for n = 1:length(trainNames)
                [~, trainNames{n}] = fileparts(trainFiles{n});
            end
            for n = 1:length(params.AnnotateBadTrainFiles)
                trainMask = trainMask | strcmpi(trainNames, params.AnnotateBadTrainFiles{n});
            end
        end
       
        %% Annotate and save the data
        annotData = annotate(scoreData(~trainMask), classLabel, params); %#ok<NASGU>
        fileName = [outPath filesep fileList(k).name];
        save(fileName, 'annotData', '-v7.3');
    end
end