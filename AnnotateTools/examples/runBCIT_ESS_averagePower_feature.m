% %% Example of extracting average power feature
% 
level2DerivedFile = 'studyLevelDerived_description.xml';

% level2DerivedDir = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\Experiment X6 Speed Control';
% featureOutDir = 'D:\Temp\Data 3\BCIT_ESS\Level2_256Hz_feature\averagePower\Experiment X6 Speed Control';

level2DerivedDir = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\Experiment X2 Traffic Complexity';
featureOutDir = 'D:\Temp\Data 3\BCIT_ESS\Level2_256Hz_feature\averagePower\Experiment X2 Traffic Complexity';
% level2DerivedDir = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\X4 Advanced Guard Duty';
% featureOutDir = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_feature\averagePower\Experiment X6 Speed Control';
% level2DerivedDir = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\X1 Baseline RSVP';   % 256 channels
% featureOutDir = 'D:\Temp\Data 3\BCIT_ESS\Level2_256Hz_feature\averagePower\X1 Baseline RSVP';



%% Create a level 2 derevied study
derivedXMLFile = [level2DerivedDir filesep level2DerivedFile];
obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
%obj.validate();     % do I need to validate it? Kyung

%% Get the file (.set) list
[filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);

%% go over all files and apply a feature extraction function
subbands = [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32];
filterOrder = 844;
windowLength = 1.0;
subWindowLength = 0.125;
step = 0.125;
headsetName = 'biosemi64.sfp';

for i=1:length(filenames)
    [path, name, ext] = fileparts(filenames{i});
    EEG = pop_loadset([name ext], path);
	[data, config] = averagePower(EEG, ...
                            'subbands', subbands, ...
                            'filterOrder', filterOrder, ...
                            'windowLength', windowLength, ...
                            'subWindowLength', subWindowLength, ...
                            'step', step, ...
                            'targetHeadset', headsetName);
                    
    outDir = [featureOutDir filesep 'session' filesep sessionNumbers{i}];
    saveFile = ['averagePower_' name '.mat'];   % new file name = ['averagePower_' old file name];
    if ~isdir(outDir)   % if the directory is not exist
        mkdir(outDir);  % make the new directory
    end
    save([outDir filesep saveFile], 'data', 'config', '-v7.3');
end;

 