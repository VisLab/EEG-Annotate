function outputFileNames = batchMapToCommonChannels(inPaths, outPathBase, baselocs)
%% Map EEG to common channels
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
        [EEG, omittedLabels, nonMappedLabels] = mapToCommonChannels(EEG, baselocs); %#ok<ASGLU>
        fprintf('%d: omitted: [ ', k);
        for n = 1:length(omittedLabels)
            fprintf('%s ', omittedLabels{n});
        end
        fprintf('] nonmapped: [');
        for n = 1:length(nonMappedLabels)
            fprintf('%s ', nonMappedLabels{n});
        end
        fprintf(']\n');
         
        save([outPathBase filesep theName '.set'], 'EEG', '-v7.3');
    end
end
            