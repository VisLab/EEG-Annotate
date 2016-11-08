%% Apply the high pass filter on the all EEG datasets in the inPath
%  
%  Parameters:
%       inPat: the pash to the EEG datasets
%       outPath: the path to the place where filtered EEG datasets are saved
%
function outPath = batch_preprocess_highPassNew(inPath, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all files and process them using the specified function
    fileList = dir([inPath filesep '*.set']);
    for i=1:length(fileList)
        EEG = pop_loadset(fileList(i).name, inPath);
        EEG = highpassNew(EEG, varargin{:});
        save([outPath filesep fileList(i).name], 'EEG', '-v7.3');
    end    
end