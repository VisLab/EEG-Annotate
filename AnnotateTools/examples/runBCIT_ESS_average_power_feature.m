%% Example of extracting average power feature

level2DerivedFile = 'studyLevelDerived_description.xml';
%level2DerivedDir = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\Experiment X2 Traffic Complexity';
level2DerivedDir = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\X4 Advanced Guard Duty';
featureOutDir = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_feature\averagePower\Experiment X2 Traffic Complexity';

%% Create a level 2 derevied study
derivedXMLFile = [level2DerivedDir filesep level2DerivedFile];
obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);

[filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);







% obj2 = level2Study('level2XmlFilePath', derivedXMLFile);
% 
% 
% % load the container in to a MATLAB object
% obj = level2Study('level2XmlFilePath', 'Z:\Data 3\BCIT_ESS\Level2_256Hz\Experiment X2 Traffic Complexity\');
% 
% % get all the recording files 
% filenames = obj.getFilename;
% 
% 
% 
% 
% 
% % obj2 = level2Study('level2XmlFilePath', level2DerivedDir);
% % 
% % 
% % obj2 = level2Study('level2XmlFilePath', level2DerivedDir);
% % obj2.validate();       % what it is? Kyung
% % 
% %% Get the files out
% [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = ...
%     getFilename(obj);
% 
% % go over all recording and apply a function
% subbands = [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32];
% filterOrder = 844;
% windowLength = 1.0;
% subWindowLength = 0.125;
% step = 0.125;
% for i=1:length(filenames)
%     [path, name, ext] = fileparts(filenames{i});
%     EEG = pop_loadset([name ext], path);
% 	feature = averagePower(EEG, ...
%                             'subbands', [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32], ...
%                             'filterOrder', 844, ...
%                             'windowLength', 1.0, ...
%                             'subWindowLength', 0.125, ...
%                             'step', 0.125);
%                         
%     save([outDir filesep saveFile], 'feature', '-v7.3');
% end;

% 
% % %% Make sure level 2 derived study validates
% % derivedXMLFile = [levelDerivedDir filesep level2File];
% % obj = levelDerivedStudy('parentStudyXmlFilePath', derivedXMLFile);
% 
% %% Call the average power feature extraction
% callbackAndParameters = {@averagePower, ...
%                             {'subbands', [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32], ...
%                              'filterOrder', 844, ...
%                              'windowLength', 1.0, ...
%                              'subWindowLength', 0.125, ...
%                              'step', 0.125}};    
% obj = obj.createLevelDerivedStudy(callbackAndParameters, ...
%       'filterDescription', 'Extract average power feature', ...
%      'filterLabel', 'average power', 'levelDerivedFolder', levelDerivedDirFeature);
 