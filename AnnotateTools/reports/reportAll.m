function outPath = reportAll(inPath, outPath, targetClass, ...
                             alternateClasses, params)
%% Generate reports using the precision metric
%
%  Parameters:
%       inPat: the pash to the annotation scores
%       outPath: the path to the place where the generated report is saved
%

    %% Set up the defaults and process the input arguments 
    params = processAnnotateParameters('batchReportPrecision', nargin, 5, params);
    tolerances = params.reportTimingTolerances;
    
    %% Make sure that the outPath exists, if not make the directory
    if ~exist(outPath, 'dir')
      mkdir(outPath);
    end

    %% go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.mat']);
    
    % go over all test sets and estimate scores
    numTests = length(fileList);
    numTolerances = length(tolerances);
    averagePrecision = zeros(numTests, length(tolerances)); % avrage precisions
    tp = zeros(numTests, numTolerances);
    fp = zeros(numTests, numTolerances);
    fn = zeros(numTests, numTolerances);
    totalPositives = zeros(numTests, 1);
    totalAlternates = zeros(numTests, 1);
    totalRetrieved = zeros(numTests, 1);
    uniqueCorrect = zeros(maxToAnnotate, numTests, numTolerances);
    for k = 1:numTests
        annotData = [];
        testFile = [inPath filesep fileList(k).name];
        load(testFile); % load annotData
        if isempty(annotData)
            warning('%s: has no annotData\n', testFile);
            continue;
        end
        labels = annotData.trueLabels;
        theMap = containers.Map('KeyType', 'char', 'ValueType', 'char');
        for n = 1:length(labels)
            [~, classIndex] = getClassMask(labels, targetClasses{n});
            if sum(strcmpi(labels{m}, targetClass)) > 0
                totalPositives(k) = totalPositives(k) + 1;
                theMap(num2str(m)) = 't';
            elseif sum(strcmpi(alternateClasses, labels{m})) > 0
                totalAlternates(k) = totalAlternates(k) + 1;
            end
        end
        sampleMask = annotData.wmScores >= annotData.combinedCutoff;
        totalRetrieved(k) = sum(sampleMask);
        [sampleNums, timeTolerance, nearestEvent] = ...
            getTimingTolerance(labels, targetClasses, sampleMask);
        altTolerances = cell(length(alternateClasses), 1);
        altEvents = cell(length(alternateClasses), 1);
        for m = 1:length(alternateClasses)
            [samps, tols, events] = getTimingTolerance(labels, ...
                alternateClasses{m}, sampleMask);
            if sum(abs(sampleNums - samps)) > 0
                error('Samples do not match');
            end
            altTolerances{m} = tols;
            altEvents{m} = events;
        end
        retrievedScores = annotData.wmScores(sampleNums);
        [sortedScores, sortedIndex] = sort(retrievedScores, 'descend');
        sortedTolerance = timeTolerance(sortedIndex);
        nearestSorted = nearestEvent(sortedIndex);
        sortedSampleNums = sampleNums(sortedIndex);
        for m = 1:numTolerances
            toleranceMask = abs(sortedTolerance) <= tolerances(m);
            nearestTolerance = nearestSorted(toleranceMask);
            
            if n <= length(toleranceMask) && toleranceMask(n) ...
                    && isKey(theMap, num2str(nearestSorted(m)))
                remove(theMap, num2str(nearestSorted(m)));
            end
            uniqueCorrect(n, k, m) = totalPositives(k) - length(keys(theMap));
        end
    end
    
end