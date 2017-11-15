function [classMask, classIndex] = getClassMask(labels, classLabel)
%% Extracts a class mask and the class index of the specified classLabel
%
%  Parameters:
%     labels   cell array containing single labels or cell arrays of labels
%     classLabel  string label to be extracted
%     classMask  (output) logical array of length as labels indicating 
%                presence of the classLabel
%     classIndex  (output) array of positions of classLabel in labels
%
% Written by: Kay Robbins, UTSA, 2017
%
classIndex = (1:length(labels))';
classMask = false(size(labels));
for k = 1:length(classMask)
    classMask(k) = sum(strcmpi(labels{k}, classLabel)) > 0;
end
classIndex = classIndex(classMask);