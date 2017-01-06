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

# Example scripts
  run_typeX_classifierY.m under /AnnotateTools/examples/
  
  typeX: 
		type1: training data is VEP dataset, test data is VEP dataset
		type2: training data is VEP dataset, test data is Driving dataset
  classifierY:
		LDA: Linear Discriminant Analysis
		ARTLorg: Adaptation Regualization based Transfer Learning (ARTL) by Long et al.
		ARTLimb: ARTL classifier modified to handle imbalance

