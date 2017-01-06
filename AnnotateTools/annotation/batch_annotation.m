%% Estimate annotation scores using the annotator
%  
%  Parameters:
%       inPat: the pash to the classification scores
%       outPath: the path to the place where estimated scores are saved
%
function outPath = batch_annotation(inPath, varargin)

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
    fileList = dir([inPath filesep '*.mat']);
    for i=1:length(fileList)
        readData = load([inPath filesep fileList(i).name]);
        annotData = annotator(readData.scoreData, i, varargin{:});
        try 
            fileName = [outPath filesep fileList(i).name];
            save(fileName, 'annotData', '-v7.3');
        catch ME
            if strcmp(ME.identifier, 'MATLAB:save:unableToWriteToMatFile') % if filename is too long
                delete(fileName);      % remove the error file
                annotData.originalFileName = fileList(i).name;
                fileName = [outPath filesep 'file_' num2str(i, '%02d') '.mat'];
                save(fileName, 'annotData', '-v7.3');
                fprintf('file_%02d.mat <== %s\n', i, fileList(i).name);
            else
                rethrow(ME);
            end
        end
    end
end