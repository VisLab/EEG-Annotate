
function [features, featureLabels, params] = timeFeatures(EEG, params)
%% Extract time features and labels from an EEG structure.
%
%  Parameters:
%   EEG     EEGLAB data structure
%   
%   params  (Input/output) structure with any of the following fields set:
%   
%     featureWindowLength  
%           Window length in seconds.
%           Default: 1 
%     featureSubWindowLength 
%           Subwindow length in seconds.
%           Default:  0.125
%     featureWindowStep 
%           Window slide length in seconds (multiple of subwindow size).
%           Default:  0.125
%     featureExcludedChannels 
%           Cell array of channel labels to explicitly exclude.
%           Default: {}
%     featureExcludeNonEEGChannels 
%           If true exclude channels whose type is not 'EEG' 
%           Default: true
%     featureExcludeNonLocatedChannels 
%           If true exclude channels that do not have channel locations.
%           Default: true
%  
%  features       array with feature vectors in the columns
%  featureLabels     cell array of labels corresponding to the feature vectors
%  
%  Written by: Kay Robbins 2016-2018, UTSA
%
%% Get the parameters
    params = processAnnotateParameters('timeFeatures', nargin, 1, params);
    
    %% Eliminate exclude channels
    chanlocs = EEG.chanlocs;
    excludedLabels = params.featureExcludedChannels;
    channelMask = false(length(chanlocs), 1);
    for k = 1:length(chanlocs)
        if ~isempty(excludedLabels) && ...
                sum(strcmpi(excludedLabels, chanlocs(k).labels)) > 0
            channelMask(k) = true;
        elseif params.featureExcludeNonLocatedChannels && ...
                isempty(chanlocs(k).X) && isempty(chanlocs(k).sph_theta) ...
                && isemtpy(chanlocs(k).radius)
            channelMask(k) = true;
        elseif params.featureExcludeNonEEGChannels && ...
                ~isempty(chanlocs(k).type) && ...
                ~strcmpi(chanlocs(k).type, 'EEG')
            channelMask(k) = true;
        end
    end
    EEG.data(channelMask, :) = [];
    EEG.chanlocs(channelMask) = [];
    EEG.nbchan = size(EEG.data, 1);
    EEG = pop_eegfiltnew(EEG, [],40,44,0,[],0);
    [features, featureLabels] = getFeatures(EEG, params); 
end

function [features, labels] = getFeatures(EEGin, config)

    [numChans, numFrames] = size(EEGin.data);
   
    sRate = EEGin.srate;
    winLengthFrame = round(sRate*config.featureWindowLength); 
    stepFrame = round(sRate*config.featureWindowStep); 
    numFeatures = floor((numFrames - winLengthFrame)/stepFrame) + 1;
    features = zeros(numChans*winLengthFrame, numFeatures);
    windBegin = 1;
     for n = 1:numFeatures
        windEnd = windBegin + winLengthFrame - 1;
        thisFeature = EEGin.data(:, windBegin:windEnd);
        features(:, n) = thisFeature(:);
        windBegin = windBegin + stepFrame;
     end
  
    eventLabelString = getEventLabelInString(EEGin.event);       
    
    eventLatencySecond = [EEGin.event.latency]' ./ sRate;            
    eventIndex = floor(eventLatencySecond ./ config.featureWindowStep) + 1;          
    
    labels = cell(1, size(features, 2));   
    for i = 1:length(eventLabelString)
        if eventIndex(i) < length(labels)  
            if isempty(labels{eventIndex(i)})
                labels{eventIndex(i)} = eventLabelString(i);
            else
                labels{eventIndex(i)} = [labels{eventIndex(i)} eventLabelString(i)];      
            end
        end
    end  
%     features = features(:, 1:end-8);
%     labels = labels(1:end-8)';
end

function label = getEventLabelInString(event)
    % force string format event labels
    eventNumb = length(event);
    label = cell(eventNumb, 1); 
    for e=1:eventNumb
        if isnumeric(event(e).type)
            label{e} = num2str(event(e).type);
        elseif ischar(event(e).type)
            label{e} = event(e).type;
        else
            warning('unknown event type');
        end
    end
end
