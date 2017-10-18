function [features, featureLabels, params] = covarianceFeatures(EEG, params)
%% Extract covariance features and labels from an EEG structure.
%
%  Parameters:
%   EEG     EEGLAB data structure
%   
%   params  (Input/output) structure with any of the following fields set:
%     powerFeatureSubbands  
%           B x 2 array of B frequency bands for features.
%           Default: [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32]
%     powerFeatureWindowLength  
%           Window length in seconds.
%           Default: 1 
%     powerFeatureSubWindowLength 
%           Subwindow length in seconds.
%           Default:  0.125
%     powerFeatureWindowStep 
%           Window slide length in seconds (multiple of subwindow size).
%           Default:  0.125
%     powerFeatureExcludedChannels 
%           Cell array of channel labels to explicitly exclude.
%           Default: {}
%     powerFeatureExcludeNonEEGChannels 
%           If true exclude channels whose type is not 'EEG' 
%           Default: true
%     powerFeatureExcludeNonLocatedChannels 
%           If true exclude channels that do not have channel locations.
%           Default: true
%  
%  features       array with feature vectors in the columns
%  featureLabels     cell array of labels corresponding to the feature vectors
%  
%  Written by: Kyung Mu Su and Kay Robbins 2016-2017, UTSA
%
%% Get the parameters
    params = processAnnotateParameters('covarianceFeatures', nargin, 1, params);
    
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
 
    [features, featureLabels] = getFeatures(EEG, params); 
end

function [features, labels] = getFeatures(EEGin, config)
    sRate = EEGin.srate;   
    [numChans, numFrames] = size(EEGin.data); 
    stepFrames = round(sRate*config.featureWindowStep);
    windowFrames = round(sRate*config.featureWindowLength);
    numFeatures = floor((numFrames - windowFrames)/stepFrames) + 1;
    features = zeros(numChans, numChans, numFeatures);
    windBegin = 1;
    windEnd = windBegin + windowFrames - 1;
    for k = 1:numFeatures
        data = EEGin.data(:, windBegin:windEnd);
        features(:, :, k) = data*data';
        windBegin = windBegin + stepFrames;
        windEnd = windBegin + windowFrames - 1;
    end
    features = features./(numChans - 1);
    
    eventLabelString = getEventLabelInString(EEGin.event);       
    
    eventLatencySecond = [EEGin.event.latency]' ./ sRate;            
    eventIndex = floor(eventLatencySecond ./ config.featureWindowStep) + 1;          
    
    labels = cell(1, numFeatures);   
    for i = 1:length(eventLabelString)
        if eventIndex(i) < length(labels)  
            if isempty(labels{eventIndex(i)})
                labels{eventIndex(i)} = eventLabelString(i);
            else
                labels{eventIndex(i)} = [labels{eventIndex(i)} eventLabelString(i)];      
            end
        end
    end  
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
