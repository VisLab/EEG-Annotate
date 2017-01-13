function outPath = batch_annotation(inPath, varargin)
%   batch_annotation() 
%       - estimate annotation scores using the annotator
%       - the annotator uses the Fuzzy voting and adaptive cutoff
%
%   Example:
%       outPath = batch_annotation('.\pathIn');
%       outPath = batch_annotation('.\pathIn', ...
%                    'outPath', '.\pathOut', ...
%                    'excludeSelf', true, ...
%                    'adaptiveCutoff', true, ...
%                    'rescaleBeforeCombining', true, ...
%                    'position', 8, ...
%                    'weights', [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]);
%
%   Inputs:
%       inPath: the pash to the classification scores
%   
%   Optional inputs:
%       'outPath': the path to the place where estimated annotation scores will be saved. (default: '.\temp')
%       'excludeSelf', when we use the same datasets for training and test, 
%                      if this flag is true, the test set is excluded from the training set.
%                      If the flag is false, it uses all training sets for annotaion.
%       'adaptiveCutoff', option to use the adaptive cutoff on the combined scores
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
%           wmScore: the cell containing the weighted and mask-out scores
%           allScores: the 2D matrix containing normalized wmScore. [number of samples x number of training sets]
%           combinedScore = the array of combined and mask-out scores
%
%   Author:
%       Kyung-min Su, The University of Texas at San Antonio, 2016
%

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);
    for i=1:length(fileList)
        readData = load([inPath filesep fileList(i).name]);
        annotData = annotator(readData.scoreData, i, varargin{:});
        try 
            fileName = [outPath filesep fileList(i).name];
            save(fileName, 'annotData', '-v7.3');
        catch ME
            if strcmp(ME.identifier, 'MATLAB:save:unableToWriteToMatFile') % if filename is too long
                delete(fileName);      % remove the error file
                annotData.originalFileName = fileList(i).name;
                fileName = [outPath filesep 'file_' num2str(i, '%02d') '.mat'];
                save(fileName, 'annotData', '-v7.3');
                fprintf('file_%02d.mat <== %s\n', i, fileList(i).name);
            else
                rethrow(ME);
            end
        end
    end
end