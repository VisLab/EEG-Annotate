%% Estimate annotation scores using the annotator
%  
%  Parameters:
%       inPat: the pash to the classification scores
%       outPath: the path to the place where estimated scores are saved
%
function outPath = batch_annotation(inPath, varargin)
%   batch_annotation() 
%       - estimate annotation scores using the annotator
%       - annotator currently use the Fuzzy voting and adaptive cutoff
%
%   Example:
%       outPath = batch_annotation('.\pathIn_test', '\pathIn_train', 'outPath', '.\pathOut');
%  
%   Inputs:
%       inPath_test: the pash to the test EEG datasets
%       inPath_train: the pash to the training EEG datasets
%   
%   Optional inputs:
%       'outPath': the path to the place where estimated classification scores will be saved. (default: '.\temp')
%       'targetClass', trainTargetClass, ...
%       'ARRLS_p', ARRLS option p (default: 10)
%       'ARRLS_sigma',  ARRLS option sigma weight (default: 0.1)
%       'ARRLS_lambda',  ARRLS option lambda weight (default: 10.0)
%       'ARRLS_gamma',  ARRLS option gamma weight (default: 1.0)
%       'ARRLS_ker',  ARRLS option kernel name (default: 'linear')
%       'IMB_BT', option to use balanced training set for the initial classifier (default: true)
%       'IMB_AC1', option to use the adaptive cutoff on the intial scores (default: true)
%       'IMB_W', option to use reweighting for three terms (default: [true true false])
%       'IMB_AC2', option to use the adaptive cutoff on the final scores (default: true)
%       'fSaveTrainScore', if true, save the training scores too
%
%   Output:
%       outPath: the path to the place where classification scores were saved
%
%   Note:
%       It stores estimated classification scores using the scoreData structure. 
%       scoreData structure has eight fields.
%           testLabel = the cell containing the true labels of test samples
%           predLabel = the cell containing the predicted labels of test samples
%           testInitProb = the cell containing the intial scores 
%           testInitCutoff = the array of intial cutoff
%           testFinalScore = the cell containing the final scores 
%           testFinalCutoff = the array of final cutoff
%           trainLabel = the cell containing the true labels of training samples
%           trainScore = the cell containing the scores of training samples
%
%   Authou:
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