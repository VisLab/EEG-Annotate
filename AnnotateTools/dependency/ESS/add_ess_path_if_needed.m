% if dependent files are not in the path, add all file/folders under
% dependency to Matlab path.

% This takes too long in long loops, consier adding a check on time so if last time run was less
% than 5 seconds ago skip the check.

if ~(exist('uniqe_file_to_test_ESS_path', 'file') && exist('is_impure_expression', 'file') &&...
        exist('is_impure_expression', 'file') && exist('PropertyEditor', 'file') && exist('hlp_struct2varargin', 'file') && exist('savejson_for_ess', 'file'))
    thisClassFilenameAndPath = mfilename('fullpath');
    pathstr = fileparts(thisClassFilenameAndPath);
    addpath(genpath([pathstr filesep 'dependency']));
    addpath([pathstr filesep 'unit_test']);
end;