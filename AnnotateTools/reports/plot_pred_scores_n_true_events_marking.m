%% plot 
%
function sureCount = plot_pred_scores_n_true_events_marking(predScores, trueLabels, outPath, titleStr)    

    allPredLabels = zeros(length(predScores), length(trueLabels));
    for i=1:length(predScores)
        allPredLabels(i, :) = (predScores{i} > 0);
    end
    
    yTickLabels = {'Test set'};
    for i = 1:length(predScores)
        yTickLabels{i+1} = [num2str(i, '%02d') ' (' num2str(sum(allPredLabels(i, :)), '%04d') ')' ];
    end

    % if the samples in 0.5 second periods are detected by all classifiers, highlight them with red color.
    [allPredLabels, sureIdx] = highLight_surePattern(allPredLabels, 2, 1.0, 0.75);
    sureCount = sum(sureIdx);	
	
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
%    map = [1, 1, 1
%          0.00, 0.85, 1.00     % light blue
%          0, 0, 0];
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
%        title([titleStr ' (' num2str(beginF) ' - ' num2str(endF) ' of ' num2str(length(trueLabels)) ' samples)']);
        img = getframe(gcf);
        imwrite(img.cdata, [outPath filesep 'sample_' num2str(beginF, '%05d') '_' num2str(endF, '%05d') '.png']);
        beginF = beginF + 500;
    end
end

