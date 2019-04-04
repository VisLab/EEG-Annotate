%% This script computes power features for .set files in a directory


%% Set the directories for computing the features
% inDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG';
% outBasePath = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG_REMAPPED';

% inDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA';
% outBasePath = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_MARA_REMAPPED';

% inDir = 'D:\TestData\AnnotateData\VEP_RAW';
% outBasePath = 'D:\TestData\AnnotateData\VEP_RAW_REMAPPED';

inDir = 'O:\LARGData\SpeedControl\run_12\ARL_SpeedControl';
outBasePath = 'E:\AnnotateData\ARL_SpeedControl_LARG_Remapped';

commonChannelFile = 'D:\Research\Annotate\EEG-Annotate\AnnotateTools\preprocessing\baseChannelLocs.mat';
test = load(commonChannelFile);
baselocs = test.baseChannelLocs;

%% Make sure that the output base directory exists
if ~exist(outBasePath, 'dir')
    mkdir(outBasePath);
end

%% Get the input files 
inPaths = getFiles('FILES2', inDir, '.set');
outPaths = cell(length(inPaths), 1);
for k = 1:length(inPaths)
    [thePath, theName, theExt] = fileparts(inPaths{k});
    sepInds = strfind(thePath, filesep);
    outPaths{k} = [outBasePath filesep thePath(sepInds(end) + 1:end) '_' theName theExt];
end
%% Compute the features
batchMapToCommonChannels(inPaths, outPaths, baselocs);
