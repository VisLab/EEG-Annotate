%% Pairwise classification accuracy
%
% report_pairwise_accuracy_type1('D:\temp\PREP_ICA_MARA_averagePower_LDA_34', 'LDA', 'D:\temp\PREP_ICA_MARA_averagePower_ARTLimb_34', 'ARTLimb', '34', '.\pair_type1\LDA_vs_ARTLimb\34', [0.3 1.0]);
% report_pairwise_accuracy_type1('D:\temp\PREP_ICA_MARA_averagePower_LDA_34', 'LDA', 'D:\temp\PREP_ICA_MARA_averagePower_ARTLorg_34', 'ARTLorg', '34', '.\pair_type1\LDA_vs_ARTLorg\34', [0.3 1.0]);
% report_pairwise_accuracy_type1('D:\temp\PREP_ICA_MARA_averagePower_LDA_35', 'LDA', 'D:\temp\PREP_ICA_MARA_averagePower_ARTLimb_35', 'ARTLimb', '35', '.\pair_type1\LDA_vs_ARTLimb\35', [0.3 1.0]);
% report_pairwise_accuracy_type1('D:\temp\PREP_ICA_MARA_averagePower_LDA_35', 'LDA', 'D:\temp\PREP_ICA_MARA_averagePower_ARTLorg_35', 'ARTLorg', '35', '.\pair_type1\LDA_vs_ARTLorg\35', [0.3 1.0]);
function report_pairwise_accuracy_type1(inPath1, title1, inPath2, title2, targetClass, outPath, plotRange)

    accuracy1 = getBalancedAccuracy(inPath1, targetClass);
    accuracy2 = getBalancedAccuracy(inPath2, targetClass);
    
    accuracy1 = accuracy1(:);
    accuracy1(accuracy1 == -1) = [];
    accuracy2 = accuracy2(:);
    accuracy2(accuracy2 == -1) = [];
    
    %minLimit = min([accuracy1; accuracy2]);
    %maxLimit = max([accuracy1; accuracy2]);
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end
    
    fH = figure(1); clf;
    scatter(accuracy1, accuracy2);
    box on;
    line(plotRange, plotRange, 'Color', 'k', 'LineStyle', ':');
    xlim(plotRange);
    ylim(plotRange);
    xlabel(title1);
    ylabel(title2);
    title([title1 ': ' num2str(mean(accuracy1), '%.3f') ', ' title2 ': ' num2str(mean(accuracy2), '%.3f')]);
    axis  square;
    fprintf('avearge, %f, %f\n', mean(accuracy1), mean(accuracy2));
    
    fileName = ['pairwise_' num2str(mean(accuracy1)*100, '%.2f') '_' num2str(mean(accuracy2)*100, '%.2f')];
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
