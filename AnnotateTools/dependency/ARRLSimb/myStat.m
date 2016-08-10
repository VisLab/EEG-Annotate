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