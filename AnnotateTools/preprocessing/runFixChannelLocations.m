%% Get the labels
chanlocs = EEG.chanlocs;

chanLabels = {chanlocs.labels};
labelsToRemove = {'AFz', 'AF7', 'AF8', 'P9', 'P10', 'Iz'};
chanMask = true(1, length(chanLabels));
for k = 1:length(chanLabels)
    if sum(strcmpi(labelsToRemove, chanLabels{k})) > 0
        chanMask(k) = false;
    end
end
baseChannelLocs = chanlocs(chanMask);

function outPath = batch_preprocess_BCIT_ESS_exclusive(inPath, experimentName, level2File, varargin)

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
    % Make sure level 2 derived study validates
    derivedXMLFile = [inPath filesep experimentName filesep level2File];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);

    % Get the file (.set) list
    [filenames, ~, ~, sessionNumbers, ~] = getFilename(obj);

    % go over all files and apply a feature extraction function
    for i=1:length(filenames)
        [path, name, ext] = fileparts(filenames{i});
        EEG = pop_loadset([name ext], path);
        % exclude external channels
        ch_externals = [];
        for c=1:length(EEG.chanlocs)
            if isempty(EEG.chanlocs(c).radius) || (EEG.chanlocs(c).radius >= boundary)
                ch_externals = cat(1, ch_externals, c);
            end
        end
        EEG = pop_select(EEG, 'nochannel', ch_externals);    % exclude external channels
        
        save([outPath filesep 's' num2str(sessionNumbers{i}) '_' name ext], 'EEG', '-v7.3');
    end
end

% chanlocs = EEG.chanlocs;
% theseLabels = {chanlocs.labels};
% baseLabels = {baseLocs.labels};
% baseMask = zeros(1, length(chanlocs));
% 
% for k = 1:length(baseMask)
%     thisLoc =  find(strcmpi(baseLabels, theseLabels{k})
% 
%     
% 
%     
