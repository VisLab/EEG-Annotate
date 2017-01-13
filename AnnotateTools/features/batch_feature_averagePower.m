function outPath = batch_feature_averagePower(inPath, varargin)
%   batch_feature_averagePower() 
%       - extract average power feature from raw EEG data
%
%   Examples:
%       outPath = batch_feature_averagePower('.\pathIn'); 
%       outPath = batch_feature_averagePower('.\pathIn', 
%             'outPath', '.\pathOut', ...
%             'targetHeadset', 'biosemi64.sfp', ...
%             'subbands', [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32], ...
%             'windowLength', 1.0, ...
%             'subWindowLength', 0.125, ...
%             'step', 0.125);
%
%   Inputs:
%       inPat: the pash to the EEG datasets
%   
%   Optional inputs:
%       'outPath': the path to the place where extracted features will be saved. (default: '.\temp')
%       'targetHeadset': the filename of the target headset (default: [], no interpolation)
%           To process different headsets data in the same way, it can generates new EEG data for the target headset. 
%       'subbands': frequency ranges of each sub-band (default: [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32])
%       'windowLength': the length of a window in second (default: 1 second)
%       'subWindowLength': the length of a sub-window in second (default: 0.125 seconds)
%       'step': the distance between windows in second (default: 0.125 seconds), if step < windowLength, windows are overlapped.
%
%   Output:
%       outPath: the path to the place where extracted features were saved
%
%   Note:
%       It stores extracted samples and their class labels.   
%       samples: 2D array [feature size x number of samples] - each column is one sample
%       labels: a cell array containing class labels of samples.  
%               Each cell might contain more than one string.
%
%   Author:
%       Kyung-min Su, The University of Texas at San Antonio, 2016
%

    %Setup the parameters and reporting for the call   
    params = vargin2struct(varargin);  
    outPath = '.\temp';
    if isfield(params, 'outPath')
        outPath = params.outPath;
    end
    
    if ~isdir(outPath)   % if the directory is not exist
        mkdir(outPath);  % make the new directory
    end

    % go over all files and preprocess them using the specified function
    fileList = dir([inPath filesep '*.set']);
    for i=1:length(fileList)
        EEG = pop_loadset(fileList(i).name, inPath);
        [samples, labels] = averagePower(EEG, varargin{:});
        save([outPath filesep fileList(i).name(1:end-4) '.mat'], 'samples', 'labels', '-v7.3');
    end
end