%% Get the labels
fileName = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG\vep_01.set';
EEG = pop_loadset(fileName);
test = load('baseChannelLocations.mat');