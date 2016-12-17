% Copyright © Qusp 2016. All Rights Reserved.
classdef levelStudy
    methods
        function obj = levelStudy(varargin)
            add_ess_path_if_needed;           
        end;
        
        function [STUDY, studyFilenameAndPath] = createEeglabStudy(obj, studyFolder, varargin)
            % studyFilenameAndPath = createEeglabStudy(obj, studyFolder, {key, value pairs})
            % Create an EEGLAB Study in a separate folder with its own EEGLAb dataset files from the ESS container.
            %
            %	Key			Value
            %	'taskLabel'		: A cell array containing task labels to indicate the subset of files to be used.
            %	'studyFileName'		: Create two files per EEG dataset. Saves the structure without the data in a Matlab
            %				  ''.set'' file and the transposed data in a binary float ''.dat'' file.
            %	'makeTwoFilesPerSet'	: Create two files per EEG dataset. Saves the structure without the data in a Matlab
            %				  ''.set'' file and the transposed data in a binary float ''.dat'' file.
            %	'dataQuality'		: {'Good' 'Suspect' 'Unusable'}	, Acceptable data quality values. A cell array containing a combination of acceptable data quality values (Good, Suspect or Unusbale).
            %                         this is only supported in Level 2 and Derived containers and will be ignored for Level 1 (since data is raw)
            % 	'forTest'			: Logical, For Debugging ONLY. Process a small data sample for test.
            
            
            inputOptions = arg_define(varargin, ...
                arg('taskLabel', {},[],'Label(s) for session tasks. A cell array containing task labels.', 'type', 'cellstr'), ...
                arg('studyFileName', '', [],'Create two files per EEG dataset. Saves the structure without the data in a Matlab ''.set'' file and the transposed data in a binary float ''.dat'' file.', 'type', 'char'),...
                arg('makeTwoFilesPerSet', true, [],'Create two files per EEG dataset. Saves the structure without the data in a Matlab ''.set'' file and the transposed data in a binary float ''.dat'' file.', 'type', 'logical'),...
                arg('dataQuality', {'Good'},{'Good' 'Suspect' 'Unusable'},'Acceptable data quality values. A cell array containing a combination of acceptable data quality values (Good, Suspect or Unusbale)', 'type', 'cellstr'), ...
                arg('forTest', false,[],'Process a small data sample for test.', 'type', 'logical') ...
                );
            
            if ~exist(studyFolder, 'dir')
                mkdir(studyFolder);
            end;
            
            
            if ismember(class(obj), {'level2Study', 'levelDerivedStudy'})
                titleFromESSContainer = obj.title;
                
                if strcmp(class(obj),'level2Study')
                    studyDescription = obj.level1StudyObj.studyDescription;
                    studyShortDescription = obj.level1StudyObj.studyShortDescription;
                else % We need to define a method for getting description out
                    parentObj = obj.parentStudyObj;
                    while ~strcmp(class(parentObj),'level1Study')
                        switch class(parentObj)
                            case 'level2Study'
                                parentObj = parentObj.level1StudyObj;
                            case 'levelDerivedStudy'
                                parentObj = parentObj.parentStudyObj;
                        end;
                    end;
                    studyDescription = parentObj.studyDescription;
                    studyShortDescription = parentObj.studyShortDescription;
                end;
            else
                titleFromESSContainer = obj.studyTitle;
                studyDescription = obj.studyDescription;
                studyShortDescription = obj.studyShortDescription;
            end;
            
            if isempty(inputOptions.studyFileName)
                if isempty(titleFromESSContainer)
                    inputOptions.studyFileName = 'study_from_ess.study';
                else
                    nameForStudy = level1Study.removeForbiddenWindowsFilenameCharacters(titleFromESSContainer(1:min(end,22)));
                    nameForStudy = strtrim(nameForStudy);
                    nameForStudy(nameForStudy == ' ') = '_';
                    inputOptions.studyFileName = ['study_from_ess_' nameForStudy '.study'];
                end;
            end;
            
            if ismember(class(obj), {'level2Study', 'levelDerivedStudy'})
                [filename, dataRecordingUuid, taskLabel, sessionNumber, level2DataRecordingNumber, subject] = getFilename(obj, 'includeFolder', true, 'taskLabel', inputOptions.taskLabel, 'dataQuality', inputOptions.dataQuality); %#ok<ASGLU>
            else % Level 1
                [filename, dataRecordingUuid, taskLabel, sessionNumber, level1DataRecordingNumber, subject, sessionTaskNumber] = getFilename(obj, 'includeFolder', true, 'taskLabel', inputOptions.taskLabel); %#ok<ASGLU>
            end
            
            fileSessionFolder = {};
            clear ALLEEG;
            counter = 1;
            for i=1:length(filename)
                fileSessionFolder{i} = [studyFolder filesep sessionNumber{i}];
                if ~exist(fileSessionFolder{i}, 'dir')
                    mkdir(fileSessionFolder{i});
                end;
                
                [loadPath name ext] = fileparts(filename{i}); %#ok<NCOMMA>
                if ismember(class(obj), {'level2Study', 'levelDerivedStudy'})   % level 2 and derived
                    if inputOptions.makeTwoFilesPerSet
                        EEG = pop_loadset([name ext], loadPath);
                        pop_saveset(EEG, 'filename', [name ext], 'filepath', fileSessionFolder{i}, 'savemode', 'twofiles', 'version', '7.3');
                        clear EEG;
                    else
                        copyfile(filename{i}, [fileSessionFolder{i} filesep name ext]);
                    end;
                else % level 1
                    
                    % read data
                    if ~isempty(obj.essFilePath)
                        level1FileFolder = fileparts(obj.essFilePath);
                        
                        if isempty(obj.rootURI)
                            rootFolder = level1FileFolder;
                        elseif obj.rootURI(1) == '.' % if the path is relative, append the current absolute path
                            rootFolder = [level1FileFolder filesep obj.rootURI(2:end)];
                        else
                            rootFolder = obj.rootURI;
                        end;
                    else
                        rootFolder = obj.rootURI;
                    end;
                    
                    fileFinalPath = filename{i};
                    currentTask = taskLabel{i};
                    channelLocationFullPath = obj.sessionTaskInfo(sessionTaskNumber(i)).subject(1).channelLocations;
                    [EEG, dataRecordingParameterSet, allEEGChannels, allScalpChannels] = loadAndPrepareRawFile(obj, fileFinalPath, ...
                        rootFolder, currentTask, channelLocationFullPath, obj.sessionTaskInfo(sessionTaskNumber(i)).dataRecording(level1DataRecordingNumber(i)).recordingParameterSetLabel, ...
                        obj.sessionTaskInfo(sessionTaskNumber(i)).sessionNumber, level1DataRecordingNumber(i), inputOptions.forTest);
                    
                    pop_saveset(EEG, 'filename', [name '.set'], 'filepath', fileSessionFolder{i}, 'savemode', 'twofiles', 'version', '7.3');
                    clear EEG;
                end;
                
                % load for adding to STUDY, do not load actual data, just
                % info
                EEG = pop_loadset('filename', [name '.set'], 'filepath', fileSessionFolder{i}, 'loadmode', 'info');
                
                % remove the tracking field added by BCILAB since some data
                % might not have it and produce an error when aggregating
                % EEG datasets into a single ALLEEG structure
                if isfield(EEG, 'tracking')
                    EEG = rmfield(EEG, 'tracking');
                end;
                
                if isempty(subject(i).labId)
                    EEG.subject = ['subject_of_session_' sessionNumber{i}];
                else
                    EEG.subject = subject(i).labId;
                end;
                if ~isempty(subject(i).group)
                    EEG.group = subject(i).group;
                end;
                
                if counter == 1
                    ALLEEG = EEG;
                else
                    ALLEEG(end+1) = EEG;
                end;
                clear EEG;
                counter = counter + 1;
            end;
            
            % make a study from all the files
            pop_editoptions('option_storedisk', true); % keep only maximum one dataset data in memory
            STUDY = pop_study([], ALLEEG, 'updatedat', 'on', 'name', titleFromESSContainer, 'notes', studyDescription, 'task', studyShortDescription);
            STUDY.filename = inputOptions.studyFileName;
            STUDY.filepath = studyFolder;
            STUDY = pop_savestudy( STUDY, ALLEEG, 'filename', inputOptions.studyFileName, 'filepath', studyFolder);
            studyFilenameAndPath = [studyFolder filesep inputOptions.studyFileName];
        end;
        
        function EEG = addUsertagsToEEG(level1StudyObj, EEG, currentTask)
            % add usertags based on (eventcode,hed string) associations for
            % the task.
            
            % perform a sanity check on EEG.urevents
            if length(EEG.urevent) < length(EEG.event)
                fprintf('There are less events in EEG.urevent than in EEG.event.\r This suggest that EEG.ureventis not valid. It will be reconstructed from EEG.event.\n');
                EEG.urevent = EEG.event;
                if isfield(EEG.urevent, 'urevent')
                    EEG.urevent = rmfield(EEG.urevent, 'urevent');
                end;
                for i=1:length(EEG.event)
                    EEG.event(i).urevent = i;
                end;
            end;
            
            studyEventCode = {level1StudyObj.eventCodesInfo.code};
            studyEventCodeTaskLabel = {level1StudyObj.eventCodesInfo.taskLabel};
            
            studyEventCodeHedString = {};
            for i = 1:length(level1StudyObj.eventCodesInfo)
                studyEventCodeHedString{i} = level1StudyObj.eventCodesInfo(i).condition.tag;
                
                % add tags for label and description if they do not already exist
                hedTags = strtrim(strsplit(studyEventCodeHedString{i}, ','));
                labelTagExists = strfind(lower(hedTags), 'event/label/');
                descriptionTagExists = strfind(lower(hedTags), 'event/description/');
                
                if all(cellfun(@isempty, labelTagExists))
                    studyEventCodeHedString{i} = [studyEventCodeHedString{i} ', Event/Label/' level1StudyObj.eventCodesInfo(i).condition.label];
                end;
                
                if all(cellfun(@isempty, descriptionTagExists))
                    studyEventCodeHedString{i} = [studyEventCodeHedString{i} ', Event/Description/' level1StudyObj.eventCodesInfo(i).condition.description];
                end;
            end;
            
            currentTaskMask = strcmp(currentTask, studyEventCodeTaskLabel);
            
            for i=1:length(EEG.event)
                type = EEG.event(i).type;
                if isnumeric(type)
                    type = num2str(type);
                end;
                eventType{i} = type;
                
                id = currentTaskMask & strcmp(eventType{i}, studyEventCode);
                if any(id)
                    eventHedString = studyEventCodeHedString{id};
                else
                    eventHedString = '';
                end;
                
                EEG.event(i).usertags = eventHedString; % usertags should be a string (not a cell array of tags)
                EEG.urevent(i).usertags = EEG.event(i).usertags;
                
                % make sure event types are strings.
                if isnumeric(EEG.event(i).type)
                    EEG.event(i).type = num2str(EEG.event(i).type);
                end;
                if isnumeric(EEG.urevent(i).type)
                    EEG.urevent(i).type = num2str(EEG.urevent(i).type);
                end;
                
            end;
        end;
        
        function [EEG, dataRecordingParameterSet, allEEGChannels, allScalpChannels, allEEGChannelLabels, allChannelLabels, allChannelTypes] = loadAndPrepareRawFile(level1StudyObj, fileFinalPath, rootFolder, currentTask, channelLocationFullPath, recordingParameterSetLabel, sessionNumber, recordingNumber, forTest)
            % [EEG, allEEGChannels, allScalpChannels, allEEGChannelLabels, allChannelLabels, allChannelTypes] = loadAndPrepareRawFile(level1StudyObj, fileFinalPath, currentTask, channelLocationFullPath)
            % read raw EEG data, assign channel labels and types and add hed
            % tags based on events.
            
            % since io_loadset() assigns arbitrary labels when
            % EEG.chanlocs is empty, we use pop_loadset for
            % .set  files
            
            
            if nargin < 9
                forTest = false; % only load the first 10 seconds of data
            end;
            
            [pathstr, nameOfFile,extensionOfFile] = fileparts(fileFinalPath);
            if strcmpi(extensionOfFile, '.set')
                EEG = pop_loadset([nameOfFile extensionOfFile], pathstr);
            else
                if forTest % for test only
                    EEG = exp_eval(io_loadset(fileFinalPath, 'timerange', [1 10]));
                else % load all the data
                    EEG = exp_eval(io_loadset(fileFinalPath));
                end;
            end;
            
            channelLabelsAreMadeUp = false;
            for qqi = 1:length(EEG.chanlocs)
                if strcmp(EEG.chanlocs(qqi).labels, num2str(qqi))
                    channelLabelsAreMadeUp = true;
                else
                    channelLabelsAreMadeUp = false;
                    break;
                end
            end;
            if channelLabelsAreMadeUp
                EEG.chanlocs = [];
            end;
            
            % add HED tags based on events
            if ~strcmpi(level1StudyObj.eventSpecificationMethod, 'Tags')
                EEG = addUsertagsToEEG(level1StudyObj, EEG, currentTask);
            end;
            
            % find EEG channels subsets
            dataRecordingParameterSet = [];
            for kk = 1:length(level1StudyObj.recordingParameterSet)
                if strcmpi(level1StudyObj.recordingParameterSet(kk).recordingParameterSetLabel, recordingParameterSetLabel)
                    dataRecordingParameterSet = level1StudyObj.recordingParameterSet(kk);
                    break;
                end;
            end;
            
            if isempty(dataRecordingParameterSet)
                % ToDo: Throw a better error message
                error('RecordingParameterSet label is not valid');
            end;
            
            % find EEG channels
            allEEGChannels = [];
            allScalpChannels = [];
            allEEGChannelLabels = {};
            allChannelLabels = {}; % the label for each channel, whether it be EEG, MocaP..
            allChannelTypes = {}; % the type of each channel
            for m = 1:length(dataRecordingParameterSet.modality)
                
                startChannel = str2double(dataRecordingParameterSet.modality(m).startChannel);
                endChannel   = str2double(dataRecordingParameterSet.modality(m).endChannel);
                newChannels = startChannel:endChannel;
                newChannelLabels = strtrim(strsplit(dataRecordingParameterSet.modality(m).channelLabel, ','));
                
                allChannelTypes(newChannels) = {dataRecordingParameterSet.modality(m).type};
                if length(newChannelLabels) == length(newChannels)
                    allChannelLabels(newChannels) = newChannelLabels;
                else
                    error('Number of channel labels does not match start and end channel values');
                end;
                
                if strcmpi(dataRecordingParameterSet.modality(m).type, 'EEG')
                    nonScalpChannelLabels = strtrim(strsplit(dataRecordingParameterSet.modality(m).nonScalpChannelLabel, ','));
                    nonScalpChannel = ismember(lower(newChannelLabels), lower(nonScalpChannelLabels));
                    allEEGChannels = [allEEGChannels newChannels];
                    allScalpChannels = [allScalpChannels newChannels(~nonScalpChannel)];
                    channelLocationType = dataRecordingParameterSet.modality(m).channelLocationType;
                    allEEGChannelLabels = cat(1, allEEGChannelLabels, newChannelLabels);                    
                    newChannelLabels = cat(1, newChannelLabels(:), nonScalpChannelLabels(:))'; %#ok<NASGU>
                end;
            end;
            
            % assign channel type in EEG.chanlocs
            for chanCounter = 1:length(allChannelTypes)
                EEG.chanlocs(chanCounter).type = allChannelTypes{chanCounter};
                
                % place labels from XML into EEG.chanlocs when
                % empty or non-existent.
                if ~isfield(EEG.chanlocs, 'labels') || isempty(EEG.chanlocs(chanCounter).labels)
                    EEG.chanlocs(chanCounter).labels = allChannelLabels{chanCounter};
                elseif strcmpi(allChannelTypes{chanCounter}, 'EEG') && ~strcmpi(EEG.chanlocs(chanCounter).labels, allChannelLabels{chanCounter});
                    % ToDo: make a better error message.
                    keyboard;
                    error('Channel labels from level 1 XML file and EEG recording are inconsistent for %s file.', fileNameFromObj);
                end;
            end;
            
            %ToDo: make it work for multiple subjects and their
            %channel locations.
            % read digitized channel locations (if exists)
            if ~ismember(lower(channelLocationFullPath), {'', 'na'})
                fileFinalPathForChannelLocation = levelStudy.findFile(channelLocationFullPath, rootFolder, sessionNumber, recordingNumber);
                chanlocsFromFile = readlocs(fileFinalPathForChannelLocation);
                
                % check if there are enough channels in EEG.data
                % (at least the size of EEG channels expected).
                if length(allEEGChannelLabels) > size(EEG.data, 1)
                    error('There are less channels in %s file than EEG channels specified by recordingParameterSet %d',  fileNameFromObj, dataRecordingParameterSet);
                end;
                
                % sometimes channel location file does not
                % contain locations for all channels, esp.
                % channels like EXG, Mastoid, EMG.
                if length(chanlocsFromFile) ~= size(EEG.data, 1)
                    labelsFromFile = {chanlocsFromFile.labels};
                    
                    % the the option with more labels, either
                    % from the EEG.chanlocs or from the XML
                    % file.
                    % ToDo: rconsider this if.
                    if length(labelsFromFile) >= length(allChannelLabels)
                        channelLabelsToUse = labelsFromFile;
                    else
                        channelLabelsToUse = allEEGChannelLabels;
                    end;
                    
                    for ccounter = 1:length(allEEGChannels)
                        newLocation = chanlocsFromFile(strcmpi(labelsFromFile, channelLabelsToUse{allEEGChannels(ccounter)}));
                        if isempty(newLocation) && ismember(lower(channelLabelsToUse{allEEGChannels(ccounter)}), lower(allChannelLabels(allScalpChannels)))
                            error('Label %s on the scalp does not have a location associated with it in %s file.', channelLabelsToUse{allEEGChannels(ccounter)}, fileNameFromObj);
                        elseif ~isempty(newLocation)
                            fieldNames = fieldnames(newLocation);
                            for fieldCounter = 1:length(fieldNames)
                                EEG.chanlocs(allEEGChannels(ccounter)).(fieldNames{fieldCounter}) = newLocation.(fieldNames{fieldCounter});
                            end;
                        end;
                    end;
                    
                end;
            elseif strcmp(channelLocationType, '10-20') % if channels are based on 10-20 syste try assigning channel locations by matching labels to known 10-20 montage standard locations in BEM (MNI head) model
                EEG = pop_chanedit(EEG, 'lookup', 'standard_1005.elc');
            end;
        end
        
        function runShellCommandOnFiles(obj, shellString, fileType)
            % runShellCommandOnFiles(shellString, fileType)
            % Lets you execute a shell (OS) command on each of the data
            % recording, events (or both types) file.
            % The shellString must contact a %s where the name of the file
            % goes. For example 'chmod %s' will run 'chmod' command on each of the files.
            %
            % 'fileType' is a cell array with types of files to be included ('eeg', 'event', or both)
            
            if ischar(fileType)
                fileType = {fileType};
            end;
            
            if isempty(strfind(shellString, '%s'))
                error('Input ''shellString'' is missing ''%s''.');
            end;
            
            fullFile = {};
            for i=1:length(fileType)
                fullFile = cat(2, fullFile, obj.getFilename('filetype', fileType{i}));
            end;
            
            for i=1:length(fullFile)
                eval(sprintf(['!' shellString], ['''' fullFile{i} '''']));
            end;
        end;
                
        function obj = combinePartialRuns(obj, partFolders, finalFolder)
            % obj = combinePartialRuns(obj, partFolders, finalFolder)
            %
            % Combine multiple partial runs of Level2 or LevelDerived (
            % functions 'createLevel2Study', and 'createLevelDerivedStudy')
            % with a subset of sessions (e.g. to accelerate computation)
            % , into one container (object). Files are copied from partial-run
            % folders to the final folder. The function also performs valiation 
            % at the end.
            %
            % Inputs:
            % partFolders         : cell array of string of folders
            %                       containing partial runs
            % finalFolder         : the folder in which the combined container 
            %                       to be placed.
            %
            % Outout:
            % obj                 : the object representing the final,
            %                       combined ESS container.
            %
            % Example (for Level 2):
            % 
            % >> obj = level2Study;
            % >> partFolders = {'c:\...\part1\' 'c:\...\part2\' .. };
            % >> finalFolder = 'c:\...\final\'
            % >> obj = obj.combinePartialRuns(partFolders, finalFolder);
            %
            %
            % Example (for Level-Derived):
            % 
            % >> obj = levelDerivedStudy;
            % >> partFolders = {'c:\...\part1\' 'c:\...\part2\' .. };
            % >> finalFolder = 'c:\...\final\'
            % >> obj = obj.combinePartialRuns(partFolders, finalFolder);
            
            switch class(obj)
                case 'level1Study'
                    error('This fynction currently works only for levels 2 or derived');
                case 'level2Study'
                    partObj = level2Study;
                    for i =1:length(partFolders)
                        partObj(i) = level2Study('level2XmlFilePath', [partFolders{i} filesep 'studyLevel2_description.xml']);
                    end;
                    
                    filesFieldName = 'studyLevel2Files';
                    fileFieldName = 'studyLevel2File';
                    
                case 'levelDerivedStudy'
                    partObj = levelDerivedStudy;
                    for i =1:length(partFolders)
                        partObj(i) = levelDerivedStudy('levelDerivedXmlFilePath', [partFolders{i} filesep 'studyLevelDerived_description.xml']);
                    end;
                    
                    filesFieldName = 'studyLevelDerivedFiles';
                    fileFieldName = 'studyLevelDerivedFile';
            end;
            
            combinedObj = partObj(1);
            allFilters = partObj(1).filters.filter;
            for i =2:length(partObj)
                combinedObj.(filesFieldName).(fileFieldName) = cat(1, combinedObj.(filesFieldName).(fileFieldName), partObj(i).(filesFieldName).(fileFieldName));
                allFilters = cat(1, allFilters,  partObj(i).filters.filter);
            end;
            
            % order sessions            
            [filename, dataRecordingUuid, taskLabel, sessionNumber, levelDerivedDataRecordingNumber, subjectInfo] = getFilename(combinedObj);
            [dummy ord] = sort(str2double(sessionNumber), 'ascend');
            combinedObj.studyLevelDerivedFiles.studyLevelDerivedFile = combinedObj.studyLevelDerivedFiles.studyLevelDerivedFile(ord);
                        
            finalFilters = uniqe_struct(allFilters);
            combinedObj.filters.filter = finalFilters;
            
            % copy files
            mkdir(finalFolder);
            copyfile(partFolders{1}, finalFolder);
            for i = 2:length(partObj)
                copyfile([partFolders{i} filesep 'session'], [finalFolder filesep 'session']);
            end;
            
            % if Level2, combine reports
            if isa(obj, 'level2Study')
                combinedText = '';
                for i =1:length(partFolders)
                    fid =  fopen([partFolders{i} filesep 'summaryReport.html']);
                    text = fread(fid, Inf, 'char=>char');
                    combinedText = [combinedText; text];
                    fclose(fid);
                end;
                fid =  fopen([finalFolder filesep 'summaryReport.html'], 'w');
                fprintf(fid, '%s', combinedText);
                fclose(fid);
            end;
            
            switch class(obj)
                case 'level2Study'
                    combinedObj = combinedObj.write([finalFolder filesep 'studyLevel2_description.xml']);
                case 'levelDerivedStudy'
                    combinedObj = combinedObj.write([finalFolder filesep 'studyLevelDerived_description.xml']);
            end;
            
            combinedObj = combinedObj.validate;
            obj = combinedObj;
        end;
        
          function writeJSONP(obj, essFolder)
            % writeJSONP(obj, essFolder)
            % write ESS container manifest data as a JSONP (JSON with a function wrapper) in manifest.js file.
%             if nargin < 2
%                 essFolder = fileparts(obj.essFilePath);
%             end;
            
            if ~exist(essFolder, 'dir')
                mkdir(essFolder);
            end;
            
            json = getAsJSON(obj);
            
            fid= fopen([essFolder filesep 'manifest.js'], 'w');
            fprintf(fid, '%s', ['receiveEssDocument(' json ');']);
            fclose(fid);
        end;
        
        function copyJSONReportAssets(obj, essFolder)
%             if nargin < 2
%                 essFolder = fileparts(obj.essFilePath);
%             end;
            
            thisClassFilenameAndPath = mfilename('fullpath');
            essDocumentPathStr = fileparts(thisClassFilenameAndPath);
            % copy index.html
            copyfile([essDocumentPathStr filesep 'asset' filesep 'index.html'], [essFolder filesep 'index.html']);
            
            % copy javascript and CSS used in index.html
            copyfile([essDocumentPathStr filesep 'asset' filesep 'web_resources' filesep '*'], [essFolder filesep 'web_resources']);
        end;
    end
    methods (Static)
        function fileFinalPathOut = findFile(fileNameFromObjIn, rootFolder, sessionNumber, recordingNumber)
            % search for the file both next to the xml file and in the standard ESS
            % convention location
            nextToXMLFilePath = [rootFolder filesep fileNameFromObjIn];
            fullEssFilePath = [rootFolder filesep 'session' filesep sessionNumber filesep fileNameFromObjIn];
            
            if ~isempty(fileNameFromObjIn) && exist(fullEssFilePath, 'file')
                fileFinalPathOut = fullEssFilePath;
            elseif ~isempty(fileNameFromObjIn) && exist(nextToXMLFilePath, 'file')
                fileFinalPathOut = nextToXMLFilePath;
            elseif ~isempty(fileNameFromObjIn) % when the file is specified but cannot be found on disk
                fileFinalPathOut = [];
                fprintf('File %s specified for data recoding %d of sesion number %s does not exist, \r         i.e. cannot find either %s or %s.\n', fileNameFromObjIn, recordingNumber, sessionNumber, nextToXMLFilePath, fullEssFilePath);
                fprintf('You might want to run validate() routine.\n');
            else % the file name is empty
                fileFinalPathOut = [];
                fprintf('You have not specified any file for data recoding %d of sesion number %s\n', recordingNumber, sessionNumber);
                fprintf('You might want to run validate() routine.\n');
            end;
        end
    end
end