function [] = batchMapToCommonChannels(inPaths, outPaths, baselocs)
%% Map EEG to common channels
%  
%  Parameters:
%    inPaths          cell array of path names for EEG files to extract features
%    outPaths         cell array of full path output filenames
%    params           structure that overrides defaults
%
% Features have same name as the EEG files, but extension .mat not .set
%  
%  Written by: Kyung Mu Su and Kay Robbins 2016-2017, UTSA
%
    

    %% Process datasets to compute power features
    numDatasets = length(inPaths);
    for k = 1:numDatasets
        EEG = pop_loadset(inPaths{k});
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
        [thePath, ~, ~] = fileparts(outPaths{k});
        if ~exist(thePath, 'dir')
           mkdir(thePath);
        end 
        save(outPaths{k}, 'EEG', '-v7.3');
    end
end
            