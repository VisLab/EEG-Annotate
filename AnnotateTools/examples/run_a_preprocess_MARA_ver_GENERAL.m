%% Clean EEG data using MARA. general version

clear; close all;

%% parameter for dataset
inPath = 'Z:\Data 4\annotate\VEP\preprocessedRAW\noEx_b1\MARA';
outPath = 'Z:\Data 4\annotate\VEP\preprocessedRAW\noEx_b1\MARA';

%% run
if ~isdir(outPath)   % if the directory is not exist
    mkdir(outPath);  % make the new directory
end

fileList = dir([inPath filesep '*.set']);

% go over all files and apply a feature extraction function
for i=1:length(fileList)
    EEG = pop_loadset(fileList(i).name, inPath);
    
    EEG = cleanMARA(EEG);
    
    save([outPath filesep fileList(i).name(1:end-4) '_MARA.set'], 'EEG', '-v7.3');
end
