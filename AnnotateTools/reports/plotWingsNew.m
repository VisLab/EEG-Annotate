function figh = plotWingsNew(annotData, outPath, params)
%% Generate plots showing the true events around the detected samples
%
%  Parameters:
%       inPat: the path to the annotation scores
%       outPath: the path to the place where the generated plots is saved
%
%% Setup the parameters and reporting for the call
    params = processAnnotateParameters('plotWings', nargin, 2, params);
    plotSize = params.wingPlotSize;
    subwindowPlotOffset = round((plotSize - 1)/2);
    
    %% Set up the parameters for the plot
    [~, theName, ~] = fileparts(annotData.testFileName);
    theTitle = [theName ': classifier=' annotData.classifier ...
               ' class= ' annotData.classLabel];
    cmap = [1.0, 0.0, 0.0       % red1:  'Foe w/ CR'
         %   1.0, 0.7, 0.4       % red2 (orange):  'Foe w/ IR'
        %1.0, 0.4, 1.0       % red3 (pink):  'Foe w/ NR'
        0.2, 0.3, 1.0       % blue1: 'Friend w/ CR'
        0.0, 0.9, 1.0       % blue2: 'Friend w/ IR'
        %0.5, 0.5, 1.0       % blue3: 'Friend w/ NR'
        0.0, 0.0, 0.0       % black: false positive (peak, but no event around there)
        1.0, 1.0 1.0];      % white:  background, low (or 0) score
    colorbarTickLabels = { ...
        '3C<=W', ...   % 1
        '2C<=W<3C', ...   % 1
        'C<=W<2C', ...  %'Friend w/ IR', ...     % 5%'Friend w/ NR', ...     % 6
        '0<=W<C', ...
        'Low score'};     % 6    ==> zero-out score 
    lowScore = length(colorbarTickLabels);
    xTickLabel = cell(plotSize, 1);
    for n = 1:2:plotSize
        xTickLabel{n} = num2str(n - subwindowPlotOffset - 1);
    end
    
    %% go over all files and preprocess them using the specified function
    plotLabels = ones(size(annotData.wmScores)) * lowScore;  
    centerMask = annotData.wmScores > params.wingBaseThreshold;
    cutoffMask = annotData.wmScores > annotData.combinedCutoff;
    cutoffMask2 = annotData.wmScores > 2*annotData.combinedCutoff;
    cutoffMask3 = annotData.wmScores > 3*annotData.combinedCutoff;
    plotLabels(centerMask) = lowScore - 1;
    plotLabels(cutoffMask) = lowScore - 2;
    plotLabels(cutoffMask2) = lowScore - 3;
    plotLabels(cutoffMask3) = lowScore - 4;
    centerIndex = find(centerMask);    
    plotData = generatePlotData(plotLabels, centerIndex);
    wmData = annotData.wmScores(centerMask);
    wmData = wmData(:);
    sortCols = -1;
        
    [~, sIdx] = sortrows(wmData, sortCols);
    sortData = plotData(sIdx, :);
    
    figh = figure;
    imagesc(sortData, [1 size(cmap, 1)]);
    colormap(cmap);
%     if isfield(annotData, 'combinedCutoff')
%         numbPositives = sum(annotData.wmScores > annotData.combinedCutoff);
%         hold on
%         plot([0 size(sortData, 2)], [numbPositives+1 numbPositives+1], 'k:', 'LineWidth', 3)
%         hold off
%     end
    
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
%     centerData = sortData(:, subwindowPlotOffset+1);
%     CRa = sum(centerData==1);
%     IRa = sum(centerData==2);
%     NRa = sum(centerData==3);
%     CRb = sum(centerData==4);
%     IRb = sum(centerData==5);
%     NRb = sum(centerData==6);
%     NoEvent = sum(centerData==7);
%     LowScore = sum(centerData==8);
%     fprintf('Predicted positives %s:\n', theName);
%     fprintf('   CRa=%d, IRa=%d, NRa=%d, CRb=%d, IRb=%d, NRb=%d\n', ...
%             CRa, IRa, NRa, CRb, IRb, NRb);
%     fprintf('   No event=%d, Low score=%d, Fraction foe=%.2f, Fraction friend=%.2f\n', ...
%          NoEvent, LowScore, sum(CRa+IRa+NRa)/length(centerData), sum(CRb+IRb+NRb)/length(centerData));
%     numbPositives = sum(annotData.wmScores > annotData.combinedCutoff);
%     centerData = sortData(1:numbPositives, subwindowPlotOffset + 1);
%     CRa = sum(centerData==1);
%     IRa = sum(centerData==2);
%     NRa = sum(centerData==3);
%     CRb = sum(centerData==4);
%     IRb = sum(centerData==5);
%     NRb = sum(centerData==6);
%     NoEvent = sum(centerData==7);
%     LowScore = sum(centerData==8);
%     fprintf('Predicted positives above the cutoff %s: \n', theName);
%     fprintf('   CRa=%d, IRa=%d, NRa=%d, CRb=%d, IRb=%d, NRb=%d\n', ...
%             CRa, IRa, NRa, CRb, IRb, NRb);
%     fprintf('   No event=%d, Low score=%d, Fraction foe=%.2f, Fraction friend=%.2f\n', ...
%          NoEvent, LowScore, sum(CRa+IRa+NRa)/length(centerData), sum(CRb+IRb+NRb)/length(centerData));
    
%     function plotData = generatePlotDataTrueWings(plotLabels, centerIndex, timingTolerances)
%     % initial values is 8 (Low score)
%         plotData = ones(length(centerIndex), plotSize)*8;     
%         for i = 1:length(centerIndex)
%             [bIn, idx] = isInRange2(plotLabels, centerIndex(i), 8, timingTolerances);
%             if bIn
%                 plotData(i, :) = copyLabels(plotLabels, idx);
%             else
%                 plotData(i, :) = copyLabels(plotLabels, centerIndex(i));
%                 plotData(i, subwindowPlotOffset + 1) = 7;     % no event
%             end
%         end
%     end

   function plotData = generatePlotData(plotLabels, centerIndex)
    % initial values is 8 (Low score)
        plotData = ones(length(centerIndex), plotSize)*lowScore;     
        for i = 1:length(centerIndex)
                plotData(i, :) = copyLabels(plotLabels, centerIndex(i));
        end
    end

    function newData = copyLabels(data, idx)
        newData = ones(1, plotSize) * lowScore;    % one row vector    
        srcStart = max(1, idx - subwindowPlotOffset);
        srcEnd = min(length(data), idx + subwindowPlotOffset);   
        destStart = max(1, subwindowPlotOffset + 2 - idx);
        destEnd = min(length(newData), subwindowPlotOffset + 1 + length(data) - idx);   
        newData(destStart:destEnd) = data(srcStart:srcEnd);
    end

%     function [bIn, idx] = isInRange2(labels, curIdx, targetID, timingTolerances)
%     % if targetID is not exist in labels with the range (from -offLeft to +offRight of curIdx)
%         startIdx = max(1, curIdx - timingTolerances);
%         endIdx = min(length(labels), curIdx + timingTolerances);
%         idx = find(labels(startIdx:endIdx) ~= targetID);
%         if ~isempty(idx)
%             bIn = true;
%             idx = startIdx + idx(1) - 1;
%         else
%             bIn = false;
%             idx = curIdx;
%         end
%     end
% 
%     function plotLabels = convertTrue2Plot(trueLabels)
%      %% Convert the original labels to labels encoded by response type   
%         plotLabels = ones(size(trueLabels)) * 8;    % initial values is 8 (Low score)
%         for s = 1:length(trueLabels)
%             if ~isempty(trueLabels{s})
%                 for i = 1:length(trueLabels{s})
%                     if strcmp(trueLabels{s}{i}, '34')  % friend
%                         if isInRange(trueLabels, s, '38')  % inspect if there is correct response in 2 seconds
%                             plotLabels(s) = 4;
%                         elseif isInRange(trueLabels, s, '39')  % incorrect response in 2 second
%                             plotLabels(s) = 5;
%                         else    % no response
%                             plotLabels(s) = 6;
%                         end
%                     elseif strcmp(trueLabels{s}{i}, '35')  % foe
%                         if isInRange(trueLabels, s, '38')  % inspect if there is correct response in 2 seconds
%                             plotLabels(s) = 1;
%                         elseif isInRange(trueLabels, s, '39')  % incorrect response in 2 second
%                             plotLabels(s) = 2;
%                         else   % no response
%                             plotLabels(s) = 3;
%                         end
%                     end
%                 end
%             end
%         end
%     end

%     function [bIn, idx] = isInRange(labels, curIdx, targetID)
%    % if targetID is exist in labels with the range (from -offLeft to +offRight of curIdx)
%         startIdx = max(1, curIdx);
%         endIdx = min(length(labels), curIdx + subwindowPlotOffset);
% 
%         idx = [];
%         for s = startIdx:endIdx
%             if ~isempty(labels{s})
%                 for i=1:length(labels{s})
%                     if strcmp(labels{s}{i}, targetID)
%                         idx = cat(1, idx, s);
%                     end
%                 end
%             end
%         end
% 
%         if ~isempty(idx)
%             bIn = true;
%             idx = idx(1);
%         else
%             bIn = false;
%             idx = curIdx;
%         end
%     end

end    
    
