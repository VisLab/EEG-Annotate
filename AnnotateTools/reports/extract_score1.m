%% Extract score1 (window score)
%
% extract_score1('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34', '.\extractData\score1', '34');
% extract_score1('D:\temp\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_35', '.\extractData\score1', '35');
function extract_score1(inPath, outPath, targetClass)

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
                
                scores{testID, trainID} = rawScore;
            end
        end
    end

    save([outPath filesep targetClass '.mat'], 'scores', 'trueLabels');
end

