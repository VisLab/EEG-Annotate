function obj = load_study_container(folderOrXML, verbose)
% obj = load_study_container(folderOrXML, verbose)
% loads all study levels by detecting the type of file or folder provided.

if nargin < 2
    verbose = true;
end;

switch(exist(folderOrXML))
    case 0
        error('file or folder %s does not exist.', folderOrXML);
    case 7 % is a directory
        if exist([folderOrXML filesep 'studyLevelDerived_description.xml'], 'file')
            obj = levelDerivedStudy(folderOrXML);
        elseif exist([folderOrXML filesep 'studyLevel2_description.xml'], 'file')
            obj = level2Study(folderOrXML);
        elseif exist([folderOrXML filesep 'study_description.xml'], 'file')
            obj = level1Study(folderOrXML);
        else
            if verbose
            warning('No container manifest xml file can be found in the directory %s,', folderOrXML);
            end;
            obj = [];
        end
    case 2 % is a file name that exists
        Pref.NumLevels = 1;
        [tree, RootName, DOMnode] = xml_read(folderOrXML, Pref);
        switch(RootName{1})
            case 'studyLevelDerived'
                obj = levelDerivedStudy(folderOrXML);
            case 'studyLevel2'
                obj = level2Study(folderOrXML);
            case 'studyLevel1'
                obj = level1Study(folderOrXML);
        end;
    otherwise
        error('cannot recognize the input argument');
end;
end
