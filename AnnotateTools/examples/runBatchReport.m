%% Script to run the performance reports for the annotated data

%% Paths for ARRLS imbalanced
inPathBase = 'D:\Research\Annotate\Kay\Data2\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data2\VEP_PREP_ICA_VEP2_MARA_averagePower';
targetClasses = {'34', '35'};
targetClassifiers = {'ARRLSimb'};
inType = '_Annotation_';
outType = '_Annotation_Reports_';
% inType = '_Annotation_No17_';
% outType = '_Annotation_No17_Reports_';
params = struct();
numBootstraps = 10000;

%% Process the annotData and compute performance and significance
for m = 1:length(targetClassifiers)
    for n = 1:length(targetClasses)
        inPath = [inPathBase '_' targetClassifiers{m} inType targetClasses{n}];
        outPath = [outPathBase '_' targetClassifiers{m} outType targetClasses{n}];
        reportPrecision(inPath, outPath, targetClasses, n, params);
        bootstrapPrecision(outPath, numBootstraps)
    end
end