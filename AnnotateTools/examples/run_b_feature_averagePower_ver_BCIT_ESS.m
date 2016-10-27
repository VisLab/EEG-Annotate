% %% Example of extracting average power feature
% 

%% use double precision
pop_editoptions('option_single', false, 'option_savetwofiles', false);

% parameter for feature extraction
subbands = [0 4; 4 8; 8 12; 12 16; 16 20; 20 24; 24 28; 28 32];
windowLength = 1.0;
subWindowLength = 0.125;
step = 0.125;
headsetName = 'biosemi64.sfp';

% set path
level2DerivedFile = 'studyLevelDerived_description.xml';

prefixIn = 'Z:\Data 4\annotate\BCIT\BE_256Hz_II_MARA\';
prefixOut = 'Z:\Data 4\annotate\BCIT\BE_256Hz_II_MARA_fAP\';

testNames = {'EXB'};

% go over for all tests
for t=1:length(testNames)
    testName = testNames{t};        
    level2DerivedDir = [prefixIn testName]; 
    featureOutDir = [prefixOut testName]; 
    
    % Create a level 2 derevied study
    derivedXMLFile = [level2DerivedDir filesep level2DerivedFile];
    obj = levelDerivedStudy('levelDerivedXmlFilePath', derivedXMLFile);

    % Get the file (.set) list
    [filenames, dataRecordingUuids, taskLabels, sessionNumbers, subjects] = getFilename(obj);

    % go over all files and apply a feature extraction function
    for i=1:length(filenames)
        [path, name, ext] = fileparts(filenames{i});
        EEG = pop_loadset([name ext], path);
        [data, config, history] = averagePower(EEG, ...
                                'subbands', subbands, ...
                                'windowLength', windowLength, ...
                                'subWindowLength', subWindowLength, ...
                                'step', step, ...
                                'targetHeadset', headsetName);

        outDir = [featureOutDir filesep 'session' filesep sessionNumbers{i}];
        saveFile = ['AP_' name '.mat'];   % new file name = ['averagePower_' old file name];
                                          % Aug 28, 2016, because the new file name is too long,
                                          % to shorten, I use 'AP' instead of 'averagePower'
        if ~isdir(outDir)   % if the directory is not exist
            mkdir(outDir);  % make the new directory
        end
        save([outDir filesep saveFile], 'data', 'config', 'history', '-v7.3');
    end
end        

