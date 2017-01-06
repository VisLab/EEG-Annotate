function EEGout = cleanMARA(EEGin, varargin)
% Perform MARA cleaning
% The input data (pointed by icachansind) and the ICA.weight have the same dimension.
try
    EEGout = EEGin; 
    
    % tempoary EEG set that has only ica processed channels
    ch_ica = EEGin.icachansind;
    ch_exclude = 1:length(EEGin.chanlocs);
    ch_exclude(ch_ica) = [];
    
    EEGica = pop_select(EEGin, 'channel', ch_ica);    % exclude non-ica channels
    
    % clean EEG using MARA
    [~, EEGout, ~] = processMARA(EEGica, EEGica, 1, [0, 0, 0, 0, 1]);

    % recover external channels and channel locations
    EEGout.nbchan = EEGin.nbchan;
    icaData = EEGout.data;
    EEGout.data = zeros(size(EEGin.data));
    EEGout.data(ch_ica, :) = icaData;
    EEGout.data(ch_exclude, :) = EEGin.data(ch_exclude, :);
    EEGout.chanlocs = EEGin.chanlocs;    
catch mex
    errorMessages.MARA = ['failed MARA: ' getReport(mex)];
    errorMessages.status = 'unprocessed';
    EEGout.etc.MARA.errors = errorMessages;
    fprintf(2, '%s\n', errorMessages.MARA);
end
end
