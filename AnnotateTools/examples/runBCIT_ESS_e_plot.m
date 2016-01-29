%% plot annotated samples
% 

cutOffPercent = 1;
beginFrame = 1;
endFrame = 500;

classifierName = 'LDA'; % 'ARRLS'

%% path to raw scores (estimated by classifiers)
scoreWeightedIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_scoreWeighted';    % annotated samples
plotOut = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_plot';    

% testNames = {'X3 Baseline Guard Duty'; ...
%             'X4 Advanced Guard Duty'; ...
%             'Experiment X2 Traffic Complexity'; ...
%             'Experiment X6 Speed Control'; ...
%             'Experiment XB Baseline Driving'; 
%             'Experiment XC Calibration Driving'; ...
%             'X1 Baseline RSVP'; ...
%             'X2 RSVP Expertise'};
testNames = {'Experiment X2 Traffic Complexity'; ...
            'X3 Baseline Guard Duty'; ...
            'X4 Advanced Guard Duty'; ...
            'Experiment X2 Traffic Complexity'; ...
            'Experiment X6 Speed Control'};

for t=1:length(testNames)
    testName = testNames{t};
    plotEachOut = [plotOut filesep testName];
    
    if ~isdir(plotEachOut)   % if the directory is not exist
        mkdir(plotEachOut);  % make the new directory
    end

    load([scoreWeightedIn filesep testName '_ARRLS_scoreWeighted.mat']);  % load results
    % weightedScore = struct('trueLabel', [], 'excludeIdx', [], 'wScore', []);  

    %% go over all test sets and estimate scores
    testsetNumb = length(weightedScore.trueLabel);
    
    %weightedScore.trueLabel = cell(1, testsetNumb);
    %weightedScore.excludeIdx = cell(1, testsetNumb);
    %weightedScore.wScore = cell(18, testsetNumb);
    yTickLabels = {'Test dataest'};
    for trainID = 1:18
        yTickLabels{trainID+1} = ['(Train) ' num2str(trainID, '%02d')];
    end
    
    for testSubjID=1:testsetNumb
        sampleNumb = length(weightedScore.trueLabel{testSubjID});
        cutOffCount = round(sampleNumb * cutOffPercent / 100);
        fprintf('Each training subject annotates %d samples among %d samples\n', cutOffCount, sampleNumb);
    
        binaryScore = zeros(18+1, sampleNumb); % extra one to print out event codes
        wScore = weightedScore.wScore{testSubjID};
        for trainID = 1:18
            [~, sIdx] = sort(wScore(trainID, :), 'descend');
            binaryScore(trainID+1, sIdx(1:cutOffCount)) = 1;
        end

        xtickCount = floor(sampleNumb / 40);
        xticks = (1:xtickCount) * 40;
        xtickLabel = cell(xtickCount, 1);
        for x=1:xtickCount
            xtickLabel{x} = num2str(x*5);
        end

        fH = figure(1); 
        set(fH, 'Position', [50, 310, 1580, 420]);

        map = [1, 1, 1
              0.00, 0.85, 1.00     % light blue
              0, 0, 0];
        colormap(map);	

        figure(fH);  clf;
        imagesc(binaryScore);
        axis xy;
        set(gca, 'YTick', (1:18+1));     
        set(gca, 'YTickLabel', yTickLabels);
        set(gca, 'TickLabelInterpreter', 'none');
        set(gca, 'XTick', xticks);  set(gca, 'XTickLabel', xtickLabel);
        set(gca, 'Ticklength', [0 0]);
        xlabel('Seconds');     ylabel('Subjects');

        xlim([beginFrame endFrame]);

        trueLabel = weightedScore.trueLabel{testSubjID};
        for f=beginFrame:endFrame
            if ~isempty(trueLabel{f})
                for j=1:length(trueLabel{f})
                    text(f, j, trueLabel{f}{j});
                end
            end
        end

        fileName = ['plot_file' num2str(testSubjID, '%02d')];
        
        img = getframe(gcf);
        imwrite(img.cdata, [plotEachOut filesep fileName '_cutoffP' num2str(cutOffPercent, '%.1f') '_range_' num2str(beginFrame) '_' num2str(endFrame) '.png']);
    end
end
