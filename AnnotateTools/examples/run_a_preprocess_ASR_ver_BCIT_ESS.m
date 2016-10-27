%% Example using ESS for the BCIT to perform ASR cleaning

level2File = 'studyLevelDerived_description.xml';

prefixIn = 'Z:\Data 3\BCIT_ESS\Level2_256Hz\';
prefixOut = 'Z:\Data 3\BCIT_ESS\Level2_256Hz_ASR\';

testNames = {'X3 Baseline Guard Duty'; ...
            'X4 Advanced Guard Duty'; ...
            'Experiment X2 Traffic Complexity'; ...
            'Experiment X6 Speed Control'; ...
            'Experiment XB Baseline Driving'; 
            'Experiment XC Calibration Driving'; ...
            'X1 Baseline RSVP'; ...
            'X2 RSVP Expertise'};

for t=1:length(testNames)
    testName = testNames{t};        
    levelDerivedDirIn = [prefixIn testName];   
    levelDerivedDirOut = [prefixOut testName];  

    % Make sure level 2 derived study validates
    derivedXMLFile = [levelDerivedDirIn filesep level2File];
    obj = levelDerivedStudy('parentStudyXmlFilePath', derivedXMLFile);

    % Call the ASR
    callbackAndParameters = {@cleanASR3, {'burstCriterion', 20}};    
    obj = obj.createLevelDerivedStudy(callbackAndParameters, ...
          'filterDescription', 'Use ASR to clean the data', ...
         'filterLabel', 'ASR', 'levelDerivedFolder', levelDerivedDirOut);
end