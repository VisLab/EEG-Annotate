
function [features, featureLabels, params] = powerFeatures(EEG, params)
%% Extract power features and labels from an EEG structure.
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
    params = processAnnotateParameters('powerFeatures', nargin, 1, params);
    
    %% Eliminate exclude channels
    chanlocs = EEG.chanlocs;
    excludedLabels = params.powerFeatureExcludedChannels;
    channelMask = false(length(chanlocs), 1);
    for k = 1:length(chanlocs)
        if ~isempty(excludedLabels) && ...
                sum(strcmpi(excludedLabels, chanlocs(k).labels)) > 0
            channelMask(k) = true;
        elseif params.powerFeatureExcludeNonLocatedChannels && ...
                isempty(chanlocs(k).X) && isempty(chanlocs(k).sph_theta) ...
                && isemtpy(chanlocs(k).radius)
            channelMask(k) = true;
        elseif params.powerFeatureExcludeNonEEGChannels && ...
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

    dataLength = size(EEGin.data, 2); 
    sRate = EEGin.srate;   
    subLengthFrame = round(sRate*config.powerFeatureSubWindowLength); 
    stepFrame = round(sRate*config.powerFeatureWindowStep);           
    featureSubj = [];
    pBands = config.powerFeatureSubbands;
    for m = 1:size(pBands, 1) % for each sub-band      
        subEEG = pop_eegfiltnew(EEGin, pBands(m, 1), pBands(m, 2));  
        data = zscore(subEEG.data, 0, 2);
        data = data .^ 2;   % power data = amplitude ^ 2
        
        featureBand = [];
        windBegin = 1;
        windEnd = windBegin + subLengthFrame - 1;
        while windEnd <= dataLength     % update to include the last frame
            windFeature = mean(data(:, windBegin:windEnd), 2); % [64x1]
            featureBand = cat(2, featureBand, windFeature);
            windBegin = windBegin + stepFrame;
            windEnd = windBegin + subLengthFrame - 1;
        end
        featureSubj = cat(1, featureSubj, featureBand);
    end    
    
    subWindowNumb = round(config.powerFeatureWindowLength / config.powerFeatureSubWindowLength);
    features = repmat(featureSubj, subWindowNumb, 1);

    dimension = size(featureSubj, 1);			% average Power for biosemi 64 channels, 8 sub-bands, 8 sub-windwos ==> (512)
    for b= 2:size(config.powerFeatureSubbands, 1)
        bandBegin = (b-1)*dimension+1;
        bandEnd = b*dimension;
        copyOffset = b-1;
        features(bandBegin:bandEnd, 1:end-copyOffset) = ...
                              features(bandBegin:bandEnd, 1+copyOffset:end);
    end
    
    eventLabelString = getEventLabelInString(EEGin.event);       
    
    eventLatencySecond = [EEGin.event.latency]' ./ sRate;            
    eventIndex = floor(eventLatencySecond ./ config.powerFeatureWindowStep) + 1;          
    
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
    features = features(:, 1:end-8);
    labels = labels(1:end-8)';
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
