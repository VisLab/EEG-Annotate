%% get the largest peak
%
% apply smooth and find the largest peak
%
function [peak_x, peak_y, peak_i, smoothCounts, xgrids] = getLargestPeak_new(X)

    binNumbs = [10 20 25 50 100];   % because histograms sometimes are not smoooth, 
                                    % to get stable results, use more than one histogram with differnet bin numbers.
                                    % and use the average of histograms.
    smoothFilter = [0.2 0.2 0.2 0.2 0.2];

    allCounts = [];
    for binNumb = binNumbs
        xgrids = min(X):(max(X)-min(X))/(binNumb-1):max(X);
        if length(xgrids) < binNumb
            xgrids = cat(2, xgrids, max(X));
        end
        
        counts = hist(X,xgrids);
        binCoeff = 100 / binNumb;
        counts = counts ./ binCoeff;
        counts = repmat(counts, binCoeff, 1);
        counts = counts(:);
        allCounts = cat(2, allCounts, counts);
    end
    counts = mean(allCounts, 2);
    
    smoothCounts = counts;
    for i=3:length(counts)-2
        smoothCounts(i) = smoothFilter * counts(i-2:i+2);
    end
    [peak_y, peak_i] = max(smoothCounts);
    peak_x = xgrids(peak_i);
end