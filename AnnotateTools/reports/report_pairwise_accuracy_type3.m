%% Pairwise classification accuracy
%
% report_pairwise_accuracy_type3('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_34', 'LDA', 'D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLorg_34', 'ARTLorg', 'D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34', 'ARTLimb', '34', '.\pair_type3\friend', [0.3 1.0]);
% report_pairwise_accuracy_type3('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_35', 'LDA', 'D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLorg_35', 'ARTLorg', 'D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_35', 'ARTLimb', '35', '.\pair_type3\foe', [0.3 1.0]);
function report_pairwise_accuracy_type3(inPath1, title1, inPath2, title2, inPath3, title3, targetClass, outPath, plotRange)

    accuracy1 = getBalancedAccuracy(inPath1, targetClass); % LDA
    accuracy2 = getBalancedAccuracy(inPath2, targetClass); % ARTLorg
    accuracy3 = getBalancedAccuracy(inPath3, targetClass); % ARTLimb
    
    accuracy1 = accuracy1(:);
    accuracy1(accuracy1 == -1) = [];
    accuracy2 = accuracy2(:);
    accuracy2(accuracy2 == -1) = [];
    accuracy3 = accuracy3(:);
    accuracy3(accuracy3 == -1) = [];
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end
    
    fH = figure(1); clf;
    scatter(accuracy2, accuracy1, 72, 'o', 'MarkerEdgeColor', [0.75 0.75 0.75]);
    hold on
    scatter(accuracy2, accuracy3, 72, 's', 'MarkerEdgeColor', 'k');
    hold off
    box on;
    line(plotRange, plotRange, 'Color', 'k', 'LineStyle', ':');
    xlim(plotRange);
    ylim(plotRange);
    xlabel([title2 ' accuracy']);
    ylabel(['(' title1 ', ' title3 ') accuracy']);
    legend(title1, title3, 'Location', 'southeast');
    title([title1 ': ' num2str(mean(accuracy1), '%.3f') ', ' title2 ': ' num2str(mean(accuracy2), '%.3f') ', ' title3 ': ' num2str(mean(accuracy3), '%.3f')]);
    axis  square;
    fprintf('avearge (std), LDA, %.1f (%.2f), ARTL, %.1f (%.2f), ARTLimb, %.1f (%.2f)\n', mean(accuracy1)*100, std(accuracy1)*100, mean(accuracy2)*100, std(accuracy2)*100, mean(accuracy3)*100, std(accuracy3)*100);
    
    fprintf('ARTL > LDA?\n');
    [h, p, ci, stats] = ttest(accuracy2, accuracy1, 'Alpha', 0.001, 'Tail', 'right') % one-sided t-test (ARTL > LDA?)
    
    fprintf('ARTLimb > LDA?\n');
    [h, p, ci, stats] = ttest(accuracy3, accuracy1, 'Alpha', 0.001, 'Tail', 'right') % one-sided t-test (ARTL > LDA?)
    
    fprintf('ARTLimb > ARTL?\n');
    [h, p, ci, stats] = ttest(accuracy3, accuracy2, 'Alpha', 0.001, 'Tail', 'right') % one-sided t-test (ARTL > LDA?)
    
    fileName = ['pairwise_' num2str(mean(accuracy1)*100, '%.2f') '_' num2str(mean(accuracy2)*100, '%.2f') '_' num2str(mean(accuracy3)*100, '%.2f') '_target_' targetClass];
    saveas(fH, [outPath filesep fileName '.fig'], 'fig');
    img = getframe(fH);
    imwrite(img.cdata, [outPath filesep fileName '.png']);
end

function allAccuracy = getBalancedAccuracy(inPath, targetClass)

    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);

    % go over all test sets and estimate scores
    setNumb = length(fileList);
    
    allAccuracy = zeros(setNumb, setNumb);
    for setID = 1:setNumb
        testSubjID = str2double(fileList(setID).name(5:6));
        load([inPath filesep fileList(setID).name]); % load annotData
        
        trueLabel = scoreData.testLabel;
        trueLabelBinary = zeros(size(trueLabel));

        numbEvent = 0;
        for s=1:length(trueLabel)
            if ~isempty(trueLabel{s})
                for i1=1:length(trueLabel{s})
                    numbEvent = numbEvent + 1;
                    if strcmp(trueLabel{s}{i1}, targetClass)
                        trueLabelBinary(s) = 1;
                    end
                end
            end
        end
        fprintf('test subject, %d, has %d targets, in %d events, in %d samples\n', ...
                    testSubjID, sum(trueLabelBinary), numbEvent, length(trueLabel));
        
        tnIdx = (trueLabelBinary == 0); % index of true negative
        tpIdx = (trueLabelBinary == 1); % index of true positive
        
        for trainSubjID = 1:setNumb
            if testSubjID == trainSubjID
                allAccuracy(testSubjID, trainSubjID) = -1;
            else
                predLabelBinary = scoreData.predLabel{trainSubjID};
                TP = sum(predLabelBinary(tpIdx) == 1);
                FN = sum(predLabelBinary(tpIdx) == 0);
                TN = sum(predLabelBinary(tnIdx) == 0);
                FP = sum(predLabelBinary(tnIdx) == 1);
                accuracy = 0.5 * (TP/(TP+FN) + TN/(TN+FP));
                allAccuracy(testSubjID, trainSubjID) = accuracy;
            end
        end
    end
end
