%%
% See 20160607_integrated_test\getCutoff_fitting_max_n_rest10.m
%
% X : scores
%
% When height is about 0.6065 x (max height), the x = center + sigma or center - sigma.
% Assumption: the minor (positive) class has the higher score than the major (negative) class
function [cutOff, mu1, sigma1, mu2, sigma2, xgrid] = getCutoffFL(X, maxLoop, cutOffdefault)

    sigmaG = std(X); % global sigma
    
    % detect the peak
    [peak_x, peak_y, peak_i, counts, xgrid] = getLargestPeak(X);
    
    % fitting major curve on the peak
    mu1 = peak_x;

    y_peak_sigma = peak_y * 0.6065;
    x_peak_sigma1 = Inf;
    for i=peak_i-1:-1:1
        if counts(i) <= y_peak_sigma
            x_peak_sigma1 = mu1 - xgrid(i);
            break;
        end
    end
    x_peak_sigma2 = Inf;
    for i=peak_i+1:length(counts)
        if counts(i) <= y_peak_sigma
            x_peak_sigma2 = xgrid(i) - mu1;
            break;
        end
    end
    
    % ver 5: choose the larger one
    % ver 6,7: choose the smaller one
    % ver 8: use the avearage <== this version
    if (x_peak_sigma1 == Inf) && (x_peak_sigma2 == Inf)
        error('sigma estimation fail');
    elseif (x_peak_sigma1 == Inf) && (x_peak_sigma2 ~= Inf)
        sigma1 = x_peak_sigma2;
    elseif (x_peak_sigma1 ~= Inf) &&(x_peak_sigma2 == Inf)
        sigma1 = x_peak_sigma1;
    else
        sigma1 = (x_peak_sigma1 + x_peak_sigma2) / 2;
    end
  
    if sigma1 > sigmaG
        sigma1 = sigmaG * 0.5; % when there is only one big Gaussian, guess the sigma1
    end
    
    y1 = pdf('Normal', xgrid, mu1, sigma1);
    y1 = y1 * peak_y / max(y1);
	
    wFlag = true;
    m = 0;
    adjustFactor = 1;
    while (wFlag && (m<maxLoop))
        y1 = y1 * adjustFactor;

        newCount = counts' - y1;
        newCount(newCount < 0) = 0;
        newCount(1:peak_i) = 0; % leave only the minor class side

        xgrid2 = xgrid(newCount > 0);
        
        if length(xgrid2) > 1
            wFlag = false;
        end
        adjustFactor = adjustFactor * 0.9;
        m = m + 1;
    end
    
    if m == maxLoop
        warning('reach to maxLoop');
        mu2 = [];
        sigma2 = [];
        cutOff = cutOffdefault;
    else
        [mu2, sigma2] = myStat(xgrid, newCount);
        cutOff = mu1 + (mu2 - mu1) * (sigma1 / (sigma1 + sigma2));
    end
end

% get mean and std of the histogram
%
% x : centers of bins
% 
function [muhat, sigmahat] = myStat(x, counts)
 
    p = counts ./ sum(counts);  % probability
    
    muhat = x * p';
    
    tmp = x - muhat;
    tmp = tmp .^ 2;
    tmp = tmp * p';
    
    sigmahat = sqrt(tmp);
end
 