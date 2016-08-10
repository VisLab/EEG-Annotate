%% plot 
%
function plot_pred_labelsScoreOverlap_n_true_events(predLabels, predScores, trueLabels, excludeIdx, outPath, titleStr)    

    allPredLabels = zeros(length(predLabels), length(trueLabels));
    for i=1:length(predLabels)
        pred_temp1 = zeros(1, length(trueLabels));
        pred_temp1(excludeIdx==0) = predLabels{i};
        pred_temp2 = (predScores{i} > 0);
        allPredLabels(i, :) = (pred_temp1 & pred_temp2);
    end
    
    yTickLabels = {'Test set'};
    for i = 1:length(predLabels)
        yTickLabels{i+1} = [num2str(i, '%02d') ' (' num2str(sum(allPredLabels(i, :)), '%04d') ')' ];
    end

    binTrueLabel = zeros(1, length(trueLabels));
    for i = 1:length(trueLabels)
        if ~isempty(trueLabels{i})
            if strcmp(trueLabels{i}, 'boundary')
                binTrueLabel(i) = 0.5; % boundary event
            else
                binTrueLabel(i) = 1;   % true events
            end
        end
    end
    
    fH = figure(1);  clf;
    set(fH, 'Position', [50, 310, 1580, 420]);
    plotTemp = [binTrueLabel; allPredLabels];
    imagesc(plotTemp);
    axis xy;
    map = [1, 1, 1
          0.00, 0.85, 1.00     % light blue
          0, 0, 0];
    colormap(map);	
    set(gca, 'YTick', (1:size(plotTemp, 1)));     set(gca, 'YTickLabel', yTickLabels);
    xtickCount = floor(length(trueLabels) / 40);
    xticks = (1:xtickCount) * 40;
    xtickLabel = cell(xtickCount, 1);
    for x=1:xtickCount
        xtickLabel{x} = num2str(x*5);
    end
    set(gca, 'XTick', xticks);  set(gca, 'XTickLabel', xtickLabel);
    set(gca, 'Ticklength', [0 0]);
    xlabel('Seconds');     ylabel('Training Subjects (number of detected samples)');

    if ~isdir(outPath)
        mkdir(outPath);
    end

    beginF = 1; 
    while beginF < length(trueLabels)
        endF = beginF + 499;
        xlim([beginF-1 endF]);
        title([titleStr ' (' num2str(beginF) ' - ' num2str(endF) ' of ' num2str(length(trueLabels)) ' samples)']);
        img = getframe(gcf);
        imwrite(img.cdata, [outPath filesep 'sample_' num2str(beginF, '%05d') '_' num2str(endF, '%05d') '.png']);
        beginF = beginF + 500;
    end
end

