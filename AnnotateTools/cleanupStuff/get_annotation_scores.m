%% get annotation sub-window scores and plot the histogram
% 
%  ex) get_annotation_scores('.\friend\vep_01.mat')
%   
function get_annotation_scores(filePath)

    data = load(filePath);
    
    scores = data.annotData.combinedScore;   % includes zero and non_zero_scores.
    
    non_zero_scores = scores(scores > 0);
    
    figure; 
    hist(non_zero_scores, 30);      % default bin number is 30.
    
    fprintf('there are %d non_zero_scores in %d samples, and estimated cutoff for non_zero_score is %.2f.\n', ...
             length(non_zero_scores), ...
             length(scores), ...
             data.annotData.combinedCutoff);
end

    
    
