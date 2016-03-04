%% plot categories
%   - sorted by score
% 
%  events + backgroud : 
%
function plot_sortEvent_n_Score(scores, trueLabels, timingTolerance, detailHeight, tickLabels, cmap, offPast, offFuture, outPath, titleStr)    
    
    xticklabel = cell((offPast+offFuture+1), 1);
    for i=1:2:(offPast+offFuture+1)
        xticklabel{i} = num2str(i - offPast - 1);
    end
    
    eventNumb = length(tickLabels)-1;        
    
    switch eventNumb
        case 3
            plotLabels = convertTrue2Plot_BCIT_event3(trueLabels);
            colorbar_ticks = 1.4:(4.35-1.4)/4:4.35;
        case 5
            plotLabels = convertTrue2Plot_BCIT_event5(trueLabels);
            colorbar_ticks = 1.4:(6.5-1.4)/6:6.5;
        otherwise
            error('check the event number');
    end

    pickIdx = find(scores > 0);
    plotData = generatePlotData(plotLabels, pickIdx, offPast, offFuture, timingTolerance, eventNumb); 

    pickScores = scores(pickIdx);
    [~, sIdx] = sort(pickScores, 'descend');
    sortByScore = plotData(sIdx, :);
    
    eventLabels = sortByScore(:, offPast+1);
    [~, sIdx] = sort(eventLabels, 'ascend');
    sortByEvent_n_Score = sortByScore(sIdx, :);

    hf1 = figure(1); clf;
    imagesc(sortByEvent_n_Score, [1 length(tickLabels)]);
    colormap(cmap);

    colorbar('Ticks',colorbar_ticks,'TickLabels',tickLabels, 'Direction', 'reverse');
    set(gca, 'XTick', 1:(offPast+offFuture+1), 'XTickLabel', xticklabel);
    
    xlabel('Time (8 intervals / 1 second)');
    ylabel('Samples (sorted by scores)');
    title(titleStr);
    
    saveas(hf1, [outPath filesep 'plotWhole.fig']);
    img = getframe(hf1);
    imwrite(img.cdata, [outPath filesep 'plotWhole.png']);

    if detailHeight > 0  % plot details
        plotHeight = size(sortByEvent_n_Score, 1);
        plotHeight = max(plotHeight, detailHeight);
        plotNumb = floor(plotHeight / detailHeight);
        for p = 1:plotNumb
            plotBegin = (p-1)*detailHeight+1;
            plotEnd = plotBegin+detailHeight-1;

            hf1 = figure(1); clf;
            imagesc(sortByEvent_n_Score(plotBegin:plotEnd, :), [1 length(tickLabels)]);
            colormap(cmap);

            colorbar('Ticks',colorbar_ticks,'TickLabels',tickLabels, 'Direction', 'reverse');
            set(gca, 'XTick', 1:(offPast+offFuture+1), 'XTickLabel', xticklabel);
            set(gca, 'YTick', [1 detailHeight], 'YTickLabel', {num2str(plotBegin), num2str(plotEnd)});

            xlabel('Time (8 intervals / 1 second)');
            ylabel('Samples (sorted by scores)');
            title([titleStr ', detail ' num2str(p)]);
            
            saveas(hf1, [outPath filesep 'plotDetail' num2str(p) '.fig']);
            img = getframe(hf1);
            imwrite(img.cdata, [outPath filesep 'plotDetail' num2str(p) '.png']);
        end
    end
end

% if targetID is not exist in labels with the range (from -offLeft to +offRight of curIdx)
function [bIn, idx] = isInRange2(labels, curIdx, targetID, offLeft, offRight)

    startIdx = max(1, curIdx - offLeft);
    endIdx = min(length(labels), curIdx + offRight);
    idx = find(labels(startIdx:endIdx) ~= targetID);
    if ~isempty(idx)
        bIn = true;
        idx = startIdx + idx(1) - 1;
    else
        bIn = false;
        idx = curIdx;
    end
end

% if targetID is exist in labels with the range (from -offLeft to +offRight of curIdx)
function [bIn, idx] = isInRange(labels, curIdx, targetID, offLeft, offRight)

    startIdx = max(1, curIdx - offLeft);
    endIdx = min(length(labels), curIdx + offRight);
    idx = find(labels(startIdx:endIdx) == targetID);
    if ~isempty(idx)
        bIn = true;
        idx = startIdx + idx(1) - 1;
    else
        bIn = false;
        idx = curIdx;
    end
end

function plotLabels = convertTrue2Plot_BCIT_event3(trueLabels)

    plotLabels = ones(size(trueLabels)) * 4;    % initial values is 8 (Low score)
    
    for i=1:length(trueLabels)
        for j=1:length(trueLabels{i})
            tLabel = trueLabels{i}{j};
            if strcmp(tLabel, '1311') 
                plotLabels(i) = 2;  % Valid
            elseif (strcmp(tLabel, '1321') || strcmp(tLabel, '1331') || strcmp(tLabel, '1341') || strcmp(tLabel, '1351') || strcmp(tLabel, '1361'))  % foe
                plotLabels(i) = 1;  % not valid
            end
        end
    end
end

function plotLabels = convertTrue2Plot_BCIT_event5(trueLabels)

    plotLabels = ones(size(trueLabels)) * 6;    % initial values is 6 (Low score)
    
    for i=1:length(trueLabels)
        for j=1:length(trueLabels{i})
            tLabel = trueLabels{i}{j};
            if strcmp(tLabel, '1311') 
                plotLabels(i) = 1;  % Valid
            elseif (strcmp(tLabel, '1321') || strcmp(tLabel, '1331') || strcmp(tLabel, '1341') || strcmp(tLabel, '1351') || strcmp(tLabel, '1361'))  
                plotLabels(i) = 2;  % Not valid
            elseif strcmp(tLabel, '2110')
                plotLabels(i) = 3;  % Allow
            elseif strcmp(tLabel, '2120')
                plotLabels(i) = 4;  % Deny
            end
        end
    end
end

function plotData = generatePlotData(plotLabels, centerIndex, offPast, offFuture, timingTolerance, eventNumb)
    lowScore = eventNumb + 1;

    plotData = ones(length(centerIndex), (offPast+offFuture)+1) * lowScore;    % initial values is (Low score)
    
    for i=1:length(centerIndex)
        [bIn, idx] = isInRange2(plotLabels, centerIndex(i), lowScore, timingTolerance, timingTolerance);
        if bIn == true
            plotData(i, :) = copyLabels(plotLabels, idx,  offPast, offFuture, lowScore);
        else
            plotData(i, :) = copyLabels(plotLabels, centerIndex(i),  offPast, offFuture, lowScore);
            plotData(i, offPast+1) = lowScore-1;     % no event
        end
    end
end

function newData = copyLabels(data, idx,  offPast, offFuture, lowScore)
    newData = ones(1, offPast+offFuture+1) * lowScore;    % one row vector
    
    srcStart = max(1, idx - offPast);
    srcEnd = min(length(data), idx + offFuture);
    
    destStart = max(1, offPast + 2 - idx);
    destEnd = min(length(newData), offPast + 1 + length(data) - idx);
    
    newData(destStart:destEnd) = data(srcStart:srcEnd);
end

