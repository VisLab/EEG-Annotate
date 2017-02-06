%% Set up the directories
inDirData = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower';
% targetClass = '34';
% inDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34';
% outDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_34';

targetClass = '35';
inDir = 'D:\Research\Annotate\Kyung\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_35';
outDir = 'D:\Research\Annotate\Kay\Data\VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLimb_35';
%% Set up the filenames
numberFiles = 18;
theFiles = cell(numberFiles, 1);
inFiles = cell(numberFiles, 1);
for k = 1:numberFiles
    theName = sprintf('vep_%02d.mat', k);
    theFiles{k} = [inDir filesep theName];
    inFiles{k} = [inDirData filesep theName];
end

for k = 1:numberFiles
    load(theFiles{k});
    scoreDataOld = scoreData;
    clear scoreData;
    inName = inFiles{k};
    [~, theName, ~] = fileparts(inName);
    scoreData = convertOld(scoreDataOld, inName, inFiles);
    save([outDir filesep theName '_' targetClass '.mat'], 'scoreData', '-v7.3');
end
