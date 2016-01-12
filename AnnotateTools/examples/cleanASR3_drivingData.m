%% remove artifacts using ASR (clean_rawdata)
%  and it interpolates the removed channels, otherwise each subject has different number of channels.
%  
%  parameters:
%   EEGin: EEG data (in EEGLAB structure)
%   burst_thres: threshold for ASR burst option
%
function EEGout = cleanASR3_drivingData(EEGin, arg_burst)

    [boundaryEEG, ~, EEGout] = clean_artifacts(EEGin, 'BurstCriterion', arg_burst); 
    %   boundaryEEG : Final cleaned EEG recording.        
    %   hpEEG  : Optionally just the high-pass filtered data.
    %   EEGout : Optionally the data without final removal of "irrecoverable" windows.

    % interpolate removed channels
    if EEGout.nbchan ~= EEGin.nbchan
        pop_writelocs(EEGin.chanlocs, 'temp.sfp', 'filetype', 'sfp', 'format' , {'labels' '-Y' 'X' 'Z'}, 'header', 'off', 'customheader', '');
        %cleanEEG = pop_interpmont(cleanEEG, 'temp.sfp', 'manual', 'off'); 
        % It returns: Error using eval
        %             Undefined function or variable 'cleanEEG'.
        % The reason of the error (a bug):
        % it uses 'cleanEEG', the wrong variable name, inside the function. It should be the local name 'EEG'.
        EEGout = interpmont(EEGout, 'temp.sfp', 'nfids', 0);
    end

    % insert boundary events but do not remove data
    % replace the original boundary event with two new events (bBegin & bEnd)
    [EEGout, ~, ~] = addBoundaryEvents(EEGout, boundaryEEG);
    eeg_checkset(EEGout);
end

function [newEEG, bIndex, dSum] = addBoundaryEvents(EEG, boundaryEEG)

    EEG.urevent = EEG.event;        % copy the original event to the urevent
    % Driving dataset
    newEvent = struct('type', [], 'latency', [], 'urevent', [], 'usertags', [], 'duration', []);
    % VEP dataset
    % newEvent = struct('type', [], 'latency', [], 'urevent', [], 'duration', []);
    for i=1:length(EEG.urevent)
        if ischar(EEG.urevent(i).type)
            newEvent(i).type = EEG.urevent(i).type;
        elseif isnumeric(EEG.urevent(i).type)
            newEvent(i).type = int2str(EEG.urevent(i).type);
        else
            error('unknown event type');
        end
        newEvent(i).latency = EEG.event(i).latency;
        newEvent(i).urevent = i;
        newEvent(i).duration = 0;
        newEvent(i).usertags = EEG.event(i).usertags;
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
                newEvent(insertIdx) = eventTmp(i);
                newEvent(insertIdx).type = ['bBegin' num2str(bIndex)];
            else
                newEvent = [newEvent(1:insertIdx) newEvent(insertIdx:end)]; % make one entry to insert a boundary event
                newEvent(insertIdx) = eventTmp(i);  % add (actually copy) boundary event
                newEvent(insertIdx).type = ['bBegin' num2str(bIndex)];  % update the type from 'boundary' to 'bBegin + index'
            end
            
            % insert boundary end event to the new Event
            duration = eventTmp(i).duration;
            dSum = dSum + duration;
            insertIdx = find([newEvent.latency] > (eventTmp(i).latency+duration), 1);
            if isempty(insertIdx)
                insertIdx = length(newEvent) + 1;
                newEvent(insertIdx).type = ['bEnd' num2str(bIndex)];
                newEvent(insertIdx).latency = eventTmp(i).latency+duration;
                newEvent(insertIdx).urevent = [];
                newEvent(insertIdx).duration = 0;
            else
                newEvent = [newEvent(1:insertIdx) newEvent(insertIdx:end)];
                newEvent(insertIdx).type = ['bEnd' num2str(bIndex)];
                newEvent(insertIdx).latency = eventTmp(i).latency+duration;
                newEvent(insertIdx).urevent = [];
                newEvent(insertIdx).duration = 0;
            end
            
            % to increase the latencies of following boundary events            
            for j=i+1:length(eventTmp)
                eventTmp(j).latency = eventTmp(j).latency + eventTmp(i).duration;
            end
        end
    end   
    newEEG = EEG;
    newEEG.event = newEvent;
end
