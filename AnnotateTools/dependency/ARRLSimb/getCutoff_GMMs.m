%%
% X : scores
%
function [cutOff, GMModel] = getCutoff_GMMs(X, numbReplicates, maxIter, RegularizeationValue)
    
    GMModel = fitgmdist(X, 2, 'Replicates', numbReplicates, 'Options', statset('MaxIter', maxIter), 'RegularizationValue', RegularizeationValue); 
    cutOff = GMModel.mu(1) + (GMModel.mu(2) - GMModel.mu(1)) * (GMModel.Sigma(1) / (GMModel.Sigma(1) + GMModel.Sigma(2)));
end
