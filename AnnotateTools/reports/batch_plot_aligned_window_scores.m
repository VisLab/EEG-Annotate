function outPath = batch_plot_aligned_window_scores(inPath, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    excludeSelf = true;     % when training data and test data are same
    if isfield(params, 'excludeSelf')
        excludeSelf = params.excludeSelf;
    end
    if isfield(params, 'targetClasses')
        targetClasses = params.targetClasses;
    else
        error('Target class must be specified');
    end
    neighborSize = 10;
    if isfield(params, 'neighborSize')
        neighborSize = params.neighborSize;
    end
    titleStr = 'aligned window scores';
    if isfield(params, 'titleStr')
        titleStr = params.titleStr;
    end

    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end
    
    allAveragePatterns = [];
    
    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);
    for testIdx=1:length(fileList)
        readData = load([inPath filesep fileList(testIdx).name]);

        trueLabel = readData.scoreData.testLabel;
        trueLabelBinary = zeros(size(trueLabel));

        for s=1:length(trueLabel)
            if ~isempty(trueLabel{s})
                for i1=1:length(trueLabel{s})
                    for i2=1:length(targetClasses)
                        if strcmp(trueLabel{s}{i1}, targetClasses{i2})
                            trueLabelBinary(s) = 1;
                        end
                    end
                end
            end
        end
        
        trainsetNumb = length(readData.scoreData.testFinalScore); 
        for trainIdx = 1:trainsetNumb
            if (excludeSelf == true) && (testIdx == trainIdx)
                continue;
            end
            rawScore = readData.scoreData.testFinalScore{trainIdx};
            rawScore = zscore(rawScore);
            patterns = getPatterns_target(rawScore, trueLabelBinary, neighborSize);
            averagePattern = mean(patterns, 2);
            
            allAveragePatterns = cat(2, allAveragePatterns, averagePattern);
        end
    end
    
    hf1 = figure(1); clf;
    plot(allAveragePatterns);
    hold on;
    plot(mean(allAveragePatterns, 2), 'k', 'LineWidth', 5);     % it is the average of the average
    hold off;
    xlim([1 neighborSize*2+1]);
    %ylim([min(allAveragePatterns(:)) max(allAveragePatterns(:))]);
    ylim([-1.4 4.4]);
    xlabel('Offset from the event sub-window (8 sub-windows/sec)');
    ylabel('Score');
    set(gca, 'XTick', 2:20);
    set(gca, 'XTickLabel', {'', '-8', '', '', '', '', '', '', '', '0', '', '', '', '', '', '', '', '8', ''});
    saveas(hf1, [outPath filesep 'AverageAverage.fig'], 'fig');
    img = getframe(hf1);
    imwrite(img.cdata, [outPath filesep 'AverageAverage.png']);
end    

function patterns = getPatterns_target(scores, trueLabel, neighborSize)

    trueIdx = find(trueLabel);
    N = length(scores);
    patterns = [];
    for t=1:length(trueIdx)
        thePos = trueIdx(t);
        startPos = thePos - neighborSize;
        endPos = thePos + neighborSize;
        if startPos < 1
            startAddZero = 1 - startPos;
            startPos = 1;
        else 
            startAddZero = 0;
        end
        if endPos > N
            endAddZero = endPos - N;
            endPos = N;
        else
            endAddZero = 0;
        end
        
        pattern = scores(startPos:endPos);
        
        patternZeroPad = [zeros(startAddZero, 1); pattern; zeros(endAddZero, 1)];
        
        patterns = cat(2, patterns, patternZeroPad);
    end
end
