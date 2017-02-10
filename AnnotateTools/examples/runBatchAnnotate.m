%% This script annotates a data collection that has been classified 

%% Set the directories for input and output
inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
targetClasses = {'34', '35'};
targetClassifiers = {'LDA', 'ARRLS', 'ARRLSMod', 'ARRLSimb'};
params = struct();

%% Set the directories for input and output for LDA reranked LDA
% inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_positive_LDA';
% outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_positive_LDA_Annotation';
% targetClasses = {'34', '35'};

%% Perform the annotation
for n = 1:length(targetClassifiers)
    for k = 1:length(targetClasses)
        inPath = [inPathBase '_' targetClassifiers{n} '_' targetClasses{k}]; 
        outPath = [outPathBase '_' targetClassifiers{n} '_Annotation_' targetClasses{k}]; 
        batchAnnotate(inPath, outPath, targetClasses{k}, params);
    end
end