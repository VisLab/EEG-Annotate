%% 
%
function outPath = batch_preprocess_cleanASR(inPath, varargin)

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
        EEG = cleanASR(EEG, 'burstCriterion', burstCriterion);
        save([outPath filesep fileList(i).name], 'EEG', '-v7.3');
    end    
end