%%
% inPath = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Annotation_34';
% outPath = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Annotation_34_Wings';

%% Path for ARRLS modified 
% inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSMod_Annotation';
% outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSMod_Annotation_Wings';
% targetClasses = {'34', '35'};
% classifierName = 'ARRLSMod';

%% Path for ARRLS imbalanced
% inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSimb_Annotation';
% outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSimb_Annotation_Wings';
% targetClasses = {'34', '35'};
% classifierName = 'ARRLSimb';

%% Path for ARRLS 
inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLS_Annotation';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLS_Annotation_Wings';
targetClasses = {'34', '35'};
classifierName = 'ARRLS';

%% Process and plot the variables
for n = 1:length(targetClasses)
    inPath = [inPathBase '_' targetClasses{n}];
    outPath = [outPathBase '_' targetClasses{n}];
    if ~exist(outPath, 'dir')
        mkdir(outPath)
    end
    fileList = dir([inPath filesep '*.mat']);
    for k = 1:length(fileList)
        thisFile = [inPath filesep fileList(k).name];
        load(thisFile);
        annotData.classifier = classifierName;
        figh = plotTrueInWings(annotData, 'outPath', outPath);
        close(figh);
    end
end