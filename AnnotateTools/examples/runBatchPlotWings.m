%%
inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
inType = '_reranked_ARRLSMod_';
outType = '_reranked_ARRLSMod__Wings_';
targetClasses = {'34', '35'};
targetClassifiers = {'LDA', 'ARRLS', 'ARRLSMod', 'ARRLSimb'};
params = struct();

%% Process and plot the variables
for m = 1%:length(targetClassifiers)
    for n = 1%:length(targetClasses)
        inPath = [inPathBase '_' targetClassifiers{m} inType targetClasses{n}];
        outPath = [outPathBase '_' targetClassifiers{m} outType targetClasses{n}];
            if ~exist(outPath, 'dir')
               mkdir(outPath)
            end
            fileList = dir([inPath filesep '*.mat']);
            for k = 1%:length(fileList)
                thisFile = [inPath filesep fileList(k).name];
                load(thisFile);
                annotData.classifier = targetClassifiers{m};
                figh = plotWings(annotData, outPath, params);
                %close(figh);
            end
    end
end