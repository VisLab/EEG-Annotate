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
inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
inType = '_reranked_ARRLSMod_';
outType = '_reranked_ARRLSMod__WingsBig_';
% inType = '_Annotation_';
% outType = '_Annotation_Wings_';
targetClasses = {'34', '35'};
%targetClassifiers = {'LDA', 'ARRLS', 'ARRLSMod', 'ARRLSimb'};
targetClassifiers = {'ARRLSimb'};
params = struct();
params.wingPlotSize = 65;
%% Process and plot the variables
for m = 1:length(targetClassifiers)
    for n = 1:length(targetClasses)
        inPath = [inPathBase '_' targetClassifiers{m} inType targetClasses{n}];
        outPath = [outPathBase '_' targetClassifiers{m} outType targetClasses{n}];
            if ~exist(outPath, 'dir')
               mkdir(outPath)
            end
            fileList = dir([inPath filesep '*.mat']);
            for k = 1:length(fileList)
                thisFile = [inPath filesep fileList(k).name];
                load(thisFile);
                annotData.classifier = targetClassifiers{m};
                figh = plotTrueInWings(annotData, outPath, params);
                close(figh);
            end
    end
end