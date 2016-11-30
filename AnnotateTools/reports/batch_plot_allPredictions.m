%% Generate reports using the recall metric
%  Parameters:
%       inPat: the pash to the annotation scores
%       outPath: the path to the place where the generated report is saved
%
function outPath = batch_plot_allPredictions(inPath, varargin)

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
   
    plotClasses_str = [];
    for i=1:length(plotClasses)
        plotClasses_str = strcat(plotClasses_str,  '_', num2str(plotClasses{i}));
    end
    
    if fBinary == true
        outPath = [outPath '_binary_length_' num2str(plotLength) '_markEvent' plotClasses_str];
    else
        outPath = [outPath '_gray_length_' num2str(plotLength) '_markEvent' plotClasses_str];
    end
    
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
        trueLabelBinary = zeros(size(trueLabel));

        for s=1:length(trueLabel)
            if ~isempty(trueLabel{s})
                for i1=1:length(trueLabel{s})
                    for i2=1:length(plotClasses)
                        if strcmp(trueLabel{s}{i1}, plotClasses{i2})
                            trueLabelBinary(s) = 1;
                        end
                    end
                end
            end
        end

        yTickLabels = {'(Test)'};
        for trainID = 1:size(annotData.allScores, 2)
            yTickLabels{trainID+1} = ['' num2str(trainID)];
        end
        fH = figure(1);  clf;
        set(fH, 'Position', [200, 310, 1580, 420]);
        plotTemp = [trueLabelBinary annotData.allScores];
        if fBinary == true
            plotTemp(plotTemp > 0) = 1;
        else
            plotTemp = round(plotTemp * 255);  % 256 grey 
        end
        imagesc(plotTemp');
        axis xy;
        if fBinary == true
            map = [1, 1, 1
                  0, 0, 0];
        else % grey
            map = 1 - gray(256);
        end
        colormap(map);	
        set(gca, 'YTick', (1:18));     set(gca, 'YTickLabel', yTickLabels);
        %set(gca, 'XTick', 480:80:960);  set(gca, 'XTickLabel', {'60', '70', '80', '90', '100', '110', '120'});
        set(gca, 'Ticklength', [0 0]);
        ylabel(['Training subjects 1-' num2str(size(annotData.allScores, 2))]);
        xlabel('Samples');     %xlabel('Seconds');     
        beginFrame = 1;
        endFrame = beginFrame + plotLength - 1;
        while(beginFrame < size(plotTemp, 1))
            xlim([beginFrame endFrame]);
            title(['Predicted scores by 17 training subjects for the test subject ' num2str(testSubjID) ', frame: ' num2str(beginFrame) '-' num2str(endFrame)]);
            img = getframe(gcf);
            imwrite(img.cdata, [outPath filesep ['testSubject' num2str(testSubjID, '%02d') '_f' num2str(beginFrame, '%04d') '.png']]);
            beginFrame = beginFrame + plotLength;
            endFrame = endFrame + plotLength;
        end
    end
end