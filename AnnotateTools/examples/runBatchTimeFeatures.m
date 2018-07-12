%% This script computes time features for .set files in a directory


%% Set the directories for computing the features
% inDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA_REMAPPED';
% outBasePath = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA_REMAPPED_TIME';

% inDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG_REMAPPED';
% outBasePath = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG_REMAPPED_TIME';

inDir = 'D:\TestData\AnnotateData\VEP_RAW_REMAPPED_1HZ_REF';
outBasePath = 'D:\TestData\AnnotateData\VEP_RAW_REMAPPED_1HZ_REF_TIME';

params = struct();
%% Make sure that the output base directory exists
if ~exist(outBasePath, 'dir')
    mkdir(outBasePath);
end

%% Get the input files 
inPaths = getFiles('FILES', inDir, '.set');

%% Compute the features
outputFileNames = batchTimeFeatures(inPaths, outBasePath, params);
