%% plot 
%
function sureCount = plot_pred_labelsScoreOverlap_n_true_events_marking(predLabels, predScores, trueLabels, excludeIdx, outPath, titleStr)    

    allPredLabels = get_pred_labelsScoreOverlap(predLabels, predScores, excludeIdx);
    
    yTickLabels = {'Test set'};
    for i = 1:length(predLabels)
        yTickLabels{i+1} = [num2str(i, '%02d') ' (' num2str(sum(allPredLabels(i, :)), '%04d') ')' ];
    end

    % if the samples in 0.5 second periods are detected by all classifiers, highlight them with red color.
    sureCount = 0;
    for i = 3:size(allPredLabels, 2)-2
        if sum(sum(allPredLabels(:, i-2:i+2))) >= size(allPredLabels, 1)
            labelTemp = allPredLabels(:, i-2:i+2);
            labelTemp(labelTemp == 1) = 0.75;
            allPredLabels(:, i-2:i+2) = labelTemp;
            sureCount = sureCount + 1;
        end
    end
    
    binTrueLabel = zeros(1, length(trueLabels));
    for i = 1:length(trueLabels)
        if ~isempty(trueLabels{i})
            if strcmp(trueLabels{i}, 'boundary')
                binTrueLabel(i) = 0.25; % boundary event
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
    map = [1 1 1              % white
          0.00 0.85 1.00     % 0.25: light blue 
          0.6 0.6 0.6          % 0.5: grey
          1.0 0 0            % 0.75: red
          0 0 0];            % black
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
        title([titleStr ' (' num2str(beginF) ' - ' num2str(endF) ' of ' num2str(length(trueLabels)) ' samples) (Sure: ' num2str(sureCount) ', ' num2str(sureCount*100/length(trueLabels), '%.2f') '%)']);
        img = getframe(gcf);
        imwrite(img.cdata, [outPath filesep 'sample_' num2str(beginF, '%05d') '_' num2str(endF, '%05d') '.png']);
        beginF = beginF + 500;
    end
end

