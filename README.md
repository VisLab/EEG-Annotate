# EEG-Annotate
	A tool to identify particular response in unknown continuous EEG signals

# To run example scripts (tested with MATLAB R2015b)
	- add path to EEGLAB (tested with 13.5.4b)
	- run EEGLAB, if clean_rawdata plugin is not installed, install it (version 0.31)
	- add path to ESS (to use levelDerivedStudy.m)
	- add path to EEG-Clean-Tools\PrepPipeline\utilities (to use vargin2struct.m)
	- add path to this AnnotateTools with Subfolders
	- update data paths in an example script
	- run the example script

# Example scripts
	run_typeX_classifierY.m under /AnnotateTools/examples/
  
	typeX: 
		type1: training data is VEP dataset, test data is VEP dataset
		type2: training data is VEP dataset, test data is Driving dataset
	classifierY:
		LDA: Linear Discriminant Analysis
		ARRLS: Adaptation Regualization based Transfer Learning classifer by Long et al.
		ARRLSimb: ARRLS classifier modified to handle imbalance by Kyung et al.

# References
	- EEGLAB: https://sccn.ucsd.edu/eeglab/
	- ESS: http://www.eegstudy.org/
	- EEG-Cleaan-Tools: http://vislab.github.io/EEG-Clean-Tools/
	- ARRLS: M. Long, J. Wang, G. Ding, S. J. Pan, and P. S. Yu, “Adaptation regularization: A general framework for transfer learning,” IEEE Trans. Knowl. Data Eng., vol. 26, no. 5, pp. 1076–1089, May 2014
	- ARRLSimb: K. Su, W. D. Hairston, and K. A. Robbins, “Adaptive thresholding and reweighting to improve domain transfer learning for unbalanced data With applications to EEG imbalance,” in 15th IEEE International Conference on Machine Learning and Applications, 2016
	
	
