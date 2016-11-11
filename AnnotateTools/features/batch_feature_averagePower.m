%% Extract average power feature from raw EEG data
%  
%  Parameters:
%       inPat: the pash to the EEG datasets
%       outPath: the path to the place where extracted features are saved
%
function outPath = batch_feature_averagePower(inPath, varargin)

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
    fileList = dir([inPath filesep '*.set']);
    for i=1:length(fileList)
        EEG = pop_loadset(fileList(i).name, inPath);
        [samples, labels] = averagePower(EEG, varargin{:});
        save([outPath filesep fileList(i).name(1:end-4) '.mat'], 'samples', 'labels', '-v7.3');
    end
end