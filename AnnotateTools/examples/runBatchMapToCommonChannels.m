%% This script computes power features for .set files in a directory


%% Set the directories for computing the features
% inDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG';
% outBasePath = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG_REMAPPED';

% inDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA';
% outBasePath = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA_REMAPPED';

inDir = 'D:\TestData\AnnotateData\VEP_RAW';
outBasePath = 'D:\TestData\AnnotateData\VEP_RAW_REMAPPED';

commonChannelFile = 'D:\Research\Annotate\EEG-Annotate\AnnotateTools\preprocessing\baseChannelLocs.mat';
test = load(commonChannelFile);
baselocs = test.baseChannelLocs;

%% Make sure that the output base directory exists
if ~exist(outBasePath, 'dir')
    mkdir(outBasePath);
end

%% Get the input files 
inPaths = getFiles('FILES', inDir, '.set');

%% Compute the features
outputFileNames = batchMapToCommonChannels(inPaths, outBasePath, baselocs);
