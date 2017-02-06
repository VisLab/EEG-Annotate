%% This script annotates a data collection that has been classified 

%% Set the directories for input and output for LDA
% inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA';
% outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Annotation';
% targetClasses = {'34', '35'};

%% Set the directories for input and output for ARRLSimb
% inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSimb';
% outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSimb_Annotation';
% targetClasses = {'34', '35'};

%% Set the directories for test and training data
inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLS';
outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLS_Annotation';
targetClasses = {'34', '35'};

%% Set the directories for input and output for ARRLSMod
% inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSMod';
% outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARRLSMod_Annotation';
% targetClasses = {'34', '35'};

%% Set the directories for input and output for LDA reranked LDA
% inPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_positive_LDA';
% outPathBase = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_positive_LDA_Annotation';
% targetClasses = {'34', '35'};

%% Run the annotation
for k = 1:length(targetClasses)
  inPath = [inPathBase '_' targetClasses{k}]; 
  outPath = [outPathBase '_' targetClasses{k}]; 
  batchAnnotate(inPath, outPath, targetClasses{k});
end