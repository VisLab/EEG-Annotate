% The following example runs a function on all the recording in the study

% load the container in to a MATLAB object
obj = level2Study('level2XmlFilePath', 'C:\Users\...\[ESS Container Folder]\');

% get all the recording files 
filenames = obj.getFilename;

% go over all recording and apply a function
for i=1:length(filenames)
    [path name ext] = fileparts(filenames{i});
    EEG = pop_loadset([name ext], path);
	EEG = [YOUR FUNCTION](EEG,..)
end;