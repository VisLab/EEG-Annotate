% %% Example of extracting average power feature
% 
level2DerivedFile = 'studyLevelDerived_description.xml';

prefixIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\';
prefixOut = 'D:\Temp\Data 3\BCIT_ESS\Level2_256Hz_feature\averagePower\';

testName = 'Experiment X2 Traffic Complexity'; % 64 channels;
% testName = 'Experiment X6 Speed Control'; 
% testName = 'Experiment XC Calibration Driving'; 
% testName = 'X1 Baseline RSVP'; % 256 channels;
% testName = 'X2 RSVP Expertise'; 
% testName = 'X3 Baseline Guard Duty'; 
% testName = 'X4 Advanced Guard Duty'; 

level2DerivedDir = [prefixIn testName];
featureOutDir = [prefixOut testName]; 

%% Create a level 2 derevied study
derivedXMLFile = [level2DerivedDir filesep level2DerivedFile];
obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
%obj.validate();     % do I need to validate it? Kyung

%% Get the file (.set) list
[filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);

%% go over all files and apply a feature extraction function
subbands = [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32];
windowLength = 1.0;
subWindowLength = 0.125;
step = 0.125;
headsetName = 'biosemi64.sfp';

for i=1:length(filenames)
    [path, name, ext] = fileparts(filenames{i});
    EEG = pop_loadset([name ext], path);
	[data, config, history] = averagePower(EEG, ...
                            'subbands', subbands, ...
                            'windowLength', windowLength, ...
                            'subWindowLength', subWindowLength, ...
                            'step', step, ...
                            'targetHeadset', headsetName);
                    
    outDir = [featureOutDir filesep 'session' filesep sessionNumbers{i}];
    saveFile = ['averagePower_' name '.mat'];   % new file name = ['averagePower_' old file name];
    if ~isdir(outDir)   % if the directory is not exist
        mkdir(outDir);  % make the new directory
    end
    save([outDir filesep saveFile], 'data', 'config', 'history', '-v7.3');
end;

 