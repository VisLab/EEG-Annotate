%% Example using ESS for the BCIT to perform Highpass filtering

level2File = 'studyLevelDerived_description.xml';
levelDerivedDir = 'Z:\Data 3\BCIT_ESS\Level2_256Hz\X3 Baseline Guard Duty';
levelDerivedDirNew = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_HP\X3 Baseline Guard Duty';

%% Make sure level 2 derived study validates
derivedXMLFile = [levelDerivedDir filesep level2File];
obj = levelDerivedStudy('parentStudyXmlFilePath', derivedXMLFile);

%% Call the ASR
callbackAndParameters = {@highpassNew, {'cutoff', 0.5}};    
obj = obj.createLevelDerivedStudy(callbackAndParameters, ...
      'filterDescription', 'Use pop_eegfiltnew to highpass filtering', ...
     'filterLabel', 'HP', 'levelDerivedFolder', levelDerivedDirNew);
