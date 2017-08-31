function outputFileNames = batchPowerFeatures(inPaths, outPathBase, params)
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
    params = processAnnotateParameters('batchPowerFeatures', nargin, 2, params);

    %% Make sure that the outPathBase exists, if not make the directory
    if ~exist(outPathBase, 'dir')
      mkdir(outPathBase);
    end
    
    %% Process the training-test set pairs using the LDA classifier
    numDatasets = length(inPaths);
    outputFileNames = cell(numDatasets, 1);
    for k = 1:numDatasets
        if params.verbose
            fprintf('Creating power features for %s \n', inPaths{k});
        end
       
        EEG = pop_loadset(inPaths{k});
        [~, theName, ~] = fileparts(inPaths{k});
        [samples, labels] = powerFeatures(EEG, params); %#ok<ASGLU>
        save([outPathBase filesep theName '.mat'], 'samples', 'labels', '-v7.3');
    end
end
            