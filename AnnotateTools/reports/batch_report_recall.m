function outPath = batch_report_recall(inPath, varargin)
%% Generate reports using the recall metric
%
%  Parameters:
%       inPat: the pash to the annotation scores
%       outPath: the path to the place where the generated report is saved
%

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    if isfield(params, 'targetClasses')
        targetClasses = params.targetClasses;
    else
        error('Target class must be specified');
    end
    timinigTolerances = 0:5;
    if isfield(params, 'timinigTolerances')
        timinigTolerances = params.timinigTolerances;
    end
    retrieveNumbs = 100:100:1000;
    if isfield(params, 'retrieveNumbs')
        retrieveNumbs = params.retrieveNumbs;
    end
   
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);
    
    % go over all test sets and estimate scores
    testsetNumb = length(fileList);
    
    averageRecalls = zeros(length(retrieveNumbs), testsetNumb, length(timinigTolerances)); % avrage precisions
    
    for r=1:length(retrieveNumbs)
        retrieveNumb = retrieveNumbs(r);
    
        for testSubjID=1:testsetNumb
            load([inPath filesep fileList(testSubjID).name]); % load annotData
            
            trueLabel = annotData.testLabel;
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

            score = annotData.combinedScore;
            if length(trueLabelBinary) ~= length(score)
                error('data lengths are not matched');
            end
            for tID = 1:length(timinigTolerances)
                tol = timinigTolerances(tID);
                averageRecalls(r, testSubjID, tID) = evaluate_recall(trueLabelBinary, score, tol, retrieveNumb);
            end
        end
    end
    outResults = squeeze(mean(averageRecalls, 2));
    
    saveName = 'target';
    for cID = 1:length(targetClasses)
        saveName = [saveName '_' targetClasses{cID}];
    end
    saveName = [saveName '_recall'];
    save([outPath filesep saveName], 'averageRecalls', 'outResults', '-v7.3');
    
    disp('Report: recall');
    disp('Parameter1: retrieveNumbs');
    disp(retrieveNumbs);
    disp('Parameter2: timing tolerance');
    disp(timinigTolerances);
    disp(outResults);   % MAP (mean of average precision)    
end