%%
% inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
% outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
% inType = '_';
% outType = '_Wings_';
% targetClasses = {'34', '35'};
% targetClassifiers = {'ARRLSimb'};
% params = struct();
% %%
inPathBase = 'D:\Research\Annotate\Kay\Data1\BCIT_ESS_PREP_ICA_BCIT2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data1\BCIT_ESS_PREP_ICA_BCIT2_MARA_averagePower';
targetClasses = {'34', '35'};
inType = '_Annotation_';
outType = '_Annotation_Wings_';
%targetClassifiers = {'LDA', 'ARRLS', 'ARRLSMod', 'ARRLSimb'};
targetClassifiers = {'ARRLSimb'};
params = struct();
params.wingPlotSize = 65;
%% Process and plot the variables
for m = 1%:length(targetClassifiers)
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
                figh = plotWingsNew(annotData, outPath, params);
                close(figh);
            end
    end
end