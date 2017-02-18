function figh = plotTrueInWings(annotData, outPath, params)
%% Generate plots showing the true events around the detected samples
%
%  Parameters:
%    annotData  annotData structure containing the results 
%               (must have trueLabels for this plot)
%
%  Optional name-value parameters:
%    'timingTolerance'    number of subwindows to consider a hit
%                            (default: 2, no tolerance: 0)
%    'outPath'            path directory for saving plots (not saved if not given)
%    'subwindowRange'     number of subwindows to show on either side of events
%    'baseThreshold'      lowest score to plot (default 0, all scores = -inf)
%
%  Return values:
%     figh       figure handle of the generated plot
%
%  Written by:
%     Kyung-Min Su, UTSA, 2016
%  Modified by:
%     Kay Robbins, UTSA, 2017
%
%% Setup the parameters and reporting for the call
    params = processAnnotateParameters('plotTrueInWings', nargin, 2, params);
    plotSize = params.wingPlotSize;
    subwindowPlotOffset = round((plotSize - 1)/2);
    rankCutoff = params.wingRankCutoff;
    %% Set up the parameters for the plot
    [~, theName, ~] = fileparts(annotData.testFileName);
    theTitle = [theName ': classifier=' annotData.classifier ...
               ' class= ' annotData.classLabel];
    cmap = [1.0, 0.0, 0.0       % red1:  'Foe w/ CR'
        1.0, 0.7, 0.4       % red2 (orange):  'Foe w/ IR'
        1.0, 0.4, 1.0       % red3 (pink):  'Foe w/ NR'
        0.2, 0.3, 1.0       % blue1: 'Friend w/ CR'
        0.0, 0.9, 1.0       % blue2: 'Friend w/ IR'
        0.5, 0.5, 1.0       % blue3: 'Friend w/ NR'
        0.0, 0.0, 0.0       % black: false positive (peak, but no event around there)
        1.0, 1.0 1.0];      % white:  background, low (or 0) score
    colorbarTickLabels = {'Foe w/ CR', ...          % 1
        'Foe w/ IR', ...        % 2
        'Foe w/ NR', ...        % 3
        'Friend w/ CR', ...     % 4
        'Friend w/ IR', ...     % 5
        'Friend w/ NR', ...     % 6
        'No event', ...   % 7
        'Low score'};           % 8    ==> zero-out score 
    
    xTickLabel = cell(plotSize, 1);
    for n = 1:2:plotSize
        xTickLabel{n} = num2str(n - subwindowPlotOffset - 1);
    end
    
    %% Create an image of the true events with labeled events aligned at 0. 
    trueLabels = annotData.trueLabels;
    plotLabels = convertTrue2Plot(trueLabels);
    centerIndex = find(annotData.wmScores > params.wingBaseThreshold);
    plotData = generatePlotData(plotLabels, centerIndex);
    wmData = annotData.wmScores(centerIndex);
    wmData = wmData(:);
    sortCols = -1;
    if isfield(annotData, 'rankCounts')
        rankedData = annotData.rankCounts;
        wmData = [wmData, rankedData(:)];
        sortCols = [-2, -1];
    end
   [~, sIdx] = sortrows(wmData, sortCols);
    sortData = plotData(sIdx, :);
    
    %% Create the figure from the image.
    figh = figure;
    imagesc(sortData, [1 size(cmap, 1)]);
    colormap(cmap);
    if isfield(annotData, 'combinedCutoff')
        numbPositives = sum(annotData.wmScores > annotData.combinedCutoff);
        hold on
        plot([0 size(sortData, 2)], [numbPositives+1 numbPositives+1], 'k:', 'LineWidth', 3)
        hold off
    end
    if isfield(annotData, 'rankCounts')
        sampleIndex = annotData.sampleIndex;
        tempMask = false(size(annotData.wmScores));
        rankedHighIndex = sampleIndex(annotData.rankCounts > rankCutoff);
        rankedHighMask = tempMask;
        rankedHighMask(rankedHighIndex) = true;
        numbRankedPositives = sum(annotData.wmScores > annotData.combinedCutoff & rankedHighMask);
        hold on
        plot([0 size(sortData, 2)], [numbRankedPositives+1 numbRankedPositives+1], ...
              'k--', 'LineWidth', 3)
        hold off
    end  
    colorbar('Ticks', 1.5:(8.5-1.5)/8:8.5, 'TickLabels', colorbarTickLabels, ...
             'Direction', 'reverse');   
    set(gca, 'XTick', 1:plotSize, 'XTickLabel', xTickLabel);  
    xlabel('Time (8 intervals / 1 second)');
    ylabel('Samples (sorted by scores)');
    title(theTitle, 'Interpreter', 'none');
    
    %% Save the figure if requested
    if ~isempty(outPath)
        fileName = [theName '_' annotData.classifier '_' annotData.classLabel];
        saveas(figh, [outPath filesep fileName '.fig']);
        img = getframe(figh);
        imwrite(img.cdata, [outPath filesep fileName '.png']);
    end
    
    %% Now output the predictions
    centerData = sortData(:, subwindowPlotOffset + 1);
    CRa = sum(centerData==1);
    IRa = sum(centerData==2);
    NRa = sum(centerData==3);
    CRb = sum(centerData==4);
    IRb = sum(centerData==5);
    NRb = sum(centerData==6);
    NoEvent = sum(centerData==7);
    LowScore = sum(centerData==8);
    if params.verbose
        fprintf('(Breakdown of predicted positives) %s: %d, %d, %d, %d, %d, %d, %d, %d, %.2f, %.2f\n', ...
        theName, ...
        CRa, IRa, NRa, CRb, IRb, NRb, NoEvent, LowScore, ...
        sum(CRa+IRa+NRa)/length(centerData), sum(CRb+IRb+NRb)/length(centerData));
    end
    numbPositives = sum(annotData.wmScores > annotData.combinedCutoff);
    centerData = sortData(1:numbPositives, subwindowPlotOffset + 1);
    CRa = sum(centerData==1);
    IRa = sum(centerData==2);
    NRa = sum(centerData==3);
    CRb = sum(centerData==4);
    IRb = sum(centerData==5);
    NRb = sum(centerData==6);
    NoEvent = sum(centerData==7);
    LowScore = sum(centerData==8);
    fprintf('(Breakdown above the cutoff) %s: , %d, %d, %d, %d, %d, %d, %d, %d, %.2f, %.2f\n', ...
        theName, ...
        CRa, IRa, NRa, CRb, IRb, NRb, NoEvent, LowScore, ...
        sum(CRa+IRa+NRa)/length(centerData), sum(CRb+IRb+NRb)/length(centerData));
    
    %% Internal functions now follow
    
    function plotData = generatePlotData(plotLabels, centerIndex)
    %% Generate an image of labeled events aligned at 0.
    plotData = ones(length(centerIndex), plotSize)*8;     
        for i=1:length(centerIndex)
            [bIn, idx] = isInRange2(plotLabels, centerIndex(i), 8);
            if bIn
                plotData(i, :) = copyLabels(plotLabels, idx);
            else
                plotData(i, :) = copyLabels(plotLabels, centerIndex(i));
                plotData(i, subwindowPlotOffset + 1) = 7;     % no event
            end
        end
    end

    function newData = copyLabels(data, idx)
        %% Copy the actual labels around idx into a row of plotsize values
        newData = ones(1, plotSize) * 8;    % one row vector    
        srcStart = max(1, idx - subwindowPlotOffset);
        srcEnd = min(length(data), idx + subwindowPlotOffset);   
        destStart = max(1, subwindowPlotOffset + 2 - idx);
        destEnd = min(length(newData), subwindowPlotOffset + 1 + length(data) - idx);   
        newData(destStart:destEnd) = data(srcStart:srcEnd);
    end

    function [bIn, idx] = isInRange2(labels, curIdx, targetID)
    % If a non-targetID value is within timingTolerance count as hit and mark 
        startIdx = max(1, curIdx - params.wingSubwindowTolerance);
        endIdx = min(length(labels), curIdx + params.wingSubwindowTolerance);
        theIndices = startIdx:endIdx;
        idx = find(labels(theIndices) ~= targetID);
        if ~isempty(idx)
            bIn = true;
            idx = theIndices(idx);
        else
            bIn = false;
            idx = curIdx;
        end
    end

    function plotLabels = convertTrue2Plot(trueLabels)
     %% Convert the original labels to labels encoded by response type   
        plotLabels = ones(size(trueLabels)) * 8;    % initial values is 8 (Low score)
        for s = 1:length(trueLabels)
            if ~isempty(trueLabels{s})
                for i = 1:length(trueLabels{s})
                    if strcmp(trueLabels{s}{i}, '34')  % friend
                        if isInRange(trueLabels, s, '38')  % inspect if there is correct response in 2 seconds
                            plotLabels(s) = 4;
                        elseif isInRange(trueLabels, s, '39')  % incorrect response in 2 second
                            plotLabels(s) = 5;
                        else    % no response
                            plotLabels(s) = 6;
                        end
                    elseif strcmp(trueLabels{s}{i}, '35')  % foe
                        if isInRange(trueLabels, s, '38')  % inspect if there is correct response in 2 seconds
                            plotLabels(s) = 1;
                        elseif isInRange(trueLabels, s, '39')  % incorrect response in 2 second
                            plotLabels(s) = 2;
                        else   % no response
                            plotLabels(s) = 3;
                        end
                    end
                end
            end
        end
    end

    function [bIn, idx] = isInRange(labels, curIdx, targetID)
    %% See if there is a response subwindowOffset subwindows after stimulus event
        startIdx = max(1, curIdx);
        endIdx = min(length(labels), curIdx + subwindowPlotOffset);
        bIn = false;
        idx = curIdx;
        for s = startIdx:endIdx
            if ~isempty(labels{s})
                for i = 1:length(labels{s})
                    if strcmp(labels{s}{i}, targetID)
                        bIn = true;
                        idx = s;
                        return;
                    end
                end
            end
        end
    end
end    
    
