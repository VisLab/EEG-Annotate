%% This script shows how to calculate and plot pairwise accuracy
% The baseClassifier is plotted against the others
%
%% Set up the directories, colors and shapes colors
inBase = 'D:\Research\Annotate\Kay\Data2\VEP_PREP_ICA_VEP2_MARA_averagePower';
outDir = 'D:\Papers\Current\Annotation\Resubmission\figures\pairwiseAccuracy';
targetClasses = {'34', '35'};
targetClassNames = {'Friend', 'Foe'};
baseClassifier = 'ARRLSMod';
otherClassifiers = {'ARRLSimb', 'LDA'};
otherShapes = {'o', 's'};
otherColors = [0, 0, 0; 0.75, 0.75, 0.75];
plotRange = [0, 1];
%% Make the output directory
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Plot the pairwise accuracies for other classifiers vs base classifier
for n = 1:length(targetClasses)
    basePath = [inBase '_' baseClassifier '_' targetClasses{n}];
    baseFiles = getFiles('FILES', basePath, '.mat');
    baseAccuracy = getPairwiseAccuracy(baseFiles, targetClasses{n});
    baseAccuracy = baseAccuracy(:);
    baseAccuracy(baseAccuracy == -1) = [];
    otherAccuracies = cell(length(otherClassifiers), 1);
    legendMask = true(1, length(otherClassifiers));
    theTitle = ['Pairwise accuracies for ' targetClassNames{n}];
    fH = figure('Name', theTitle);
    hold on
    for m = 1:length(otherClassifiers)
       otherPath = [inBase '_' otherClassifiers{m} '_' targetClasses{n}];
       otherFiles = getFiles('FILES', otherPath, '.mat');
       otherAccuracy = getPairwiseAccuracy(otherFiles, targetClasses{n}); 
       otherAccuracy = otherAccuracy(:);
       otherAccuracy(otherAccuracy == -1) = [];
       if length(baseAccuracy) ~= length(otherAccuracy)
           warning('Classifier %s accuracies do not match base classifer');
           legendMask(m) = false;
           continue;
       end
       scatter(baseAccuracy, otherAccuracy, 72, otherShapes{m}, ...
              'MarkerEdgeColor', otherColors(m, :));
    end 
    box on;
    line(plotRange, plotRange, 'Color', 'k', 'LineStyle', ':');
    xlim(plotRange);
    ylim(plotRange);
    xlabel([baseClassifier ' accuracy']);
    ylabel('Other accuracy');
    legend(otherClassifiers(legendMask), 'Location', 'southeast');
    title(theTitle);
    axis square;
    hold off
%     fprintf('avearge (std), LDA, %.1f (%.2f), ARTL, %.1f (%.2f), ARTLimb, %.1f (%.2f)\n', mean(accuracy_LDA)*100, std(accuracy_LDA)*100, mean(accuracy_ARRLS)*100, std(accuracy_ARRLS)*100, mean(accuracy_ARRLSimb)*100, std(accuracy_ARRLSimb)*100);
%     
%     fprintf('ARTL > LDA?\n');
%     [h, p, ci, stats] = ttest(accuracy_ARRLS, accuracy_LDA, 'Alpha', 0.001, 'Tail', 'right') % one-sided t-test (ARTL > LDA?)
%     
%     fprintf('ARTLimb > LDA?\n');
%     [h, p, ci, stats] = ttest(accuracy_ARRLSimb, accuracy_LDA, 'Alpha', 0.001, 'Tail', 'right') % one-sided t-test (ARTL > LDA?)
%     
%     fprintf('ARTLimb > ARTL?\n');
%     [h, p, ci, stats] = ttest(accuracy_ARRLSimb, accuracy_ARRLS, 'Alpha', 0.001, 'Tail', 'right') % one-sided t-test (ARTL > LDA?)
%     
%     fileName = ['pairwise_' num2str(mean(accuracy_LDA)*100, '%.2f') '_' num2str(mean(accuracy_ARRLS)*100, '%.2f') '_' num2str(mean(accuracy_ARRLSimb)*100, '%.2f') '_target_' targetClass];
%     saveas(fH, [outPath filesep fileName '.fig'], 'fig');
%     img = getframe(fH);
%     imwrite(img.cdata, [outPath filesep fileName '.png']);
end

