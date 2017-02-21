function [figh, metric, pValue] = plotMetric(stats, tolerances, ...
                        toleranceMask, metricName, theTitle, theColors)
%% Plot value and significance of each subject for specified metric
lowSignificance = 0.05;
highSignificance = 0.001;
numTolerances = length(stats);
numDatasets = length(stats{1});
metric = zeros(numDatasets, numTolerances);
pValue = zeros(numDatasets, numTolerances);
legendStrings = cell(1, numTolerances);
for k = 1:numTolerances
    metric(:, k) = cellfun(@double, {stats{k}.value});
    pValue(:, k) = cellfun(@double, {stats{k}.p});
    legendStrings{k} = ['Tol=' num2str(tolerances(k))];
end

%%
subjectNums = (1:numDatasets)';
pLowMask = pValue > lowSignificance;
pHighMask = pValue <= highSignificance;
pLowMask = pLowMask(:, toleranceMask);
pHighMask = pHighMask(:, toleranceMask);
num2Plot = sum(toleranceMask);
figh = figure('Color', [1, 1, 1], 'Name', theTitle);
hold on
%% Allow user to pass in line colors -- otherwise use default
if size(theColors, 1) < num2Plot
    warning('plotMetric:NotEnoughColors', ...
           'Not enough colors are provided, using defaults');
end
if isempty(theColors) || size(theColors, 1) < num2Plot
    plot(metric(:, toleranceMask), '-', 'Marker', '.', ...
        'MarkerSize', 20, 'LineWidth', 2.5);
else
    for k = 1:num2Plot
        plot(metric(:, k), 'LineStyle', '-', 'Marker', '.', ...
            'MarkerSize', 20, 'LineWidth', 3, 'Color', theColors(k, :));
    end
end
for k = 1:num2Plot
    plot(subjectNums(pHighMask(:, k)), metric(pHighMask(:, k), k), ...
        'k', 'Marker', 's', 'MarkerSize', 10, 'LineWidth', 1.5, 'LineStyle', 'None');
    plot(subjectNums(pLowMask(:, k)), metric(pLowMask(:, k), k), ...
        'r', 'Marker', 'x', 'MarkerSize', 12, 'LineWidth', 3, 'LineStyle', 'None');
end
set(gca, 'YLim', [0, 1], 'XLim', [0, numDatasets + 1], ...
   'FontSize', 12, 'XTick', 1:numDatasets);
legend(legendStrings(toleranceMask), 'Location', 'southoutside', ...
       'Orientation', 'horizontal');
xlabel('Subject');
ylabel(metricName);
title(theTitle)
hold off
box on