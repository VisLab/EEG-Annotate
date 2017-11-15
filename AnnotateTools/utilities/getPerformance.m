function [totalPositives, totalRetrieved, precision, recall, averagePrecision] = ...
                      getPerformance(labels, scores, targetClasses, tolerances, sampleMask) 
%% Get the performance measures from annotation data
%
%  Parameters:
%      labels

%%
    numClasses = length(targetClasses);
    numTolerances = length(tolerances);
    positives = zeros(numClasses, 1);
    for n = 1:numClasses
       [~, classIndex] = getClassMask(labels, targetClasses{n});
       positives(n) = length(classIndex);
    end
    totalPositives = sum(positives);
    totalRetrieved = sum(sampleMask);
    [sampleIndex, timeTolerance, nearestEvent] = ...
         getTimingTolerances(labels, targetClasses, sampleMask);
    
    retrievedScores = scores(sampleIndex);
    [sortedScores, sortedIndex] = sort(retrievedScores, 'descend'); %#ok<ASGLU>
    sortedTolerance = timeTolerance(sortedIndex);
    nearestSorted = nearestEvent(sortedIndex);
    maxToAnnotate = length(sortedTolerance);
    recall = zeros(1, numTolerances);
    precision = zeros(1, numTolerances);
    averagePrecision = zeros(1, numTolerances);
    for m = 1:numTolerances
      toleranceMask = abs(sortedTolerance) <= tolerances(m);
      nearestRank = 1:maxToAnnotate;
      nearestRank = nearestRank(toleranceMask);
      nearestEventInTolerance = nearestSorted(toleranceMask);
      uniqueTrueEvents = unique(nearestEventInTolerance);
      if length(uniqueTrueEvents) ~= length(nearestEventInTolerance)
          warning('Tolerance:%d  total unique:%d  total events: %d', ...
              tolerances(m), length(uniqueTrueEvents), ...
              length(nearestEventInTolerance));
      end
      numCorrect = length(nearestEventInTolerance);
      recall(m) = numCorrect/totalPositives;
      precision(m) = numCorrect/maxToAnnotate;
      rankedPrecision = zeros(numCorrect, 1);
      for n = 1:numCorrect
          rankedPrecision(n) = n/nearestRank(n);
      end
      averagePrecision(m) = sum(rankedPrecision)/totalPositives;
    end