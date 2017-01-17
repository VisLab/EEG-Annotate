%% To annotate EEG datasets, this example script runs the following five jobs in batch.
% 
%   1) Preprocess
%   2) Feature extraction
%   3) Score estimation1, estiamting classification score of window samples
%   4) Score estimation2, estimating annotation score of sub-window samples
%   5) Report
% 
%   Reference:
%       Kyung-min Su, W. David Hairston, Kay Robbins, "Automated annotation for continuous EEG data", 2016
%  
%   Author:
%       Kyung-min Su, The University of Texas at San Antonio, 2016
% 

clear; close all;

% 0) Parameters
pathIn = 'Z:\Data 3\VEP\VEP_PrepClean_Infomax';   
% path to input raw EEG data in .set format. 
% Assume, they have been already PREP and ICA processed.

pathTemp = 'D:\temp';
% path to store temporary data

pathOutput = '.\output\type1_ARTLorg_34';  % '34', '35'
% path to store annotation scores and reports

trainTargetClass = '34';  % '34', '35'
% positive class

testTargetClasses = {'34'};  % '34', '35'
% in a report, show these events in test data

className = 'Friend';  % 'Friend', 'Foe'
% name of the positive class

pop_editoptions('option_single', false, 'option_savetwofiles', false);
rng('default'); % to reproduce results, keep use the same random seed

%% 1) Preprocess
batch_preprocess_VEP_exclusive(pathIn, ...
             'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2'], ...
             'boundary', 1);
%  The preprocess dedidcated to the VEP dataset
%  - fix the data length of dataset #12 (cut at 600 seconds)
%  - exclude external channels located out of the head area
         
batch_preprocess_cleanMARA([pathTemp filesep 'VEP_PREP_ICA_VEP2'], ...
             'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA']);
%  Remove artifacts using the MARA toolbox

%% 2) Feature extraction
batch_feature_averagePower([pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA'], ...
             'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower'], ...
             'targetHeadset', 'biosemi64.sfp', ...
             'subbands', [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32], ...
             'windowLength', 1.0, ...
             'subWindowLength', 0.125, ...
             'step', 0.125);
%  Feature: avearge power of subbands and subwindows
%  Note: it stores extracted samples and their class labels in the specified output path.
%       samples: 2D array [feature size x number of samples] 
%               Each column is one sample.
%       labels: a cell array containing class labels of samples.  
%               Each cell might contain more than one string.

%% 3) Estimate classification scores of window samples
batch_classify_ARTLorg([pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower'], ...  % test data
             [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower'], ...          % training data
             'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLorg_' trainTargetClass], ...
             'targetClass', trainTargetClass, ...
             'ARRLS_p', 10, ...     % ARRLS parameters
             'ARRLS_sigma', 0.1, ...
             'ARRLS_lambda', 10.0, ...
             'ARRLS_gamma', 1.0, ...
             'ARRLS_ker', 'linear', ...
             'fTrainBalance', true, ...    % Balance training samples
             'fSaveTrainScore', true);
%   Using the ARTLorg classifier (ARRLS: Adaptation Regualization based Transfer Learning classifer)
%   Note:
%       It stores estimated classification scores using the scoreData structure. 
%       scoreData structure has eight fields.
%           testLabel = the cell containing the true labels of test samples
%           predLabel = the cell containing the predicted labels of test samples
%           testInitProb = the cell containing the intial scores 
%           testInitCutoff = the array of intial cutoff
%           testFinalScore = the cell containing the final scores 
%           testFinalCutoff = the array of final cutoff
%           trainLabel = the cell containing the true labels of training samples
%           trainScore = the cell containing the scores of training samples       

%% 4) Estimate annotation scores of window sub-samples
batch_annotation([pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLorg_' trainTargetClass], ...
             'outPath', [pathOutput filesep 'annotScore'], ...
             'excludeSelf', true, ...
             'adaptiveCutoff', true, ...
             'rescaleBeforeCombining', true, ...
             'position', 8, ...
             'weights', [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]);

%%  5) Generate various reports
batch_report_RAP([pathOutput filesep 'annotScore'], ...
             'outPath', [pathOutput filesep 'report'], ...
             'targetClasses', testTargetClasses, ...   % hit if it is any one of these class
             'timinigTolerances', 0:7); 
%  Ranked Average Precision (RAP)

batch_report_recall([pathOutput filesep 'annotScore'], ...
             'outPath', [pathOutput filesep 'report'], ...
             'targetClasses', testTargetClasses, ...   % hit if it is any one of these class
             'timinigTolerances', 0:7, ...
             'retrieveNumbs', 100:100:500); 
% Recall         

batch_report_precision([pathOutput filesep 'annotScore'], ...
             'outPath', [pathOutput filesep 'report'], ...
             'targetClasses', testTargetClasses, ...   % hit if it is any one of these class
             'timinigTolerances', 0:7, ...
             'maxAnnotation', 100); 
% Precision         

batch_plot_allPredictions_VEPevent([pathOutput filesep 'annotScore'], ...
             'outPath', [pathOutput filesep 'report' filesep 'plotAllScores'], ...
             'sampleSize', 0.125, ...   % length of one sample
             'plotLength', 500, ...     % length showed in a plot, 240frames = 30seconds.
             'plotClasses', {'63', '38', '39'; '33', '34', '35'}, ...
             'fBinary', false); 
% Plot predicted positive samples in each test data         

batch_plot_true_in_wing([pathOutput filesep 'annotScore'], ...
             'outPath', [pathOutput filesep 'report' filesep 'plotTrueWing'], ...
             'timingTolerances', 2, ...
             'offPast', 32, ...
             'offFuture', 32, ...
             'titleStr', [className '_No_re_ranking']);   % number of sub-window smaples in each window
         
% Plot true event labels around the predicted positive samples          
         
batch_plot_aligned_window_scores([pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower_ARTLorg_' trainTargetClass], ...
             'outPath', [pathOutput filesep 'report'], ...
             'targetClasses', testTargetClasses, ...
             'excludeSelf', true, ...
             'neighborSize', 10);
% Plot the window scores aligned at sub-window 0     

%% Done
disp('Done. To save space, you can delete the temp folder.');
