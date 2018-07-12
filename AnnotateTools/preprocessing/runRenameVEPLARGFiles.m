%% This renames the files to be according to the VEP LARG
inDir = 'D:\temp5\VEP\run_12\ARL_VEP';
outDir = 'D:\TestData\AnnotateData\VEP_PREP_ICA_VEP2_LARG';

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

%% Number subjects
numSubjects = 18;
for k = 1:numSubjects
    thisFile = [inDir filesep 'recording_' num2str(k) filesep 'EEG.set'];
    EEG = pop_loadset(thisFile);
    newName = sprintf('vep_%02d.set', k);
    save([outDir filesep newName], 'EEG', '-v7.3');
end