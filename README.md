# EEG-Annotate
	A tool to identify particular response in unknown continuous EEG signals

# EEG-Annotate is freely available under the GNU General Public License. 
Please cite the following publication if using: 
> EEG-Annotate: Automated identification and labeling of events 
> in continuous signals with applications to EEG  
> Kyung-min Su, W. David Hairston, Kay Robbins
    

# To run example scripts (tested with MATLAB R2015b)
	- add path to EEGLAB (tested with 13.5.4b)
	- run EEGLAB, if clean_rawdata plugin is not installed, install it (version 0.31)
	- add path to ESS (to use levelDerivedStudy.m)
	- add path to EEG-Clean-Tools\PrepPipeline\utilities (to use vargin2struct.m)
	- add path to this AnnotateTools with Subfolders
	- update data paths in an example script
	- run the example script

# Example scripts (under the examples subdirectory):  

	runBatchClassifier.m  runs a specified classifier for specified  
                          classes for all test files in a directory  
                          to produce a file containing a scoreData structure.    
       
	runBatchAnnotate.m    runs the annotation for all of the files  
                          in a specified directory and produces a  
                          corresponding file containing an annotData  
                          structure.  The input files should each contain  
                          an appropriate scoreData structure.  

	runReport.m           reads a directory of files, each of which contain  
                          an annotData structure and computes the  
                          performance metrics and bootstraps for statistical  
                          significance.  

# Data preparation:  
Before running the annotation pipeline, you must prepare the data to have power features if you are using VEP as training. If you have your own data for training you can prepare both your training and test data using the same features.


# References:
	- EEGLAB: https://sccn.ucsd.edu/eeglab/
	- ESS: http://www.eegstudy.org/
	- EEG-Clean-Tools: http://vislab.github.io/EEG-Clean-Tools/
	- ARRLS:  
         >Adaptation regularization: A general framework for transfer learning  
         >M. Long, J. Wang, G. Ding, S. J. Pan, and P. S. Yu  
         >IEEE Trans. Knowl. Data Eng., vol. 26, no. 5, pp. 1076-1089, May 2014  
	- ARRLSimb:  
         >Adaptive thresholding and reweighting to improve domain transfer  
         >learning for unbalanced data: With applications to EEG imbalance  
         >K. Su, W. D. Hairston, and K. A. Robbins  
         >15th IEEE International Conference on Machine Learning and Applications, 2016  
	
# Support:    
	
    This research was sponsored by the Army Research Laboratory and was 
    accomplished under Cooperative Agreement Number W911NF-10-2-0022. 
    The views and conclusions contained in this document are those of 
    the authors and should not be interpreted as representing the 
    official policies, either expressed or implied, of the 
    Army Research Laboratory or the U.S. Government. The U.S. 
    Government is authorized to reproduce and distribute reprints 
    for Government purposes notwithstanding any copyright notation herein.

    