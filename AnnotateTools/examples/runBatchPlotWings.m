%% Set up the paths
inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Annotation';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Annotation';
targetClasses = {'34', '35'};

%% Run the annotation
for k = 1:length(targetClasses)
    inPath = [inPathBase '_' targetClasses{k}];
    fileList = dir([inPath filesep '*.mat']);
    for j = 1:length(fileList)
        load([inPath filesep fileList(k).name]);
        outPath = [outPathBase '_Wings_' targetClasses{k} ];
        annotData.classifier = 'LDA';
        figh = plotTrueInWings(annotData, 'trueInWings', true, 'outPath', outPath);
        close(figh)
    end
end


