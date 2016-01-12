%% run batch sciprts
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

testPath = 'Z:\Data 3\BCIT_ESS\Level2_256Hz\Experiment X2 Traffic Complexity\session';
testSubPath = 1:28;

trainPath = 'Z:\Data 2\Kyung\autoLabeling\data\AveragePower\zeroMean_unitStd\non_time_locked';
trainName = {'B_01.mat', 'B_02.mat', 'B_03.mat', 'B_04.mat', 'B_05.mat', 'B_06.mat', 'B_07.mat', 'B_08.mat', 'B_09.mat', ...
             'B_10.mat', 'B_11.mat', 'B_12.mat', 'B_13.mat', 'B_14.mat', 'B_15.mat', 'B_16.mat', 'B_17.mat', 'B_18.mat'};

outPath = '.\results';

%% run
myLogs = {};
for t=1:length(testSubPath)
    myLog = batch_drivingData([testPath filesep num2str(testSubPath(t))], trainPath, trainName, [outPath filesep  num2str(testSubPath(t))]);
    myLogs = cat(1, myLogs, myLog);
end
disp(myLogs);
fprintf('Done: batch processing of driving dataset\n');
