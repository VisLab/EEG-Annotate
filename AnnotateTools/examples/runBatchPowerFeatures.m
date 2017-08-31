%% This script computes power features for .set files in a directory


%% Set the directories for computing the features
% inDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA';
% outBasePath = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA_averagePower';
% params = struct();
inDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG';
outBasePath = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG_averagePower';
params = struct();

%% Make sure that the output base directory exists
if ~exist(outBasePath, 'dir')
    mkdir(outBasePath);
end

%% Get the input files 
inPaths = getFiles('FILES', inDir, '.set');

%% Compute the features
outputFileNames = batchPowerFeatures(inPaths, outBasePath, params);
