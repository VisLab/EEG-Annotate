% % This annotation example runs the following five batch scripts.
% 
%  1) Preprocess
%  2) Feature extraction
%  3) Score estimation1: classification score of sub-window samples
%  4) Score estimation2: annotation score of window samples
%  5) Report
% 
%  Reference:
%  Kyung-min Su, W. David Hairston, Kay Robbins, "Automated annotation for continuous EEG data", 2016
%  
%  Kyung-min Su, The University of Texas at San Antonio, 2016-11-07
% 

clear; close all;

% 0) Parameters
pathInTrain = 'Z:\Data 3\VEP\VEP_PrepClean_Infomax';   % it is already PREP and ICA processed, otherwise I need to run PREP and ICA
pathInTest = 'Z:\Data 3\BCIT_ESS\BCIT_ESS_256Hz_0p5Hz_Cleaned_ICA_Extended';   
pathTemp = 'D:\temp';
pathOutput = '.\output\type2_ARTLimb_34';  % '35'
trainTargetClass = '34';  % '35'
testTargetClasses = {'34'};  % '35'
className = 'Friend';  % 'Foe'

experimentName = 'Experiment X6 Speed Control';
level2File = 'studyLevelDerived_description.xml';

pop_editoptions('option_single', false, 'option_savetwofiles', false);
rng('default')

% %% 1) Preprocess
% %  Apply general preprocessings on the raw EEG data
% %  Note: the input data is already PREP and ICA processed.
% %  - The test dataset dedicated pre-processes such as fixing the data length of subject 12
% %  - Remove artifacts using the ASR tool
% %
% %  Note: If EEG is not PREPed, apply PREP and ICA here.
% batch_preprocess_VEP_exclusive(pathInTrain, ...
%              'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2'], ...
%              'boundary', 1);
% batch_preprocess_cleanMARA([pathTemp filesep 'VEP_PREP_ICA_VEP2'], ...
%              'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA']);
% 
% batch_preprocess_BCIT_ESS_exclusive(pathInTest, experimentName, level2File, ...
%              'outPath', [pathTemp filesep 'BCIT_ESS_PREP_ICA_BCIT2'], ...
%              'boundary', 1);
% batch_preprocess_cleanMARA([pathTemp filesep 'BCIT_ESS_PREP_ICA_BCIT2'], ...
%              'outPath', [pathTemp filesep 'BCIT_ESS_PREP_ICA_BCIT2_MARA']);
%          
% %% 2) Feature extraction
% %  Feature: avearge power of subbands and subwindows
% %  Note: to process different headsets data in the same way, 
% %        it generates new EEG data for the target headset 
% %        and extracts features from the new data.
% batch_feature_averagePower([pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA'], ...
%              'outPath', [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower'], ...
%              'targetHeadset', 'biosemi64.sfp', ...
%              'subbands', [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32], ...
%              'windowLength', 1.0, ...
%              'subWindowLength', 0.125, ...
%              'step', 0.125);
% batch_feature_averagePower([pathTemp filesep 'BCIT_ESS_PREP_ICA_BCIT2_MARA'], ...
%              'outPath', [pathTemp filesep 'BCIT_ESS_PREP_ICA_BCIT2_MARA_averagePower'], ...
%              'targetHeadset', 'biosemi64.sfp', ...
%              'subbands', [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32], ...
%              'windowLength', 1.0, ...
%              'subWindowLength', 0.125, ...
%              'step', 0.125);

% %% 3) Classification score of window samples
% %   Using ARRLS classifier or LDA classifier
% %   For training classifiers, use VEP datasets having friend (34) and foe (35) classes
% %   In this test, we use the same (VEP) datasets for training and for test.
% batch_classify_ARTLimb([pathTemp filesep 'BCIT_ESS_PREP_ICA_BCIT2_MARA_averagePower'], ...  % test data
%              [pathTemp filesep 'VEP_PREP_ICA_VEP2_MARA_averagePower'], ...          % training data
%              'outPath', [pathTemp filesep 'BCIT_ESS_PREP_ICA_BCIT2_MARA_averagePower_ARTLimb_' trainTargetClass], ...
%              'targetClass', trainTargetClass, ...
%              'ARRLS_p', 10, ...     % ARRLS parameters
%              'ARRLS_sigma', 0.1, ...
%              'ARRLS_lambda', 10.0, ...
%              'ARRLS_gamma', 1.0, ...
%              'ARRLS_ker', 'linear', ...
%              'IMB_BT', true, ...    % Imbalance related parameters
%              'IMB_AC1', true, ...
%              'IMB_W', [true true false], ...
%              'IMB_AC2', true, ...
%              'fSaveTrainScore', true);
% 
% %% 4) Annotation score of sub-window
% %  Estimate annotation scores from classification scores.
% %  using weighting, zero-out, and fuzzy voting
% batch_annotation([pathTemp filesep 'BCIT_ESS_PREP_ICA_BCIT2_MARA_averagePower_ARTLimb_' trainTargetClass], ...
%              'outPath', [pathOutput filesep 'annotScore'], ...
%              'excludeSelf', false, ...
%              'adaptiveCutoff', true, ...
%              'rescaleBeforeCombining', true, ...
%              'position', 8, ...
%              'weights', [0.5 0.5 0.5 0.5 0.5 1 3 8 3 1 0.5 0.5 0.5 0.5 0.5]);
% 
% %%  5) Report
% %  Generate reports like precision, recall, and plots
% batch_report_RAP([pathOutput filesep 'annotScore'], ...
%              'outPath', [pathOutput filesep 'report'], ...
%              'targetClasses', testTargetClasses, ...   % hit if it is any one of these class
%              'timinigTolerances', 0:7); 
% batch_report_recall([pathOutput filesep 'annotScore'], ...
%              'outPath', [pathOutput filesep 'report'], ...
%              'targetClasses', testTargetClasses, ...   % hit if it is any one of these class
%              'timinigTolerances', 0:7, ...
%              'retrieveNumbs', 100:100:500); 
% batch_report_precision([pathOutput filesep 'annotScore'], ...
%              'outPath', [pathOutput filesep 'report'], ...
%              'targetClasses', testTargetClasses, ...   % hit if it is any one of these class
%              'timinigTolerances', 0:7, ...
%              'maxAnnotation', 100); 
batch_plot_allPredictions_binaryEvent([pathOutput filesep 'annotScore'], ...
             'outPath', [pathOutput filesep 'report' filesep 'plotAllScores'], ...
             'sampleSize', 0.125, ...   % length of one sample
             'plotLength', 500, ...     % length showed in a plot, 240frames = 30seconds.
             'plotClasses', {'1111','1121','1211','1221'}, ... 
             'fBinary', false); 

% batch_plot_true_in_wing([pathOutput filesep 'annotScore'], ...
%              'outPath', [pathOutput filesep 'report' filesep 'plotTrueWing'], ...
%              'timingTolerances', 2, ...
%              'offPast', 32, ...
%              'offFuture', 32, ...
%              'titleStr', [className '_No_re_ranking']);   % number of sub-window smaples in each window
%          
%% Done
disp('Done. To save space, you can delete the temp folder.');


%% Driving data event code

%  'plotClasses', {'1111','1121','1211','1221'}, ... 
%  'plotClasses', {'2110','2120','2130','2140','2150','2211','2221','2231','2241','2251','2311','2321','2411','2421','2431','2441','2511','2611','2612','2621','2622','2711'}, ... 
%  'plotClasses', {'3111','3121','3200','3210','3220','3230','3240','3250','3310','3320','3330'}, ... 
%  'plotClasses', {'4111','4121','4200','4210','4220','4230','4311','4411','4421','4501','4511','4521','4531','4541'}, ... 
         
% 1111	Vehicle | Perturbation | Left | Onset
% 1121	Vehicle | Perturbation | Right | Onset
% 1211	Vehicle | Moving | Forward | Onset
% 1221	Vehicle | Moving | Backward | Onset
% 2110	Scenario | StartScenario| NoScenarioCondition | NA
% 2120	Scenario | StartScenario| ScenarioConditionA | NA
% 2130	Scenario | StartScenario| ScenarioConditionB | NA
% 2140	Scenario | StartScenario| ScenarioConditionC | NA
% 2150	Scenario | StartScenario| ScenarioConditionD | NA
% 2211	Scenario | VehiclePassing | TravelLaneBLocked | Onset
% 2221	Scenario | VehiclePassing | OncomingTraffic | Onset
% 2231	Scenario | VehiclePassing | TrafficSlalom | Onset
% 2241	Scenario | VehiclePassing | OvertakeFront | Onset
% 2251	Scenario | VehiclePassing | OvertakeBehind | Onset
% 2311	Scenario | VehicleCrossing | DriverSideFast | Onset
% 2321	Scenario | VehicleCrossing | DriverSideSlow | Onset
% 2411	Scenario | PedestrianPassing | TravelDirectionFarSide| Onset
% 2421	Scenario | PedestrianPassing | OncomingFarSide| Onset
% 2431	Scenario | PedestrianPassing | TravelDirectionNearSide| Onset
% 2441	Scenario | PedestrianPassing | OncomingNearSide| Onset
% 2511	Scenario | PedestrianCrossing | DriverSide | Onset
% 2611	Scenario | RoadSign | SpeedLimit25mph | Onset
%% 2612	Scenario | RoadSign | SpeedLimit25mph | Offset
% 2621	Scenario | RoadSign | SpeedLimit45mph | Onset
%% 2622	Scenario | RoadSign | SpeedLimit45mph | Offset
% 2711	Scenario | ConstructionZone | BarrelAndCone | Onset
% 3111	Environmental | MissionBoundary | DataCollection | Onset
% 3121	Environmental | MissionBoundary | InvalidMeasurement | Onset
% 3200	Environmental | TileChange | TileComplexity0 | NA
% 3210	Environmental | TileChange | TileComplexity1 | NA
% 3220	Environmental | TileChange | TileComplexity2 | NA
% 3230	Environmental | TileChange | TileComplexity3 | NA
% 3240	Environmental | TileChange | TileComplexity4 | NA
% 3250	Environmental | TileChange | Invalid | NA
% 3310	Environmental | RoadCurvatureChange | RoadIsStraight | NA
% 3320	Environmental | RoadCurvatureChange | RoadCurvesLeft| NA
% 3330	Environmental | RoadCurvatureChange | RoadCurvesRight | NA
% 4111	Behavioral | Halt | Planned | Onset
% 4121	Behavioral | Halt | Unplanned | Onset
% 4200	Behavioral | LaneShift | NotMeasuring | NA
% 4210	Behavioral | LaneShift | WithinLane | NA
% 4220	Behavioral | LaneShift | RightOfLane | NA
% 4230	Behavioral | LaneShift | LeftOfLane | NA
% 4311	Behavioral | DriverCorrection | Manual | Onset
% 4411	Behavioral | Collision | NearMiss| Onset
% 4421	Behavioral | Collision | Hit | Onset
% 4501	Behavioral | ObjectViewed | Unknown | Onset
% 4511	Behavioral | ObjectViewed | Speedometer | Onset
% 4521	Behavioral | ObjectViewed | Vehicle | Onset
% 4531	Behavioral | ObjectViewed | Pedestrian | Onset
% 4541	Behavioral | ObjectViewed | RoadSign | Onset
