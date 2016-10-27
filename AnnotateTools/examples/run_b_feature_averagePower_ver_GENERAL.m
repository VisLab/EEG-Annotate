% %% Example of extracting average power feature
% 

clear; close all;

%% parameter for feature extraction
subbands = [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32];
windowLength = 1.0;
subWindowLength = 0.125;
step = 0.125;

%% parameter for dataset
% inPath = 'Z:\Data 3\BCI2000\BCI2000_Prep_ASR';
% outPath = 'Z:\Data 4\annotate\BCI2000_Prep_ASR\feature\averagePower';
inPath = 'Z:\Data 4\annotate\VEP\preprocessedRAW\noEx_b1\MARA';
outPath = 'Z:\Data 4\annotate\VEP\AveragePower\MARA';
headsetName = 'biosemi64.sfp';

%% run
if ~isdir(outPath)   % if the directory is not exist
    mkdir(outPath);  % make the new directory
end

fileList = dir([inPath filesep '*_MARA.set']);

% go over all files and apply a feature extraction function
for i=1:length(fileList)
    EEG = pop_loadset(fileList(i).name, inPath);
    [data, config, history] = averagePower(EEG, ...
                            'subbands', subbands, ...
                            'windowLength', windowLength, ...
                            'subWindowLength', subWindowLength, ...
                            'step', step, ...
                            'targetHeadset', headsetName);

    save([outPath filesep fileList(i).name(1:end-4) '.mat'], 'data', 'config', 'history', '-v7.3');
end

