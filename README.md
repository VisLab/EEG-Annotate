# EEG-Annotate
Tools for annotating continuous EEG signals

# To run example scripts
- add path to EEGLAB (tested with 13.5.4b)
- run EEGLAB, if clean_rawdata plugin is not installed, install it (version 0.31)
- add path to ESS\Ess_tools
- add path to EEG-Clean-Tools\PrepPipeline\utilities (to use vargin2struct.m)
- add path to this AnnotateTools with Subfolders
- update path in the example script
- run an example script (tested with MATLAB R2015a)

# Suggested order of running examples
1) runBCIT_ESS_ASR_Cleaning.m : cleaning raw EEG 
2) runBCIT_ESS_averagePower_feature.m : extracting feature (average power)
3) runBCIT_ESS_LDA_classification.m : estimating scores of test samples (using LDA classifier)

