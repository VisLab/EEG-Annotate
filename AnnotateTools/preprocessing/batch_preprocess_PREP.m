%% Apply the PREP process on the all EEG datasets in the inPath
%  
%  Parameters:
%       inPat: the pash to the EEG datasets
%       outPath: the path to the place where PREP processed EEG datasets are saved
%  
%  Note:
%       Because the PREP uses the random selection of samples to extrapolate, its output could be slightly different each time.
%
function outPath = batch_preprocess_PREP(inPath, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    params = rmfield(params, 'outPath');
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end
    
    % go over all files and process them using the specified function
    fileList = dir([inPath filesep '*.set']);
    for i=1:length(fileList)
        EEG = pop_loadset(fileList(i).name, inPath);
        params.name = fileList(i).name;
        [EEG, computationTimes] = prepPipeline(EEG, params);
        fprintf('Computation times (seconds):\n   %s\n', ...
            getStructureString(computationTimes));
        save([outPath filesep fileList(i).name], 'EEG', '-v7.3');
    end    
end