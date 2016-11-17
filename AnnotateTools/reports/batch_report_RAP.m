%% Generate reports using the recall metric
%  Parameters:
%       inPat: the pash to the annotation scores
%       outPath: the path to the place where the generated report is saved
%
function outPath = batch_report_RAP(inPath, varargin)

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
   
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);
    
    % go over all test sets and estimate scores
    testsetNumb = length(fileList);
    
    RAPs = zeros(testsetNumb, length(timinigTolerances)); % avrage precisions
    
    for testSubjID=1:testsetNumb
        load([inPath filesep fileList(testSubjID).name]); % load annotData

        trueLabel = annotData.trueLabelOriginal;
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
            RAPs(testSubjID, tID) = evaluate_AP(trueLabelBinary, score, tol);
        end
    end
    outResults = squeeze(mean(RAPs, 1));
    
    saveName = 'target';
    for cID = 1:length(targetClasses)
        saveName = [saveName '_' targetClasses{cID}];
    end
    saveName = [saveName '_RAP'];
    save([outPath filesep saveName], 'RAPs', 'outResults', '-v7.3');
    
    disp('Report: RAP');
    disp('Parameter1: timing tolerance');
    disp(timinigTolerances);
    disp(outResults);   % MAP (mean of average precision)    
end