%%
% See 20160607_integrated_test\getCutoff_fitting_max_n_rest10.m
%
% X : scores
%
% When height is about 0.6065 x (max height), the x = center + sigma or center - sigma.
%
function [cutOff, mu1, sigma1, mu2, sigma2, xgrid] = getCutoff_FL2(X, initCutoff)

    sigmaG = std(X); % global sigma
    
    % detect the peak
    [peak_x, peak_y, peak_i, counts, xgrid] = getLargestPeak_new(X);
    
    % select leftover area
    leftOver = chooseLeftOver(peak_i, counts, xgrid, X, initCutoff);
    
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
    adjustFactor = 1;
    while wFlag
        y1 = y1 * adjustFactor;

        newCount = counts' - y1;
        newCount(newCount < 0) = 0;
        if leftOver == 1  % leave only the minor class side
            newCount(1:peak_i) = 0;
        else
            newCount(peak_i:end) = 0;
        end

        xgrid2 = xgrid(newCount > 0);
        
        if length(xgrid2) > 1
            wFlag = false;
        end
        adjustFactor = adjustFactor * 0.9;
    end
    
    % old way
    %sigma2 = sigmaG - sigma1;
    %mu2 = (newCount * xgrid') / sum(newCount);

    sigma2 = (max(xgrid2)-min(xgrid2))/3;  % not sure how to decide the contant

    y_tmp = pdf('Normal', xgrid, median(xgrid2), sigma2);
                                                           
    newCountWeighted = newCount .* y_tmp; % smooth
    newCountWeighted = newCountWeighted .* y_tmp; % how many times is the best?
    newCountWeighted = newCountWeighted .* y_tmp;
    mu2 = (newCountWeighted * xgrid') / sum(newCountWeighted);
    
    cutOff = mu1 + (mu2 - mu1) * (sigma1 / (sigma1 + sigma2));
end

function leftOver = chooseLeftOver(peak_i, counts, xgrid, score, initCutoff)

    leftOvers = zeros(1, 3);

    initClass = score > initCutoff;    
    
    peak_left_i = peak_i-1;
    if peak_left_i < 1
        peak_left_i = 1;
    end
    peak_right_i = peak_i+1;
    if peak_right_i > length(xgrid)
        peak_right_i = length(xgrid);
    end
    
    pickIdx = (xgrid(peak_left_i) < score) & (score < xgrid(peak_right_i));
    pickClass = initClass(pickIdx);
    if mean(pickClass) > 0.5
        leftOvers(1) = 0;
    else
        leftOvers(1) = 1;
    end
    
    wingLcount = sum(counts(1:peak_left_i));
    wingRcount = sum(counts(peak_right_i:end));
    if wingLcount > wingRcount
        leftOvers(2) = 0;
    else
        leftOvers(2) = 1;
    end
    
    wingLlength = peak_left_i;
    wingRlength = length(xgrid)-peak_i;
    if wingLlength > wingRlength
        leftOvers(3) = 0;
    else
        leftOvers(3) = 1;
    end
    
    if mean(leftOvers) > 0.5
        leftOver = 1;
    else
        leftOver = 0;
    end
end
