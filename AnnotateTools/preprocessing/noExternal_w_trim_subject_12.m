%% exclude external channels
% the condition of external channels: 
%  if a channel doesn't have a placement or its radius is larger than the boundary
%  
%  parameters:
%   pathIn, pathOut: path for input and for output
%   boundary: the max radius of valid EEG channels
%
function pathOut = noExternal_w_trim_subject_12(pathIn, pathOut, boundary)

    pathOut = [pathOut '_b' num2str(boundary)];
    
    if isdir(pathOut)
        warning(['Skip remove external channels, because ' pathOut ' is existed.']);
        return;
    else
        fprintf('%s is being created\n', pathOut);
        mkdir(pathOut);
    end
    
    fileList = dir([pathIn filesep '*.set']);
    for i=1:length(fileList)
        fileName = fileList(i).name;
        EEG = pop_loadset('filepath', pathIn, 'filename', fileName);
        % trim subject 12 data so that is has normal length (600 seconds)
        if strcmp(fileName(5:6), '12')
            EEG = pop_select(EEG, 'time', [0 600]);
        end
        ch_externals = [];
        for c=1:length(EEG.chanlocs)
            if isempty(EEG.chanlocs(c).radius) || (EEG.chanlocs(c).radius >= boundary)
                ch_externals = cat(1, ch_externals, c);
            end
        end
        newEEG = pop_select(EEG, 'nochannel', ch_externals);    % exclude external channels
        newEEG.data = double(newEEG.data);
        fileName = [fileName(1:end-4) '_noExt.set'];
        pop_saveset(newEEG, 'filepath', pathOut, 'filename', fileName, 'savemode', 'onefile');
        fprintf('exclude external channels [%d/%d, %s]\n', i, length(fileList), fileName);
    end
end
