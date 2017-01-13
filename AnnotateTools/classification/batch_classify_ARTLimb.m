function outPath = batch_classify_ARTLimb(inPath_test, inPath_train, targetClass, varargin)
%   batch_classify_ARTLimb() 
%       - estimate classification scores of samples using the ARTLimb classifier
%       - ARTLimb classifier: ARTL classifier modified to handle imbalanced data
%
%   Example:
%       outPath = batch_classify_ARTLimb('.\pathIn_test', '\pathIn_train', 'targetClass', '34');
%       outPath = batch_classify_ARTLimb('.\pathIn_test', '\pathIn_train', 'targetClass', '34', 
%                                       'outPath', '.\pathOut', ...
%                                       'ARRLS_p', 10, ...    
%                                       'ARRLS_sigma', 0.1, ...
%                                       'ARRLS_lambda', 10.0, ...
%                                       'ARRLS_gamma', 1.0, ...
%                                       'ARRLS_ker', 'linear', ...
%                                       'IMB_BT', true, ...   
%                                       'IMB_AC1', true, ...
%                                       'IMB_W', [true true false], ...
%                                       'IMB_AC2', true, ...
%                                       'fSaveTrainScore', true);
% 
%   Inputs:
%       inPath_test: the pash to the test EEG datasets
%       inPath_train: the pash to the training EEG datasets
%       'targetClass': the labels of target class
%   
%   Optional inputs:
%       'outPath': the path to the place where estimated classification scores will be saved. (default: '.\temp')
%       'ARRLS_p': ARRLS option p (default: 10)
%       'ARRLS_sigma':  ARRLS option sigma weight (default: 0.1)
%       'ARRLS_lambda':  ARRLS option lambda weight (default: 10.0)
%       'ARRLS_gamma':  ARRLS option gamma weight (default: 1.0)
%       'ARRLS_ker':  ARRLS option kernel name (default: 'linear')
%       'IMB_BT': option to use balanced training set for the initial classifier (default: true)
%       'IMB_AC1': option to use the adaptive cutoff on the intial scores (default: true)
%       'IMB_W': option to use reweighting for three terms (default: [true true false])
%       'IMB_AC2': option to use the adaptive cutoff on the final scores (default: true)
%       'fSaveTrainScore': if true, save the training scores too
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
    fileList_test = dir([inPath_test filesep '*.mat']);
    for i=1:length(fileList_test)
        testData = load([inPath_test filesep fileList_test(i).name]);
        scoreData = classify_ARTLimbs(testData, inPath_train, targetClass, varargin{:});
        save([outPath filesep fileList_test(i).name], 'scoreData', '-v7.3');
    end
end