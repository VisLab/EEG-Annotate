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
  *.m under /AnnotateTools/examples/
  run_type1_ : training data is VEP dataset, test data is VEP dataset
  run_type2_ : training data is VEP dataset, test data is Driving dataset
