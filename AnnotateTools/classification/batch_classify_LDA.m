%% Estimate classification scores of samples using the ARRLS classifier
%  
%  Parameters:
%       inPat: the pash to the data (samples and classes)
%       outPath: the path to the place where estimated scores are saved
%
function outPath = batch_classify_LDA(inPath_test, inPath_train, varargin)

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
        scoreData = classify_LDAs(testData, inPath_train, varargin{:});
        save([outPath filesep fileList_test(i).name], 'scoreData', '-v7.3');
    end
end