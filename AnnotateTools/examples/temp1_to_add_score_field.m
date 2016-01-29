%% utility to add fields to the score structure
%  
%  why transform? to combine score datasets
%

%% set path to test set
level2DerivedFile = 'studyLevelDerived_description.xml';

fileListIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\';	% to get the list of test files
scoreIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_score\';
scoreOut = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_score_addField\';

classifier = 'LDA'; % 'ARRLS'

testName = 'Experiment X2 Traffic Complexity'; % 64 channels;
% testName = 'Experiment X6 Speed Control'; 
% testName = 'Experiment XB Baseline Driving'; 
% testName = 'Experiment XC Calibration Driving'; 
% testName = 'X1 Baseline RSVP'; % 256 channels;
% testName = 'X2 RSVP Expertise'; 
% testName = 'X3 Baseline Guard Duty'; 
% testName = 'X4 Advanced Guard Duty'; 

%% Create a level 2 derevied study
%  To get the list of file names
derivedXMLFile = [fileListIn testName filesep level2DerivedFile];
obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);
[filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);

%% save all scores into one file
load([scoreIn testName '_' classifier '.mat']);

scores = results;

scores.testName = testName;

for fileID=1:length(filenames)
    scores.sessionID{fileID} = sessionNumbers{fileID};
    [path, name, ext] = fileparts(filenames{fileID});
    scores.fileName{fileID} = name;
end
    
if ~isdir(scoreOut)   % if the directory is not exist
	mkdir(scoreOut);  % make the new directory
end
save([scoreOut testName '_' classifier '.mat'], 'scores', '-v7.3');
