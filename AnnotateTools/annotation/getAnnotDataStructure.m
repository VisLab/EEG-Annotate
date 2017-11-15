function annotData = getAnnotDataStructure()
%% Returns the annotData structure
%
% The fields of the AnnotData structure:
%
%   testFileName    file with the samples to annotate
%   trainFileNames  files with samples used to train classifiers
%   params          parameters for all of the calculations
%   classLabel      the label that was to be annotated
%   trueLabels      the true labels associated with test data (if known)
%   initialCutoffs  initial cutoffs used in the individual classifiers
%   wScores         scores obtained by combination (before zero out)
%   combinedCutoff  final cutoff to be applied to the combined scores
%
% 
annotData = struct('testFileName', NaN, 'trainFileNames', NaN, ...
                   'params', NaN, 'classLabel', NaN, ...
                   'trueLabels', NaN, ...
                   'initialCutoffs', NaN', ...
                   'wScores', NaN, 'wmScores', NaN, ...
                   'combinedCutoff', NaN);