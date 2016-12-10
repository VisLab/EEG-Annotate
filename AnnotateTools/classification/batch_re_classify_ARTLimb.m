%% Estimate classification scores of samples using the ARRLS classifier
%  
%  Parameters:
%       inPat: the pash to the data (samples and classes)
%       outPath: the path to the place where estimated scores are saved
%
function outPath = batch_re_classify_ARTLimb(inPath_test, inPath_test_initScore, inPath_train, inPath_train_initScore, varargin)

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
    fileList_initScore = dir([inPath_test_initScore filesep '*.mat']);
    if length(fileList_test) ~= length(fileList_initScore)
        error('number of files are not matched');
    end
    for i=1:length(fileList_test)
        testData = load([inPath_test filesep fileList_test(i).name]);
        load([inPath_test_initScore filesep fileList_initScore(i).name]); % load scoreData
        scoreData = re_classify_ARTLimbs(testData, scoreData, inPath_train, inPath_train_initScore, i, varargin{:});
        save([outPath filesep fileList_test(i).name], 'scoreData', '-v7.3');
    end
end