%% Extract score5 (combined scores of normalized mask-out sub-window score)
%
% extract_score5('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34', '.\output\extractData\score5', '34');
% extract_score5('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_35', '.\output\extractData\score5', '35');
function extract_score5(inPath, outPath, targetClass)
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
        
        allScores = [];
        for trainID = 1:setNumb
            if testID == trainID
                continue;
            else
                rawScore = scoreData.testFinalScore{trainID};       % window scores
                
                wScore = getWeightedScore(rawScore, weights, position); % calculate weighted sub-windows scores
                
                cutoff = getCutoff_FL(wScore, 30, 0.0);     % adaptive cutoff
                
                mScore = getMaskOutScore(wScore, 7, cutoff);  % mask out 15 elements         
                
                nonZeroScore = mScore(mScore > 0);
                cutMax = mean(nonZeroScore); % - (1 * std(nonZeroScore));
          
                mScore(mScore > cutMax) = cutMax;
                mScore = mScore ./ cutMax;              % score range is 0 to 1.
                
                allScores = cat(2, allScores, mScore);
            end
        end
        combinedScore = mean(allScores, 2);
        if sum(isnan(combinedScore)) > 0
            error('nan score');
        end
        scores{testID} = combinedScore;
    end

    save([outPath filesep targetClass '.mat'], 'scores', 'trueLabels');
end

