%% evaluation
% 
%  Assumption: VEP training set of (18 subjects odd-test)
%

targetClasses = {{'1311'}, ...   % valid
                 {'1321', '1331', '1341', '1351', '1361'}, ... % not valid
                 {'2110'}, ...   % allow
                 {'2120'}};      % deny
maxDistance = 160;  % 20 seconds
classType = {'Valid', ...          % 1
                'NotValid', ...    % 2
                'Allow', ...        % 3
                'Deny'};         % 4

%% set path to test set
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR';	% to get the list of test files
scoreIn = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreAexcludeOff';    % annotated samples
resultOut = 'Z:\Data 4\annotate\BCIT\Level2_256Hz_ASR_featureA_scoreAexcludeOff_results';    

% testNames = {'X3 Baseline Guard Duty'; ...
%             'X4 Advanced Guard Duty'; ...
%             'Experiment X2 Traffic Complexity'; ...
%             'Experiment X6 Speed Control'; ...
%             'Experiment XB Baseline Driving'; 
%             'Experiment XC Calibration Driving'; ...
%             'X1 Baseline RSVP'; ...
%             'X2 RSVP Expertise'};
testNames = {'X3 Baseline Guard Duty'; ...
            'X4 Advanced Guard Duty'};

for t=1:length(testNames)
    testName = testNames{t};
    
    fileListDir = [fileListIn filesep testName]; 

    % Create a level 2 derevied study
    %  To get the list of file names
    derivedXMLFile = [fileListDir filesep level2DerivedFile];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
    [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);
    
    % go over all test sets and estimate scores
    testsetNumb = length(filenames);
    classNumb = length(targetClasses);
    
    counts = zeros(testsetNumb, classNumb, classNumb, maxDistance); % count of distances
    
    for testSubjID=1:testsetNumb
        [path, name, ext] = fileparts(filenames{testSubjID});
        scoreDir = [scoreIn filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
        scoreData = []; % init scoreData
        load([scoreDir filesep name '.mat']);  % load scoreData

        trueLabel = scoreData.trueLabelOriginal{1};
        
        eventCount = 0;
        targetEventCount = 0;
        failList = [];
        for startIdx=1:length(trueLabel)
            if ~isempty(trueLabel{startIdx})
                eventCount = eventCount + length(trueLabel{startIdx});
                for i1=1:length(trueLabel{startIdx})
                    startID = getClassID(targetClasses, trueLabel{startIdx}{i1});
                    if startID > 0
                        targetEventCount = targetEventCount + 1;
                        for d=1:maxDistance
                            endIdx = startIdx + d;
                            if endIdx > length(trueLabel)
                                break;
                            end
                            flagFound = false;    
                            if ~isempty(trueLabel{endIdx})
                                for i2=1:length(trueLabel{endIdx})
                                    endID = getClassID(targetClasses, trueLabel{endIdx}{i2});
                                    if endID > 0
                                        counts(testSubjID, startID, endID, d) = counts(testSubjID, startID, endID, d) + 1;
                                        flagFound = true;
                                    end
                                end
                            end
                            if flagFound == true
                                break;
                            end
                        end
                        if d>=maxDistance
                            failList = cat(1, failList, [startIdx str2double(trueLabel{startIdx}{i1})]);
                        end
                    end
                end
            end
        end
        fprintf('test subject, %d, %d samples, %d events, %d target events, %d fails\n', testSubjID, length(trueLabel), eventCount, targetEventCount, size(failList, 1));
        
        countOut = [resultOut filesep 'countDistance_max' num2str(maxDistance) filesep testName filesep 'session' filesep sessionNumbers{testSubjID}];
        if ~isdir(countOut)   % if the directory is not exist
            mkdir(countOut);  % make the new directory
        end
        for startID=1:4
            for endID=1:4
                hf1 = figure(1); clf;
                cData = squeeze(counts(testSubjID, startID, endID, :));
                plot(cData);
                xlabel('Time (8 intervals / 1 second)');
                ylabel('Count');
                title([testName ', session ' sessionNumbers{testSubjID} ', ' classType{startID} ' to ' classType{endID}]);
                saveas(hf1, [countOut filesep num2str(startID) '_' num2str(endID) '.png']);
            end
        end
%         for startID=1:4
%             for endID=1:4
%                 fprintf('%d,%d,', startID, endID);
%                 for d=1:maxDistance
%                     fprintf('%d,', counts(testSubjID, startID, endID, d));
%                 end
%                 fprintf('\n');
%             end
%         end
    end
    countOut = [resultOut filesep 'count_Distance_max' num2str(maxDistance) filesep testName];
    if ~isdir(countOut)   % if the directory is not exist
        mkdir(countOut);  % make the new directory
    end
    save([countOut filesep 'countDistances.mat'], 'counts', 'failList', 'eventCount', 'targetEventCount');
end