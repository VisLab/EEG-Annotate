function [TP, FP, FN] = getConfusion(targetDist1, targetDist2, tolerance) 
%% Get the performance measures from annotation data
%
%  Parameters:
%      labels

% TP = annotation 2 indicates label within timing tolerance of annotation 1
% FP = annotation 2 indicates label but no label from annotation 1
% FN = annotation 1 indicates label but no label from annotation 2
%
% Written by: Kay Robbins
%
%% 
   TP = sum(abs(targetDist1) <= tolerance);
   FP = sum(abs(targetDist2) > tolerance);
   FN = sum(abs(targetDist1) > tolerance);
