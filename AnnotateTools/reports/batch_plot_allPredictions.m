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
        trueLabelBinary = zeros(length(trueLabel), 2);

        for s=1:length(trueLabel)
            if ~isempty(trueLabel{s})
                for i1=1:length(trueLabel{s})
                    for i2=1:2
                        for i3=1:size(plotClasses, 2)
                            if strcmp(trueLabel{s}{i1}, plotClasses{i2,i3})
                                if trueLabelBinary(s, i2) ~= 0
                                    warning('True event is overwritten');
                                end
                                trueLabelBinary(s, i2) = i3;
                            end
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
        
        yTickLabels = {'(Response)'};
        yTickLabels{2} = '(Image)';
        for trainID = 1:size(annotData.allScores, 2)
            yTickLabels{trainID+2} = ['' num2str(trainID)];
        end
        fH = figure(1);  clf;
        set(fH, 'Position', [200, 310, 1580, 420]);
        image(plotTemp');
        axis xy;
        colormap(userColorMap);	
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