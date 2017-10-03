function reportPath = bootstrapPrecision(reportPath, numBootstraps)
%% Generate bootstraps to calculate the statistical significance of report.
%
%  Parameters:
%     reportPath     full filename of the input report
%     numBootstraps  number of bootstrap samples to compute
%

%% Handle the parameters
subwindowRange = 7;

%% Load the report file
report = load([reportPath filesep 'precisionRecall.mat']);
tolerances = report.tolerances;

%% Initialize the variables to save the results

numTolerances = length(tolerances);
targetClasses = report.targetClasses;
targetNum = report.targetNum;
totalPositives = report.totalPositives;
numTests = length(totalPositives);
totalPositivesAll  = report.totalPositivesAll;
totalRetrieved = report.totalRetrieved;
totalRetrievedAll= report.totalRetrievedAll;

%% Initialize the stats structure
precisionStats = cell(numTolerances, 1);
precisionAllStats = cell(numTolerances, 1);
recallStats = cell(numTolerances, 1);
recallAllStats = cell(numTolerances, 1);
averagePrecisionStats = cell(numTolerances, 1);
averagePrecisionAllStats = cell(numTolerances, 1);
for m = 1:numTolerances
    precisionStats{m}(numTests) = getStatStructure();
    precisionAllStats{m}(numTests) = getStatStructure();
    recallStats{m}(numTests) = getStatStructure();
    recallAllStats{m}(numTests) = getStatStructure();
    averagePrecisionStats{m}(numTests) = getStatStructure();
    averagePrecisionAllStats{m}(numTests) = getStatStructure();
end

%% Compute the performance
for k = 1:numTests
    fprintf('Bootstrapping %d\n', k);
    labels = report.labels{k};
    numLabels = length(labels);
    numSamples = report.totalRetrieved(k);
    precisionBootstrap = zeros(numTolerances, numBootstraps);
    recallBootstrap = zeros(numTolerances, numBootstraps);
    aPrecisionBootstrap = zeros(numTolerances, numBootstraps);
    precisionAllBootstrap = zeros(numTolerances, numBootstraps);
    recallAllBootstrap = zeros(numTolerances, numBootstraps);
    aPrecisionAllBootstrap = zeros(numTolerances, numBootstraps);
    for n = 1:numBootstraps
        [sampleMask, actualNumSamples] = ...
            getRandomSampleMask(numLabels, numSamples, subwindowRange);
        if actualNumSamples ~= numSamples
            warning('Bootstrap %d test %d: samples should be %d but is %d', ...
                n, k, numSamples, actualNumSamples);
        end
        scores = rand(length(labels), 1);
        
        %% Calculate performance for the targetNum class
        [totalPositivesB, totalRetrievedB, precisionBootstrap(:, n), ...
            recallBootstrap(:, n),aPrecisionBootstrap(:, n)] = getPerformance(labels, ...
            scores, targetClasses(targetNum), tolerances, sampleMask);
        if totalPositives(k) ~= totalPositivesB
            warning('Bootstrap %d test %d: total positives should be %d but is %d', ...
                n, k, totalPositives(k), totalPositivesB);
        end
        if totalRetrieved(k) ~= totalRetrievedB
            warning('Bootstrap %d test %d: total retrieved should be %d but is %d', ...
                n, k, totalRetrieved{k}, totalRetrievedB);
        end
        
        %% Calculate performance when all targetClasses are considered hits
        [totalPositivesAllB, totalRetrievedAllB, ...
            precisionAllBootstrap(:, n), recallAllBootstrap(:, n), aPrecisionAllBootstrap(:, n)]...
            = getPerformance(labels, scores, targetClasses, tolerances, sampleMask);
        if totalPositivesAll(k) ~= totalPositivesAllB
            warning('Bootstrap %d test %d: total positives all should be %d but is %d', ...
                n, k, totalPositivesAllB(k), totalPositivesAllB);
        end
        if totalRetrievedAll(k) ~= totalRetrievedAllB
            warning('Bootstrap %d test %d: total retrieved allshould be %d but is %d', ...
                n, k, totalRetrievedAllB(k), totalRetrievedAllB);
        end
    end
    for m = 1:numTolerances
        precisionStats{m}(k) = ...
            getStats(precisionBootstrap(m, :), report.precision(k, m));
        precisionAllStats{m}(k) = ...
            getStats(precisionAllBootstrap(m, :), report.precisionAll(k, m));
        recallStats{m}(k) = ...
            getStats(recallBootstrap(m, :), report.recall(k, m));
        recallAllStats{m}(k) = ...
            getStats(recallAllBootstrap(m, :), report.recallAll(k, m));
        averagePrecisionStats{m}(k) = ...
            getStats(aPrecisionBootstrap(m, :), report.averagePrecision(k, m));
        averagePrecisionAllStats{m}(k) = ...
            getStats(aPrecisionAllBootstrap(m, :), report.averagePrecisionAll(k, m));
    end
    
end


fprintf('to here');
%% Save the results
save([reportPath filesep 'precisionRecallStats.mat'], 'labels', 'scores', ...
    'tolerances', 'sampleMask', 'totalPositives', ...
    'totalRetrieved', 'precisionStats',  'recallStats', 'averagePrecisionStats', ...
    'totalPositivesAll',  'totalRetrievedAll', 'precisionAllStats', ...
    'recallAllStats', 'averagePrecisionAllStats', '-v7.3');


end

function stats = getStats(bootstrap, actualValue)
    stats = getStatStructure();
    stats.value = actualValue;
    stats.mean = mean(bootstrap);
    stats.std = std(bootstrap);
    [~, p, ci, zval] = ztest(actualValue, stats.mean, stats.mean, ...
                             'Tail', 'right');
    stats.p = p;
    stats.ci = ci;
    stats.zval = zval;
    [f, x] = ecdf(bootstrap(:));
    stats.eProb = f;
    stats.eData = x;
end

function statStruct = getStatStructure()
    statStruct = struct('value', NaN, 'mean', NaN, 'std', NaN', 'p', NaN, ...
        'zval', NaN', 'ci', NaN, 'eProb', NaN, 'eData', NaN);
end