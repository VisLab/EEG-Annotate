%% Extract score7 (mask-out smoothed combined scores)
%
% extract_score7_4_ac_on_win_score('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34', '.\extractData\score7_acOnWin', '34');
% extract_score7_4_ac_on_win_score('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_35', '.\extractData\score7_acOnWin', '35');
function extract_score7_4_ac_on_win_score(inPath, outPath, targetClass)
    weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5];    
    position = 8;   

    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all test sets
    fileList = dir([inPath filesep '*.mat']);

    setNumb = length(fileList);
    
    scores = cell(setNumb, 1);    % test x training
    trueLabels = cell(setNumb, 1);
    
    for testID = 9:setNumb
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
        
        allScores = [];
        for trainID = 1:setNumb
            if testID == trainID
                continue;
            else
                rawScore = scoreData.testFinalScore{trainID};       % window scores
                
                adaptiveCutoff = getCutoff_FL(rawScore, 30, 0.5);     % adaptive cutoff
                
                shiftedScore = rawScore - adaptiveCutoff;       % now the score has zero cutoff
                
                noNegativeShiftedScore = shiftedScore;
                noNegativeShiftedScore(shiftedScore < 0) = 0;   % remove everything below zero
                
                nonZeroScore = noNegativeShiftedScore(noNegativeShiftedScore > 0);
                cutMax = prctile(nonZeroScore, 98);
                
                normalizedScore = noNegativeShiftedScore;
                normalizedScore(normalizedScore > cutMax) = cutMax;
                normalizedScore = normalizedScore ./ cutMax;              % score range is 0 to 1.
                
                wScore = getWeightedScore(normalizedScore, weights, position); % calculate weighted sub-windows scores
                
                cutoff = 0;
                
                mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements         
                
%                 if max(mScore) <= 0
%                     fprintf('TEST %d, trining %d\n', testID, trainID);
%                     cutMax = 1;
%                 else
%                     nonZeroScore = mScore(mScore > 0);
%                     %cutMax = mean(nonZeroScore); % - (1 * std(nonZeroScore));
%                     cutMax = prctile(nonZeroScore, 95);
%                 end
%           
%                 mScore(mScore > cutMax) = cutMax;
%                 mScore = mScore ./ cutMax;              % score range is 0 to 1.
                
                allScores = cat(2, allScores, mScore);
            end
        end
        combinedScore = mean(allScores, 2);
        if sum(isnan(combinedScore)) > 0
            error('nan score');
        end
        wScore = getWeightedScore(combinedScore, weights, position);    % smooth scores
        
        cutoff = 0;
        
        mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements    
        
        scores{testID} = mScore;
        
%         fH = figure(3); clf;
%         nonZeroScore = mScore(mScore>0);
%         hist(nonZeroScore, 20);
%         title(['test subject: ' num2str(testID) ', nonZero #: ' num2str(length(nonZeroScore)) ' of ' num2str(length(mScore))]);
%         xlabel('Score');         ylabel('Count');         xlim([0 10]);
        
%         set(fH, 'Position', [100, 100, 500, 900]); 
%         
%         subplot(3, 1, 1);
%         nonZeroScore = mScore(mScore>0);
%         hist(nonZeroScore, 0.5:8.5);
%         counts = hist(nonZeroScore, 0.5:8.5);
%         mCount = max(counts);
%         ylim([0 mCount*1.1]);
%         title(['test subject: ' num2str(testID) ', nonZero #: ' num2str(length(nonZeroScore)) ' of ' num2str(length(mScore))]);
%         xlabel('Score');         ylabel('Count');         xlim([0 10]);
%         
%         subplot(3, 1, 2);
%         nonZeroScore = mScore(mScore>0 & trueLabelBinary>0);
%         hist(nonZeroScore, 0.5:8.5);
%         ylim([0 mCount*1.1]);
%         title(['test subject: ' num2str(testID) ', nonZero & positive#: ' num2str(length(nonZeroScore)) ' of ' num2str(length(mScore))]);
%         xlabel('Score');         ylabel('Count');         xlim([0 10]);
%         
%         subplot(3, 1, 3);
%         nonZeroScore = mScore(mScore>0 & trueLabelBinary==0);
%         hist(nonZeroScore, 0.5:8.5);
%         ylim([0 mCount*1.1]);
%         title(['test subject: ' num2str(testID) ', nonZero & negative#: ' num2str(length(nonZeroScore)) ' of ' num2str(length(mScore))]);
%         xlabel('Score');         ylabel('Count');         xlim([0 10]);
        
        img = getframe(fH);
        imwrite(img.cdata, [outPath filesep targetClass '_' num2str(testID, '%02d') '.png']);
    end

    save([outPath filesep targetClass '.mat'], 'scores', 'trueLabels');
end

