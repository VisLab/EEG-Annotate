%% This script computes power features for .set files in a directory


%% Set the directories for computing the features
inDir = 'D:\TestData\AnnotateData\VEP_RAW_REMAPPED';
outBasePath = 'D:\TestData\AnnotateData\VEP_RAW_REMAPPED_1HZ_REF';


%% Make sure that the output base directory exists
if ~exist(outBasePath, 'dir')
    mkdir(outBasePath);
end

%% Get the input files 
inPaths = getFiles('FILES', inDir, '.set');

%% Compute the features
outputFileNames = batchReferenceFilter(inPaths, outBasePath);
