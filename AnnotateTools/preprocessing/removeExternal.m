%% remove external channels
% 
%  an external channel is defined as:
%  if a channel doesn't have a placement information or its radius is larger than the boundary
%  
%  parameters:
%   EEGin: EEG data (in EEGLAB structure)
%   boundary: the max radius of valid EEG channels
%

function EEGout = removeExternal(EEGin, boundary)

    ch_externals = [];
    for c=1:length(EEGin.chanlocs)
        if isempty(EEGin.chanlocs(c).radius) || (EEGin.chanlocs(c).radius >= boundary)
            ch_externals = cat(1, ch_externals, c);
        end
    end
    EEGout = pop_select(EEGin, 'nochannel', ch_externals);    % exclude external channels
end


