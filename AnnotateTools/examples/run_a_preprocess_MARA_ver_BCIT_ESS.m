%% Example using ESS for the BCIT to perform ASR cleaning

level2File = 'studyLevelDerived_description.xml';

prefixIn = 'Z:\Data 3\BCIT_ESS\BCIT_ESS_256Hz_ICA_Informax\';
prefixOut = 'Z:\Data 4\annotate\BCIT\BCIT_ESS_256Hz_ICA_Informax_MARA\';

% testNames = {'X3 Baseline Guard Duty'; ...
%             'X4 Advanced Guard Duty'; ...
%             'Experiment X2 Traffic Complexity'; ...
%             'Experiment X6 Speed Control'; ...
%             'Experiment XB Baseline Driving'; 
%             'Experiment XC Calibration Driving'; ...
%             'X1 Baseline RSVP'; ...
%             'X2 RSVP Expertise'};
testNames = {'Experiment XC Calibration Driving'};

for t=1:length(testNames)
    testName = testNames{t};        
    levelDerivedDirIn = [prefixIn testName];   
    levelDerivedDirOut = [prefixOut testName];  

    % Make sure level 2 derived study validates
    derivedXMLFile = [levelDerivedDirIn filesep level2File];
    obj = levelDerivedStudy('parentStudyXmlFilePath', derivedXMLFile);

    % Call the ASR
    callbackAndParameters = {@cleanMARA, {}};    
    obj = obj.createLevelDerivedStudy(callbackAndParameters, ...
          'filterDescription', 'Use MARA to clean the data', ...
         'filterLabel', 'MARA', 'levelDerivedFolder', levelDerivedDirOut);
end