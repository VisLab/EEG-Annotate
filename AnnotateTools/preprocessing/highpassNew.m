function EEG = highpassNew(EEG, varargin)
% Perform highpass filtering
% Parameters
%       cutoff: cutoff of the high pass filter (default: 1 Hz)
try
    % Convert name-value pair parameters to structure   
    params = vargin2struct(varargin);  
    arg_cutoff = 1;   % defatult 
    if isfield(params, 'cutoff')
        arg_cutoff = params.cutoff;
    end
    
    % make new EEG in which external channels have been removed
    exFlag = zeros(length(EEG.chanlocs), 1);
    for c=1:length(EEG.chanlocs)
        if isempty(EEG.chanlocs(c).radius) % || (EEG.chanlocs(c).radius >= boundary)
            exFlag(c) = 1;  % external channels
        end
    end
    ch_internals = (exFlag==0);
    ch_externals = find(exFlag==1);
    EEGonly = pop_select(EEG, 'nochannel', ch_externals);    % exclude external channels
    
    % highpass filtering using new filtering function
    [EEGfiltered, com, b] = pop_eegfiltnew(EEGonly, arg_cutoff, 0); 

    % copy cleaned EEG data to the input EEG data that has all (external and internal) channels.
    EEG.data(ch_internals, :) = EEGfiltered.data;
    
    EEG.etc.HP.cutoff =  arg_cutoff;
    EEG.etc.HP.commands =  com;             % command
    EEG.etc.HP.filterOrder =  length(b)-1;		% filter order
    EEG.setname = [EEG.setname  ' Highpass filtered'];    
catch mex
    errorMessages.HP = ['failed HP: ' getReport(mex)];
    errorMessages.status = 'unprocessed';
    EEG.etc.HP.errors = errorMessages;
    fprintf(2, '%s\n', errorMessages.HP);
end
end