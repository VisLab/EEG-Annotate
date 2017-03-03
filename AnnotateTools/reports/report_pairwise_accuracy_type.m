%% Pairwise classification accuracy
%
% report_pairwise_accuracy_type('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_34', 'LDA', 'D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLorg_34', 'ARRLS', 'D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34', 'ARRLSimb', '34', '.\output\pair_type\friend', [0.3 1.0]);
% report_pairwise_accuracy_type('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_35', 'LDA', 'D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLorg_35', 'ARRLS', 'D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_35', 'ARRLSimb', '35', '.\output\pair_type\foe', [0.3 1.0]);
function report_pairwise_accuracy_type(inPath1, title1, inPath2, title2, inPath3, title3, targetClass, outPath, plotRange)

    accuracy_LDA = getBalancedAccuracy(inPath1, targetClass); % LDA
    accuracy_ARRLS = getBalancedAccuracy(inPath2, targetClass); % ARTLorg
    accuracy_ARRLSimb = getBalancedAccuracy(inPath3, targetClass); % ARTLimb
    
    save([outPath filesep 'accuracy_LDA.mat'], 'accuracy_LDA');
    save([outPath filesep 'accuracy_ARRLS.mat'], 'accuracy_ARRLS');
    save([outPath filesep 'accuracy_ARRLSimb.mat'], 'accuracy_ARRLSimb');
    
    accuracy_LDA = accuracy_LDA(:);
    accuracy_LDA(accuracy_LDA == -1) = [];
    accuracy_ARRLS = accuracy_ARRLS(:);
    accuracy_ARRLS(accuracy_ARRLS == -1) = [];
    accuracy_ARRLSimb = accuracy_ARRLSimb(:);
    accuracy_ARRLSimb(accuracy_ARRLSimb == -1) = [];
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end
    
    fH = figure(1); clf;
    scatter(accuracy_ARRLS, accuracy_LDA, 72, 'o', 'MarkerEdgeColor', [0.75 0.75 0.75]);
    hold on
    scatter(accuracy_ARRLS, accuracy_ARRLSimb, 72, 's', 'MarkerEdgeColor', 'k');
    hold off
    box on;
    line(plotRange, plotRange, 'Color', 'k', 'LineStyle', ':');
    xlim(plotRange);
    ylim(plotRange);
    xlabel([title2 ' accuracy']);
    ylabel(['(' title1 ', ' title3 ') accuracy']);
    legend(title1, title3, 'Location', 'southeast');
    title([title1 ': ' num2str(mean(accuracy_LDA), '%.3f') ', ' title2 ': ' num2str(mean(accuracy_ARRLS), '%.3f') ', ' title3 ': ' num2str(mean(accuracy_ARRLSimb), '%.3f')]);
    axis  square;
    fprintf('avearge (std), LDA, %.1f (%.2f), ARTL, %.1f (%.2f), ARTLimb, %.1f (%.2f)\n', mean(accuracy_LDA)*100, std(accuracy_LDA)*100, mean(accuracy_ARRLS)*100, std(accuracy_ARRLS)*100, mean(accuracy_ARRLSimb)*100, std(accuracy_ARRLSimb)*100);
    
    fprintf('ARTL > LDA?\n');
    [h, p, ci, stats] = ttest(accuracy_ARRLS, accuracy_LDA, 'Alpha', 0.001, 'Tail', 'right') % one-sided t-test (ARTL > LDA?)
    
    fprintf('ARTLimb > LDA?\n');
    [h, p, ci, stats] = ttest(accuracy_ARRLSimb, accuracy_LDA, 'Alpha', 0.001, 'Tail', 'right') % one-sided t-test (ARTL > LDA?)
    
    fprintf('ARTLimb > ARTL?\n');
    [h, p, ci, stats] = ttest(accuracy_ARRLSimb, accuracy_ARRLS, 'Alpha', 0.001, 'Tail', 'right') % one-sided t-test (ARTL > LDA?)
    
    fileName = ['pairwise_' num2str(mean(accuracy_LDA)*100, '%.2f') '_' num2str(mean(accuracy_ARRLS)*100, '%.2f') '_' num2str(mean(accuracy_ARRLSimb)*100, '%.2f') '_target_' targetClass];
    saveas(fH, [outPath filesep fileName '.fig'], 'fig');
    img = getframe(fH);
    imwrite(img.cdata, [outPath filesep fileName '.png']);
end

