%% Processes dedicated for the VEP datasets
% 
%  1) Cut subject 12 datasets into 600 seconds length
%  2) Remove external channels because annotator uses only EEG channels
%
%  Parameters:
%       inPat: the pash to the EEG datasets
%       outPath: the path to the place where filtered EEG datasets are saved
%
function outPath = batch_preprocess_VEP_exclusive(inPath, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    boundary = 1;       % the head size, default 1
    if isfield(params, 'boundary')
        boundary = params.boundary;
    end
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all files and process them using the specified function
    fileList = dir([inPath filesep '*.set']);
    for i=1:length(fileList)
        EEG = pop_loadset(fileList(i).name, inPath);
        % trim subject 12 data so that is has normal length (600 seconds)
        if strcmp(fileList(i).name(5:6), '12')
            EEG = pop_select(EEG, 'time', [0 600]);
        end
        ch_externals = [];
        for c=1:length(EEG.chanlocs)
            if isempty(EEG.chanlocs(c).radius) || (EEG.chanlocs(c).radius >= boundary)
                ch_externals = cat(1, ch_externals, c);
            end
        end
        EEG = pop_select(EEG, 'nochannel', ch_externals);    % exclude external channels
        save([outPath filesep fileList(i).name], 'EEG', '-v7.3');
    end    
end