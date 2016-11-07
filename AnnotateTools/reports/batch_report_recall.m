%% 
%
function outPath = batch_report_recall(inPath, varargin)

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    timinigTolerance = 0:5;
    if isfield(params, 'outPath')
        timinigTolerance = params.timinigTolerance;
    end
    retrieveNumbs = 100:100:1000;
    if isfield(params, 'outPath')
        retrieveNumbs = params.retrieveNumbs;
    end
   
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);
    
    % go over all test sets and estimate scores
    testsetNumb = length(fileList);
    
    averageRecalls = zeros(length(retrieveNumbs), testsetNumb, length(timinigTolerance)); % avrage precisions
    
    for r=1:length(retrieveNumbs)
        retrieveNumb = retrieveNumbs(r);
    
        for testSubjID=1:testsetNumb
            load([inPath_test filesep fileList(testSubjID).name]); % load annotData
            
            trueLabel = annotData.trueLabelOriginal{1};
            trueLabelBinary = zeros(size(trueLabel));

            numbEvent = 0;
            for s=1:length(trueLabel)
                if ~isempty(trueLabel{s})
                    for i1=1:length(trueLabel{s})
                        numbEvent = numbEvent + 1;
                        for i2=1:length(targetClasses)
                            if strcmp(trueLabel{s}{i1}, targetClasses{i2})
                                trueLabelBinary(s) = 1;
                            end
                        end
                    end
                end
            end
            fprintf('test subject, %d, has %d targets, in %d events, in %d samples\n', ...
                        testSubjID, sum(trueLabelBinary), numbEvent, length(trueLabel));

            score = annotData.combinedScore{1};
            if length(trueLabelBinary) ~= length(score)
                error('data lengths are not matched');
            end
            for tID = 1:length(t_tolerance)
                tol = t_tolerance(tID);
                averageRecalls(r, testSubjID, tID) = evaluate_recall(trueLabelBinary, score, tol, retrieveNumb);
            end
        end
    end
    
    saveName = 'target';
    for cID = 1:length(targetClasses)
        saveName = [saveName '_' targetClasses{cID}];
    end
    saveName = [saveName '_recall'];
    save([outPath filesep saveName], 'averageRecalls', '-v7.3');
    disp(squeeze(mean(averageRecalls, 2)));   % MAP (mean of average precision)    
end