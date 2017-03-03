%% This script shows how to plot metrics and significance
inDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSimb_Annotation_Reports';
inFile = 'precisionRecallStats.mat';
%outDir = 'D:\Papers\Current\Annotation\Resubmission\figures\performancePlots\Original';
outDir = [];
tols2Plot = 3;
metricNames = {'precision', 'precisionAll', 'recall', 'recallAll', ...
                'averagePrecision', 'averagePrecisionAll'};
classes = {'34', '35'};
theColors = [0.45, 0.45, 0.45; 0.65, 0.65, 0.65; 0.85, 0.85, 0.85];

subjectsGood = [2, 4, 5, 8, 9, 11, 18]';
subjectsMedium = [1, 3, 7, 10, 10, 13, 15, 16]';
subjectsPoor = [6, 12, 14, 17]';

%% Load the file

for n = 1:length(classes)
    theseStats = load([inDir '_' classes{n} filesep inFile]);
    numDatasets = length(theseStats.totalPositives);
    numTolerances = length(theseStats.tolerances);
    
    tolerances = theseStats.tolerances;
    toleranceMask = false(size(tolerances));
    toleranceMask(1:tols2Plot) = true;
    for k = 1:length(metricNames)
        metricName = [metricNames{k} 'Stats'];
        stats = theseStats.(metricName);
        theTitle = ['Metric from class ' classes{n} ' with statistical significance'];
        [figh, metric, pValue] = plotMetric(stats, tolerances, toleranceMask, ...
            metricName, theTitle, theColors);
        if ~isempty(outDir)
            baseName = [outDir filesep metricName '_' classes{n}];
            saveas(figh, [baseName '.fig'], 'fig');
            saveas(figh, [baseName '.png'], 'png');
            saveas(figh, [baseName '.pdf'], 'pdf');
        end
        summary = zeros(4, numTolerances);
        summary(4, :) = mean(metric);
        summary(1, :) = mean(metric(subjectsGood, :));
        summary(2, :) = mean(metric(subjectsMedium, :));
        summary(3, :) = mean(metric(subjectsPoor, :));
        fprintf('\nClass %s: metric %s\n', classes{n},metricNames{k});
        for m = 1:numTolerances
            fprintf('%d:\t%7.3f\t%7.3f\t%7.3f\t%7.3f\n', tolerances(m), ...
                summary(1, m), summary(2, m), summary(3, m), summary(4, m));
        end
  
    end
end