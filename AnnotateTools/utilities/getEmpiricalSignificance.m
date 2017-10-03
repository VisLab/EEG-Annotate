function pValue = getEmpiricalSignificance(value, data, prob)
%% Estimates pValue given an empircal cumulative probability distribution
%
%  Parameters:
%     value     value whose pvalue should be estimated
%     data      x values of empirical cumulative probablity distribution
%     prob      cumulative probabilities corresponding to data
%     pValue    (output)  1 - probability of value
%
%  Note: This assumes that (data, prob) begins with (x, 0) and ends with
%  (x, 1).
%
numValues = length(prob);
if prob(1) ~= 0 || prob(numValues) ~= 1
    error('getEmpiricalSignificance:InvalidProb', ...
        'prob does not correspond to an empirical probability distribution');
end
if value >= data(numValues)
    pValue = 0;
elseif value <= data(1)
    pValue = 1;
else
    for m = 2:numValues
        if value == data(m)
            thisProb = prob(m);
        elseif value == data(m - 1);
            thisProb = prob(m - 1);
        else
            slope = (prob(m) - prob(m - 1))/(data(m) - data(m - 1));
            thisProb = slope*(value - data(m - 1)) + prob(m - 1);
        end
        pValue = 1 - thisProb;
    end
end