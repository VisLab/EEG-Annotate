%% This script compares two versions of the annotation and computes confusion
%
% The results are written as annotData structures to files
%
%% Set the directories for input and output as well as the other parameters
inPathBase1 = 'D:\Research\Annotate\Kay\Data2\VEP_PREP_ICA_VEP2_MARA_averagePower';
inPathBase2 = 'D:\Research\Annotate\Kay\Data2\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data2\VEP_Reports';
targetClass = '34';
targetClassifier = 'ARRLSimb';
params = struct();
outType = 'VEP_MARAverPowARRLSimb_Vs_MARAAverPowARRLSimb_';
tolerances = [0, 1, 2, 3];

%% Perform the annotation
inPath1 = [inPathBase1 '_' targetClassifier '_Annotation_' targetClass];
inPath2 = [inPathBase2 '_' targetClassifier '_Annotation_' targetClass];
if ~exist(outPathBase, 'dir')
    mkdir(outPathBase);
end
for m = 1:length(tolerances)
    outName = [outPathBase filesep outType '_Class_' targetClass ...
        '_Tol_' num2str(tolerances(m)) ];
    outName = reportComparison(inPath1, inPath2, outName, tolerances(m));
end

