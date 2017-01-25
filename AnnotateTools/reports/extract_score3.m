%% Extract score3 (mask-out sub-window score)
%
% extract_score3('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34', '.\output\extractData\score3', '34');
% extract_score3('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_35', '.\output\extractData\score3', '35');
function extract_score3(inPath, outPath, targetClass)
    weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5];    
    position = 8;   

    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all test sets
    fileList = dir([inPath filesep '*.mat']);

    setNumb = length(fileList);
    
    scores = cell(setNumb, setNumb);    % test x training
    trueLabels = cell(setNumb, 1);
    
    for testID = 1:setNumb
        testSubjID = str2double(fileList(testID).name(5:6));
        load([inPath filesep fileList(testID).name]); % load annotData
        
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
        
        trueLabels{testID} = trueLabelBinary;
        
        for trainID = 1:setNumb
            if testID == trainID
                continue;
            else
                rawScore = scoreData.testFinalScore{trainID};       % window scores
                
                wScore = getWeightedScore(rawScore, weights, position); % calculate weighted sub-windows scores
                
                cutoff = getCutoff_FL(wScore, 30, 0.0);     % adaptive cutoff
                
                mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements         
                
                scores{testID, trainID} = mScore;
                
%                 fH = figure(1); clf;
%                 hist(wScore, 50);
%                 title(['test subject: ' num2str(testID) ', train subject: ' num2str(trainID) ', adaptive cutoff: ' num2str(cutoff, '%.2f')]);
%                 xlabel('Sub window scores');
%                 ylabel('Count');
%                 img = getframe(fH);
%                 imwrite(img.cdata, [outPath filesep targetClass '_test' num2str(testID, '%02d') '_train' num2str(trainID, '%02d') '.png']);
            end
        end
    end

    save([outPath filesep targetClass '.mat'], 'scores', 'trueLabels');
end

