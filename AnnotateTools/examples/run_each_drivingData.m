%% run sciprts
% 
%  - from RAW EEG to annotated EEG
%  - use EEGLAB v13.4.4b  (including clean_rawdata 0.31)
% 
%  - Input1: a test dataset (.set)
%  - Input2: multiple training dataset (.mat) 
%  - Output: one annotated test dataset (.mat)

%%
close all; clear; clc;

%% parameters
pop_editoptions('option_single', false, 'option_savetwofiles', false);

testPath = 'Z:\Data 3\BCIT_ESS\Level2_256Hz\Experiment X2 Traffic Complexity\session\1';
testName = 'eeg_studyLevelDerived_resample__Experiment_X2_Traffic_session_1_subject_1_task_Conditi_H,LH,HL)_ARL_BC__R4_EEG_CIB_recording_1.set';
% testPath = 'Z:\Data 3\BCIT_ESS\Level2_256Hz\Experiment X2 Traffic Complexity\session\2';
% testName = 'eeg_studyLevelDerived_resample__Experiment_X2_Traffic_session_2_subject_1_task_Conditi_H,HH,LL)_ARL_BC__R2_EEG_oVG_recording_1.set';

trainPath = 'Z:\Data 2\Kyung\autoLabeling\data\AveragePower\zeroMean_unitStd\non_time_locked';
trainName = {'B_01.mat', 'B_02.mat', 'B_03.mat', 'B_04.mat', 'B_05.mat', 'B_06.mat', 'B_07.mat', 'B_08.mat', 'B_09.mat', ...
             'B_10.mat', 'B_11.mat', 'B_12.mat', 'B_13.mat', 'B_14.mat', 'B_15.mat', 'B_16.mat', 'B_17.mat', 'B_18.mat'};

%% load a test dataset
% make sure the double precision data
EEG = pop_loadset('filepath', testPath, 'filename', testName);
EEG.data = double(EEG.data);

tic
%% PREP 
% assume the PREPed data

%% remove external channel
noExEEG = removeExternal(EEG, 1);

%% remove artifacts
cleanEEG = cleanASR3_drivingData(noExEEG, 20);
delete('temp.sfp'); % remove a temporary file (optional)

%% extract feature
%  avearge power in a window
%  (apply 8 sub-bands and 8 sub-windows)
subbands = [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32];
filterOrder = 844;
windowLength = 1.0;     % the length of a window
subLength = 0.125;      % in Second, the length of sub-windows (to keep temporal information)
subStep = 0.125;       
[testSample, testLabel] = extractFeature_averagePower(cleanEEG, subbands, filterOrder, windowLength, subLength, subStep);

%% estimate score 
% using ARRLS
targetClass = '35';     % in the training set, which class is a target?
% ARRLS option
options.p = 10;             % keep default
options.sigma = 0.1;        % keep default
options.lambda = 10.0;      % keep default
options.gamma = 1.0;        % [0.1,10]
options.ker = 'linear';        % 'rbf' | 'linear'
[scores, predLabels] = estimateScores(testSample, trainPath, trainName, targetClass, options);
toc
save([testName(1:end-3) 'mat']);

%% plot results (optional)
% after weighting and zero-out for each training subject
weights = [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]';
position = 8;    % weights 
cutOffPercent= 1;
plot_prediction_n_true_events_cutOffPercent(scores, weights, position, trainName, testLabel, cutOffPercent);


