%%
inPath = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Annotation_34';
outPath = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_LDA_Annotation_34_Wings';
fileList = dir([inPath filesep '*.mat']);
k = 1;
thisFile = [inPath filesep fileList(k).name];

load(thisFile);
annotData.classifier = 'LDA';
figh = plotWings(annotData, 'trueInWings', true, 'outPath', outPath);