%% extract feature: average power in a window
%  (apply sub-bands and sub-windows)
%
%  parameters:
%   EEGin: EEG data (in EEGLAB structure)
%   subbands: frequency ranges of each band
%   filterOrder to define the width of transition bands
%   windowLength: the length of a window (in second)
%   subLength: the length of sub-window (in second)
%   subStep: the gap between sub-windows (in second)
%
%  output:
%   samples: [4096 x n], n is sample number
%   labels: [n x 1] cell
%
function features = averagePower(EEG, varargin)


end

function [sampleOut, labelOut] = averagePower(EEGin, subbands, filterOrder, windowLength, subLength, subStep)

    dataLength = size(EEGin.data, 2); 
    sRate = EEGin.srate;
    
    subLengthFrame = round(sRate*subLength);
    subStepFrame = round(sRate*subStep);

    featureSubj = [];
    
    for m=1:size(subbands, 1) % for each sub-band
        subEEG = pop_eegfiltnew(EEGin, subbands(m, 1), subbands(m, 2), filterOrder); 
        
        data = subEEG.data;    % amplitude data
        % z-normalize so that it has zero-mean and unit std.
        % Becasue all channels has unit std, the different patterns in channel scales between subjects are reduced.
        data = (data - repmat(mean(data, 2), 1, size(data, 2))) ./ repmat(std(data, 0, 2), 1, size(data, 2));   
        data = data .^ 2;   % power data = amplitude ^ 2
        
        featureBand = [];
        windBegin = 1;
        windEnd = windBegin + subLengthFrame - 1;
        while windEnd < dataLength
            windFeature = mean(data(:, windBegin:windEnd), 2); % [64x1]
            featureBand = cat(2, featureBand, windFeature);
            windBegin = windBegin + subStepFrame;
            windEnd = windBegin + subLengthFrame - 1;
        end
        featureSubj = cat(1, featureSubj, featureBand);
    end    
    
    subWindowNumb = windowLength / subLength;
    samples = repmat(featureSubj, subWindowNumb, 1);

    dimension = size(featureSubj, 1);			% BOW (800), Power (512)
    for b=2:(size(subbands, 1)-1)
        bandBegin = (b-1)*dimension+1;
        bandEnd = b*dimension;
        copyOffset = b-1;
        samples(bandBegin:bandEnd, 1:end-copyOffset) = samples(bandBegin:bandEnd, 1+copyOffset:end);
    end
    
    eventLabelString = getEventLabelInString(EEGin.event);            % event label in string format
    
    eventLatencySecond = [EEGin.event.latency]' ./ sRate;             % event.latency (in pnts) ==> seconds, note that sometimes the latency has decimal fraction.
    eventIndex = floor(eventLatencySecond ./ subStep) + 1;            % seconds ==> sub-window index
    
    labels = cell(size(samples, 2), 1);    % new label for samples
	for i=1:length(eventLabelString)
        if eventIndex(i) < length(labels)  
            if isempty(labels{eventIndex(i)})
                labels{eventIndex(i)} = eventLabelString(i);
            else
                labels{eventIndex(i)} = [labels{eventIndex(i)} eventLabelString(i)];       % if one sample has more than one events.
            end
        end
	end
    
    sampleOut = samples(:, 1:end-7);
    labelOut = labels(1:end-7);
end

function label = getEventLabelInString(event)

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