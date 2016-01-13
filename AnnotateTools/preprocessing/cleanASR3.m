function EEG = cleanASR3(EEG, varargin)
% Perform ASR cleaning
% Parameters
%     burstCriterion    Standard deviation cutoff for removal of bursts (Default: 5)
try
%Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    arg_burst = 5;   % defatult 
    if isfield(params, 'burstCriterion')
        arg_burst = params.burstCriterion;
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
    
    % clean EEG using ASR
    [newEEG_w_boundary, ~, newEEG_wo_boundary] = clean_artifacts(EEGonly, 'BurstCriterion', arg_burst); 
    %   newEEG_w_boundary : Final cleaned EEG recording.        
    %   hpEEG  : Optionally just the high-pass filtered data.
    %   newEEG_wo_boundary : Optionally the data without final removal of "irrecoverable" windows.

    % interpolate removed EEG channels
    if newEEG_wo_boundary.nbchan ~= EEGonly.nbchan 
        pop_writelocs(EEGonly.chanlocs, 'temp.sfp', 'filetype', 'sfp', 'format' , {'labels' '-Y' 'X' 'Z'}, 'header', 'off', 'customheader', '');
        newEEG_wo_boundary = interpmont(newEEG_wo_boundary, 'temp.sfp', 'nfids', 0);
        delete('temp.sfp');
    end

    % copy cleaned EEG data to the input EEG data that has all (external and internal) channels.
    EEG.data(ch_internals, :) = newEEG_wo_boundary.data;
    
    % insert boundary events, but do not remove data
    [EEG, bCount, dSum] = addBoundaryEvents(EEG, newEEG_w_boundary);

    EEG.etc.ASR.burstCriterion =  arg_burst;
    EEG.etc.ASR.boundaryCount =  bCount;  	% number of boundary events
    EEG.etc.ASR.boundaryLength =  dSum;		% total length of boundary events
    EEG.setname = [EEG.setname  ' Cleaned using ASR'];    
catch mex
    errorMessages.ASR = ['failed ASR: ' getReport(mex)];
    errorMessages.status = 'unprocessed';
    EEG.etc.ASR.errors = errorMessages;
    fprintf(2, '%s\n', errorMessages.ASR);
end
end

% The original ASR removes windows of noise signals.
% Instead of deleting windows, it just adds boundary events marking bad windows.
function [newEEG, bIndex, dSum] = addBoundaryEvents(EEG, boundaryEEG)

    EEG.urevent = EEG.event;        % copy the original event to the urevent
    
    newEvent = EEG.event;           % newEvent, struct('type', 'latency', 'urevent', 'duration', 'usertag (optional)');
    for i=1:length(EEG.event)
        if ischar(EEG.event(i).type)
            newEvent(i).type = EEG.event(i).type; % force string event type. Because of boundary events, use the string type
        elseif isnumeric(EEG.event(i).type)
            newEvent(i).type = int2str(EEG.event(i).type);
        else
            error('unknown event type');
        end
        newEvent(i).urevent = i;
        newEvent(i).duration = 0;
    end
    
    eventTmp = boundaryEEG.event;
    bIndex = 0; % boundary index
    dSum = 0;   % sum of duration
    for i=1:length(eventTmp)
        if (strcmp(eventTmp(i).type, 'boundary'))
            bIndex = bIndex + 1;
            
            % insert boundary event to the newEvent
            insertIdx = find([newEvent.latency] > eventTmp(i).latency, 1);
            if isempty(insertIdx)
                insertIdx = length(newEvent) + 1;
            else
                newEvent = [newEvent(1:insertIdx) newEvent(insertIdx:end)]; % make new entry to insert a boundary event
            end
            newEvent(insertIdx) = eventTmp(i);  % add (actually copy) boundary event
            
            dSum = dSum + eventTmp(i).duration;
                        
            % increase the latencies of following boundary events            
            for j=i+1:length(eventTmp)
                eventTmp(j).latency = eventTmp(j).latency + eventTmp(i).duration;
            end
        end
    end   
    newEEG = EEG;
    newEEG.event = newEvent;
end