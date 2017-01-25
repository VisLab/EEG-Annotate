function outPath = batch_plot_allPredictions_binaryEvent(inPath, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    if isfield(params, 'sampleSize')
        sampleSize = params.sampleSize;
    else
        error('sampleSize must be specified');
    end
    plotLength = 500;
    if isfield(params, 'plotLength')
        plotLength = params.plotLength;
    end
    plotClasses = {''};
    if isfield(params, 'plotClasses')
        plotClasses = params.plotClasses;
    end
    fBinary = true;
    if isfield(params, 'fBinary')
        fBinary = params.fBinary;
    end
   
    tenSeconds = 10 * (1 / sampleSize);
    
    plotClasses_str = [];
    tempClasses = sort(plotClasses(:));
    for i=1:length(tempClasses)
        plotClasses_str = strcat(plotClasses_str,  '_', num2str(tempClasses{i}));
    end
    
    eventColorMap = [0, 0, 1;   % blue
                     0, 1, 0;   % green
                     1, 0, 0];   % red
    if fBinary == true
        outPath = [outPath '_binary_length_' num2str(plotLength) '_markEvent' plotClasses_str];
        scoreColorMap = [1, 1, 1
              0, 0, 0];
    else % grey
        outPath = [outPath '_gray_length_' num2str(plotLength) '_markEvent' plotClasses_str];
        scoreColorMap = 1 - gray(256);
    end
    userColorMap = cat(1, scoreColorMap, eventColorMap);
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);
    
    % go over all test sets and estimate scores
    testsetNumb = length(fileList);
    
    for testSubjID=1:testsetNumb
        load([inPath filesep fileList(testSubjID).name]); % load annotData

        trueLabel = annotData.testLabel;
        trueLabelBinary = zeros(length(trueLabel), length(plotClasses));

        for s=1:length(trueLabel)
            if ~isempty(trueLabel{s})
                for i1=1:length(trueLabel{s})
                    for i2=1:length(plotClasses)
                        if strcmp(trueLabel{s}{i1}, plotClasses{i2})
                            trueLabelBinary(s, i2) = 1;
                        end
                    end
                end
            end
        end
        allScores = annotData.allScores;
        eventIdx = (trueLabelBinary>0);
        if fBinary == true
            allScores(allScores > 0) = 1;
            trueLabelBinary(eventIdx) = trueLabelBinary(eventIdx) + 2;
        else % grey
            allScores = round(allScores * 255);  % 256 grey 
            trueLabelBinary(eventIdx) = trueLabelBinary(eventIdx) + 256;
        end
        plotTemp = [trueLabelBinary allScores];
        
        yTickLabels = cell(length(plotClasses) + size(annotData.allScores, 2), 1);
        for i=1:length(plotClasses)
            yTickLabels{i} = ['event ' plotClasses{i}];
        end
        for trainID = 1:size(annotData.allScores, 2)
            yTickLabels{length(plotClasses)+trainID} = num2str(trainID);
        end
        
        XTicks = 1:tenSeconds:size(allScores, 1);
        XTickLabels = {'0'};
        for t=2:length(XTicks)
           XTickLabels{t} = num2str((t-1)*10);     
        end
        
        nRow = size(plotTemp, 2);
        heightAxis = nRow * 10;
        heightFigure = heightAxis + 220;
        
        fH = figure(1);  clf;
        set(fH, 'Position', [50, 300, 1600, heightFigure]);
        image(plotTemp');
        set(gca, 'Unit', 'points');
        set(gca, 'Position', [100, 40, 1000, heightAxis]);
        axis xy;
        colormap(userColorMap);	
        set(gca, 'YTick', (1:length(yTickLabels)));     set(gca, 'YTickLabel', yTickLabels);
        set(gca, 'XTick', XTicks);  set(gca, 'XTickLabel', XTickLabels);
        set(gca, 'Ticklength', [0 0]);
        ylabel(['Training subjects 1-' num2str(size(annotData.allScores, 2))]);
        xlabel('Seconds');     
        ylim([0.5 length(yTickLabels)+0.5]);  % to exclude response events
        beginFrame = 1;
        endFrame = beginFrame + plotLength - 1;
        while(beginFrame < size(plotTemp, 1))
            xlim([beginFrame endFrame]);
            title(['Predicted scores by ' num2str(size(annotData.allScores, 2)) ' training subjects for the test subject ' num2str(testSubjID) ', frame: ' num2str(beginFrame) '-' num2str(endFrame)]);
            fileName = ['testSubject' num2str(testSubjID, '%02d') '_f' num2str(beginFrame, '%04d')];
            %saveas(fH, [outPath filesep fileName '.fig']);
            img = getframe(fH);
            imwrite(img.cdata, [outPath filesep fileName '.png']);
            beginFrame = beginFrame + plotLength;
            endFrame = endFrame + plotLength;
        end
    end
end