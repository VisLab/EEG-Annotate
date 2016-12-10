%% Generate reports using the recall metric
%  Parameters:
%       inPat: the pash to the annotation scores
%       outPath: the path to the place where the generated report is saved
%
function outPath = batch_plot_true_in_wing(inPath, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    timingTolerances = 0:7;
    if isfield(params, 'timingTolerances')
        timingTolerances = params.timingTolerances;
    end
    offPast = 16;  %    2 seconds
    if isfield(params, 'offPast')
        offPast = params.offPast;
    end
    offFuture = 16;  %    2 seconds
    if isfield(params, 'offFuture')
        offFuture = params.offFuture;
    end
    titleStr = 'true_in_wing';
    if isfield(params, 'titleStr')
        titleStr = params.titleStr;
    end

    cmap = [1.0, 0.0, 0.0       % red1:  'Foe w/ CR'
            1.0, 0.7, 0.4       % red2 (orange):  'Foe w/ IR'  
            1.0, 0.4, 1.0       % red3 (pink):  'Foe w/ NR' 
            0.2, 0.3, 1.0       % blue1: 'Friend w/ CR'  
            0.0, 0.9, 1.0       % blue2: 'Friend w/ IR'   
            0.5, 0.5, 1.0       % blue3: 'Friend w/ NR' 
            0.0, 0.0, 0.0       % black: false positive (peak, but no event around there)  
            1.0, 1.0 1.0];      % white:  background, low (or 0) score 
    tickLabels = {'Foe w/ CR', ...          % 1
                    'Foe w/ IR', ...        % 2
                    'Foe w/ NR', ...        % 3
                    'Friend w/ CR', ...     % 4
                    'Friend w/ IR', ...     % 5
                    'Friend w/ NR', ...     % 6
                    'No event', ...   % 7
                    'Low score'};           % 8    ==> zero-out score
   
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end
    
    xticklabel = cell((offPast+offFuture+1), 1);
    for i=1:2:(offPast+offFuture+1)
        xticklabel{i} = num2str(i - offPast - 1);
    end
    
    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);
    
    % go over all test sets
    testsetNumb = length(fileList);
    
    for testSubjID=1:testsetNumb
        load([inPath filesep fileList(testSubjID).name]); % load annotData
        
        trueLabel = annotData.testLabel;
        
        plotLabels = convertTrue2Plot(trueLabel);

        centerIndex = find(annotData.combinedScore > 0);
        
        plotData = generatePlotData(plotLabels, centerIndex, offPast, offFuture, timingTolerances); 
        
		[~, sIdx] = sort(annotData.combinedScore(centerIndex), 'descend');
        sortData = plotData(sIdx, :);
        
        hf1 = figure(1); clf;
        imagesc(sortData, [1 length(tickLabels)]);
        colormap(cmap);
        
        colorbar('Ticks',1.5:(8.5-1.5)/8:8.5,'TickLabels',tickLabels, 'Direction', 'reverse');
        
        set(gca, 'XTick', 1:(offPast+offFuture+1), 'XTickLabel', xticklabel);
        xlim([14 52]);
        xlabel('Time (8 intervals / 1 second)');
        ylabel('Samples (sorted by scores)');
        title(['Subject ' num2str(testSubjID) ', ' titleStr], 'Interpreter', 'none');
        img = getframe(hf1);
        imwrite(img.cdata, [outPath filesep ['testSubject' num2str(testSubjID, '%02d') '_' titleStr '.png']]);
    end
end    

function plotData = generatePlotData(plotLabels, centerIndex, offPast, offFuture, timingTolerances)

    plotData = ones(length(centerIndex), (offPast+offFuture)+1) * 8;    % initial values is 8 (Low score)
    
    for i=1:length(centerIndex)
        [bIn, idx] = isInRange2(plotLabels, centerIndex(i), 8, timingTolerances);
        if bIn == true
            plotData(i, :) = copyLabels(plotLabels, idx,  offPast, offFuture);
        else
            plotData(i, :) = copyLabels(plotLabels, centerIndex(i),  offPast, offFuture);
            plotData(i, offPast+1) = 7;     % no event
        end
    end
end

function newData = copyLabels(data, idx,  offPast, offFuture)
    newData = ones(1, offPast+offFuture+1) * 8;    % one row vector
    
    srcStart = max(1, idx - offPast);
    srcEnd = min(length(data), idx + offFuture);
    
    destStart = max(1, offPast + 2 - idx);
    destEnd = min(length(newData), offPast + 1 + length(data) - idx);
    
    newData(destStart:destEnd) = data(srcStart:srcEnd);
end

% if targetID is not exist in labels with the range (from -offLeft to +offRight of curIdx)
function [bIn, idx] = isInRange2(labels, curIdx, targetID, timingTolerances)

    startIdx = max(1, curIdx - timingTolerances);
    endIdx = min(length(labels), curIdx + timingTolerances);
    idx = find(labels(startIdx:endIdx) ~= targetID);
    if ~isempty(idx)
        bIn = true;
        idx = startIdx + idx(1) - 1;
    else
        bIn = false;
        idx = curIdx;
    end
end

function plotLabels = convertTrue2Plot(trueLabels)

    plotLabels = ones(size(trueLabels)) * 8;    % initial values is 8 (Low score)
    
    for s=1:length(trueLabels)
        if ~isempty(trueLabels{s})
            for i=1:length(trueLabels{s})
                if strcmp(trueLabels{s}{i}, '34')  % friend
                    if isInRange(trueLabels, s, '38', 0, 16)  % inspect if there is correct response in 2 seconds
                        plotLabels(s) = 4;
                    elseif isInRange(trueLabels, s, '39', 0, 16)  % incorrect response in 2 second
                        plotLabels(s) = 5;
                    else    % no response
                        plotLabels(s) = 6;
                    end
                elseif strcmp(trueLabels{s}{i}, '35')  % foe
                    if isInRange(trueLabels, s, '38', 0, 16)  % inspect if there is correct response in 2 seconds
                        plotLabels(s) = 1;
                    elseif isInRange(trueLabels, s, '39', 0, 16)  % incorrect response in 2 second
                        plotLabels(s) = 2;
                    else   % no response
                        plotLabels(s) = 3;
                    end
                end
            end
        end
    end
end

% if targetID is exist in labels with the range (from -offLeft to +offRight of curIdx)
function [bIn, idx] = isInRange(labels, curIdx, targetID, offLeft, offRight)

    startIdx = max(1, curIdx - offLeft);
    endIdx = min(length(labels), curIdx + offRight);
    
    idx = [];
    for s=startIdx:endIdx
        if ~isempty(labels{s})
            for i=1:length(labels{s})
                if strcmp(labels{s}{i}, targetID)
                    idx = cat(1, idx, s);
                end
            end
        end
    end
    
    if ~isempty(idx)
        bIn = true;
        idx = idx(1);
    else
        bIn = false;
        idx = curIdx;
    end
end

    
    
