function plot_prediction_n_true_events_cutOffPercent(scores, weights, position, trainName, testLabel, cutOffPercent, outPath)

    sampleNumb = length(scores{1});
    cutOffCount = round(sampleNumb * cutOffPercent / 100);
    fprintf('Each training subject annotates %d samples in %d samples\n', cutOffCount, sampleNumb);
    
    allOddBinary = zeros(length(trainName)+1, sampleNumb); % extra one to print out event codes
    for trainID = 1:length(trainName)
        theseScores = scores{trainID};
        % Make up a weighting and calculate weighted scores
        subWinScores = rescore2(theseScores, weights, position);
        % Use a greedy algorithm to take best scores
        zeroOutScore = maskScores2(subWinScores, position-1);  % zero out 15 elements
        [~, sIdx] = sort(zeroOutScore, 'descend');
        allOddBinary(trainID+1, sIdx(1:cutOffCount)) = 1;
    end

    yTickLabels = {'Test dataest'};
    for trainID = 1:length(trainName)
        yTickLabels{trainID+1} = ['(Train) ' trainName{trainID}(1:4)];
    end
    xtickCount = floor(sampleNumb / 40);
    xticks = (1:xtickCount) * 40;
    xtickLabel = cell(xtickCount, 1);
    for x=1:xtickCount
        xtickLabel{x} = num2str(x*5);
    end

    if ~exist('outPath', 'var')
        outPath = '.\figures';
    end
    if ~isdir(outPath)
        mkdir(outPath);
    end

    fH = figure(1); 
    set(fH, 'Position', [50, 310, 1580, 420]);
    map = [1, 1, 1
          0.00, 0.85, 1.00     % light blue
          0, 0, 0];
    colormap(map);	

    beginFrames = 1:500:1501; 
    for i=1:length(beginFrames)
        figure(fH);  clf;
        imagesc(allOddBinary);
        axis xy;
        set(gca, 'YTick', (1:length(trainName)+1));     
        set(gca, 'YTickLabel', yTickLabels);
        set(gca, 'TickLabelInterpreter', 'none');
        set(gca, 'XTick', xticks);  set(gca, 'XTickLabel', xtickLabel);
        set(gca, 'Ticklength', [0 0]);
        xlabel('Seconds');     ylabel('Subjects');

        beginF = beginFrames(i);
        endF = beginF + 499;
        xlim([beginF endF]);
        
        for f=beginF:endF
            if ~isempty(testLabel{f})
                for j=1:length(testLabel{f})
                    text(f, j, testLabel{f}{j});
                end
            end
        end
        
        img = getframe(gcf);
        imwrite(img.cdata, [outPath filesep 'cutPercent' num2str(cutOffPercent, '%.1f') '_range_' num2str(beginF) '_' num2str(endF) '.png']);
    end    
end
