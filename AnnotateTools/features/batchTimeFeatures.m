function outputFileNames = batchTimeFeatures(inPaths, outPathBase, params)
%% Perform power feature extraction on a list of files.
%  
%  Parameters:
%    inPaths          cell array of path names for EEG files to extract features
%    outPathBase      path name to the base directory
%    params           structure that overrides defaults
%    outputFileNames  (output) cell array of full paths to feature files
%
% Features have same name as the EEG files, but extension .mat not .set
%  
%  Written by: Kyung Mu Su and Kay Robbins 2016-2017, UTSA
%
    %% Set up the defaults and process the input arguments
    params = processAnnotateParameters('batchTimeFeatures', nargin, 2, params);

    %% Make sure that the outPathBase exists, if not make the directory
    if ~exist(outPathBase, 'dir')
      mkdir(outPathBase);
    end
    
    %% Process datasets to compute power features
    numDatasets = length(inPaths);
    outputFileNames = cell(numDatasets, 1);
    for k = 1:numDatasets
       
        EEG = pop_loadset(inPaths{k});
        [~, theName, ~] = fileparts(inPaths{k});
        EEG = pop_resample(EEG, 128);
        [samples, labels] = timeFeatures(EEG, params); %#ok<ASGLU>
        save([outPathBase filesep theName '.mat'], 'samples', 'labels', '-v7.3');
    end
end
            