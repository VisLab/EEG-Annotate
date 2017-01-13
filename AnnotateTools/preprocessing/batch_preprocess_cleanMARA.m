function outPath = batch_preprocess_cleanMARA(inPath, varargin)
%   batch_preprocess_cleanMARA() 
%       - Remove artifacts from the all EEG datasets in the inPath using MARA method
%
%   Example:
%       outPath = batch_preprocess_cleanMARA('.\pathIn', 'outPath', '.\pathOut');
%  
%   Inputs:
%       inPat: the pash to the EEG datasets
%   
%   Optional inputs:
%       'outPath': the path to the place where processed EEG datasets will be saved. (default: '.\temp')
%
%   Output:
%       outPath: the path to the place where processed EEG datasets were saved
%
%   Note:
%       It assumes that input data is already PREP and ICA preprocessed.
%       If not, apply PREP and ICA before running calling this function.
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
        EEG = cleanMARA(EEG);
        save([outPath filesep fileList(i).name], 'EEG', '-v7.3');
    end    
end