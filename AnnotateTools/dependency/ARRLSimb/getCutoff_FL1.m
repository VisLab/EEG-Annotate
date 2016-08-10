%%
% See 20160607_integrated_test\getCutoff_fitting_max_n_rest3.m
%
% X : scores
%
% When height is about 0.6065 x (max height), the x = center + sigma or center - sigma.
%
function [cutOff, mu1, sigma1, mu2, sigma2, xgrid] = getCutoff_FL1(X)

    binNumbs = [10 20 25 50 100];   % because histograms sometimes are not smoooth, 
                                    % to get stable results, use more than one histogram with differnet bin numbers.
                                    % and use the average of histograms.
    allCounts = [];
    for binNumb = binNumbs
        xgrid = min(X):(max(X)-min(X))/(binNumb-1):max(X);
        if length(xgrid) < binNumb
            xgrid = cat(2, xgrid, max(X));
        end
        
        counts = hist(X,xgrid);
        binCoeff = 100 / binNumb;
        counts = counts ./ binCoeff;
        counts = repmat(counts, binCoeff, 1);
        counts = counts(:);
        allCounts = cat(2, allCounts, counts);
    end
    counts = mean(allCounts, 2);

    [y_peak, maxI] = max(counts);
    
    y_peak_sigma = y_peak * 0.6065;
    x_peak_sigma1 = inf;
    for i=maxI-1:-1:1
        if counts(i) <= y_peak_sigma
            x_peak_sigma1 = xgrid(i);
            break;
        end
    end
    x_peak_sigma2 = inf;
    for i=maxI+1:length(counts)
        if counts(i) <= y_peak_sigma
            x_peak_sigma2 = xgrid(i);
            break;
        end
    end
    if (x_peak_sigma1 == Inf) && (x_peak_sigma2 == Inf)
        error('sigma estimation fail');
    elseif (x_peak_sigma1 == Inf) && (x_peak_sigma2 ~= Inf)
        mu1 = xgrid(maxI);
        sigma1 = x_peak_sigma2 - mu1;
    elseif (x_peak_sigma1 ~= Inf) &&(x_peak_sigma2 == Inf)
        mu1 = xgrid(maxI);
        sigma1 = mu1 - x_peak_sigma1;
    else
        mu1 = (x_peak_sigma1 + x_peak_sigma2) / 2;
        sigma1 = x_peak_sigma2 - mu1;
    end
    
    y1 = pdf('Normal', xgrid, mu1, sigma1);
    y1 = y1 * y_peak / max(y1);
    
    newCount = counts' - y1;
    newCount(newCount < 0) = 0;
    if mu1 < mean(xgrid)
        newCount(xgrid<mu1) = 0;
    else
        newCount(mu1<xgrid) = 0;
    end
    
    xgrid2 = xgrid(newCount > 0);
    sigma2 = (max(xgrid2)-min(xgrid2))/5;  % not sure how to decide the contant
    y_tmp = pdf('Normal', xgrid, median(xgrid2), sigma2);
                                                           
    newCountWeighted = newCount .* y_tmp;
    mu2 = (newCountWeighted * xgrid') / sum(newCountWeighted);
    
    cutOff = mu1 + (mu2 - mu1) * (sigma1 / (sigma1 + sigma2));
end
