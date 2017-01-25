%% Timing errors
%
% report_timing_errors('..\examples\output\type1_LDA_34\annotScore', 'LDA', '..\examples\output\type1_ARTLorg_34\annotScore', 'ARRLS', '..\examples\output\type1_ARTLimb_34\annotScore', 'ARRLSimb', '34', '.\output\timingError', 8);
% report_timing_errors('..\examples\output\type1_LDA_35\annotScore', 'LDA', '..\examples\output\type1_ARTLorg_35\annotScore', 'ARRLS', '..\examples\output\type1_ARTLimb_35\annotScore', 'ARRLSimb', '35', '.\output\timingError', 8);
function report_timing_errors(inPath1, title1, inPath2, title2, inPath3, title3, targetClass, outPath, maxError)

    [allErrors1, ~, plotData1, plotError1] = getTimingErrors(inPath1, targetClass, maxError); % LDA
    [allErrors2, ~, plotData2, plotError2] = getTimingErrors(inPath2, targetClass, maxError); % ARTLorg
    [allErrors3, ~, plotData3, plotError3] = getTimingErrors(inPath3, targetClass, maxError); % ARTLimb
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end
    
    fH = figure(1); clf;
    %errorbar(0:maxError, plotData1, plotError1, 'r', 'LineWidth', 3); % color
    errorbar(0:maxError, plotData1, plotError1, 'Color', [0.8 0.8 0.8], 'LineWidth', 3);  % gray
    hold on
    %errorbar(0:maxError, plotData2, plotError2, 'g', 'LineWidth', 3);  % color
    errorbar(0:maxError, plotData2, plotError2, 'Color', [0.59 0.59 0.59], 'LineWidth', 3);
    %errorbar(0:maxError, plotData3, plotError3, 'b', 'LineWidth', 3);  % color
    errorbar(0:maxError, plotData3, plotError3, 'Color', [0.32 0.32 0.32], 'LineWidth', 3);
    hold off
    xlim([0 maxError-1]);
    ylim([0 1]);
    xlabel('Timing error');
    ylabel('Cumulative fraction');
    legend(title1, title2, title3, 'Location', 'southeast');
    if strcmp(targetClass, '34')
        title('Friend vs. others');
    else
        title('Foe vs. others');
    end
    fprintf('avearge (std), %.2f (%.2f), %.2f (%.2f), %.2f (%.2f)\n', mean(allErrors1), std(allErrors1), mean(allErrors2), std(allErrors2), mean(allErrors3), std(allErrors3));
    
    fileName = ['timingError_target_' targetClass];
    saveas(fH, [outPath filesep fileName '.fig'], 'fig');
    img = getframe(fH);
    imwrite(img.cdata, [outPath filesep fileName '.png']);
end

function [allErrors, subjErrors, plotData, plotError] = getTimingErrors(inPath, targetClass, maxError)

    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);
    
    % go over all test sets and estimate scores
    testsetNumb = length(fileList);
    
    allErrors = [];
    subjErrors = cell(testsetNumb, 1);
    for testSubjID=1:testsetNumb
        load([inPath filesep fileList(testSubjID).name]); % load annotData

        trueLabel = annotData.testLabel;
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

        score = annotData.combinedScore;
        if length(trueLabelBinary) ~= length(score)
            error('data lengths are not matched');
        end
        predLabelBinary = (score > 0);
        
        targetIdx = find(trueLabelBinary);
        N = length(targetIdx);
        errors = ones(N, 1) * maxError;   % initial distance is the max
        
        for i=1:N
            idx = targetIdx(i);
            for d=0:maxError % greedy way inspect
                iBegin = idx-d;
                iEnd = idx+d;
                iBegin = max(iBegin, 1);
                iEnd = min(length(predLabelBinary), iEnd);
                if sum(predLabelBinary(iBegin:iEnd)) > 0
                    errors(i) = d;
                    break;
                end
            end
        end
        allErrors = cat(1, allErrors, errors);
        subjErrors{testSubjID} = errors;
    end
    [counts, ~] = hist(allErrors, 0:maxError);        % if the distance is larger than the max, it is fail to retrieve.

    scaleCounts = counts ./ length(allErrors);
    plotData = cumsum(scaleCounts);
    
    plotError = [];
    for e=0:maxError
        tmpData = allErrors(allErrors <= e);
        SE = std(tmpData) / sqrt(length(tmpData));
        plotError = cat(1, plotError, SE*1.96); % https://www.mathworks.com/matlabcentral/answers/143321-how-to-put-errorbars
    end
end
