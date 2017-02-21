%% This script shows how to plot metrics and significance
inDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSimb_Annotation';
outDir = 'D:\Papers\Current\Annotation\Resubmission\figures\cutoffPlots\Resized';
classes = {'34', '35'};
%outDir = [];
subjectsGood = [2, 4, 5, 8, 9, 11, 18]';
subjectsMedium = [1, 3, 7, 10, 10, 15, 16]';
subjectsPoor = [6, 12, 14, 17]';

%% Load the file

for n = 1:length(classes)
    annotPaths = getFiles('FILES', [inDir '_' classes{n}], '.mat');
    for k = [1, 9, 14]%1:length(annotPaths)
        [~, theName, ~] = fileparts(annotPaths{k});
        thisOne = load(annotPaths{k});
        scores = thisOne.annotData.wmScores;
        cutoff = thisOne.annotData.combinedCutoff;
        scores(scores == 0) = [];
        [cutoffTest, mu1, sigma1, mu2, sigma2, xgrid] = getCutoffFL(scores, 30.0, 0.0);
        if cutoff ~= cutoffTest
            warning('%d: %s calculated cutoff is not the same as read', k, theName);
        end
        [peakX, peakY, peakBin, counts, binPos] = getLargestPeak(scores);
        yMain = pdf('Normal', binPos, mu1, sigma1);
        yMainScaled = yMain * peakY / max(yMain);
        leftOvers = counts(:) - yMainScaled(:);
        leftOvers(leftOvers < 0) = 0;
        peakPos = max(leftOvers);
        yPos = pdf('Normal', binPos, mu2, sigma2);
        yPosScaled = yPos * peakPos / max(yPos);
        fitError = sum(abs(counts(:) - yMainScaled(:) - yPosScaled(:)))/sum(counts);
        fprintf('%d: %s  fit error %g\n', k, theName, fitError);
        %%
      
        theTitle = [theName ' cutoffs'];
        figh = figure('Name', theTitle);
        hold on
        plot(binPos(:), counts(:), 'Color', [0.8, 0.8, 0.8], 'LineWidth', 4);
        plot(binPos(:), yMainScaled(:), 'Color', [0.6, 0.6, 0.6], 'LineWidth', 2);
        plot(binPos(:), yPosScaled(:), 'r', 'LineWidth', 2);
        plot(binPos(:), leftOvers(:), 'k');
        ylimits = get(gca, 'YLim');
        line([cutoff, cutoff], ylimits, 'LineStyle', '-.', ...
             'Color', [0, 0, 0], 'LineWidth', 1);
        legend('All', 'Negative', 'Positive', 'Leftovers', 'Cutoff', ...
               'Location', 'southoutside', 'Orientation', 'Horizontal')
        ylabel('Count')
        xlabel('Score')
        hold off
        title(theTitle, 'Interpreter', 'None');
        box on
        if ~isempty(outDir)
            fileName = [outDir filesep 'cutoffPlot_' theName '_' classes{n}];
            saveas(figh, [fileName '.fig'], 'fig');
            saveas(figh, [fileName '.eps'], 'eps');
            saveas(figh, [fileName '.pdf'], 'pdf');
            saveas(figh, [fileName '.png'], 'png');
        end
        %close all;
    end
end