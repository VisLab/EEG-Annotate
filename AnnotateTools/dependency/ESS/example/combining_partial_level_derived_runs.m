% This example shows how to combine partial Level-derived runs into a single container

% specify folders containing partial runs, here we use partial runs that
% are a part of ESS unit test. Replace these with your folders.
partialLevelDerivedFolder1 = [fileparts(which('level1Study')) filesep 'unit_test' filesep 'dummy_level_derived_partial_1'];
partialLevelDerivedFolder2 = [fileparts(which('level1Study')) filesep 'unit_test' filesep 'dummy_level_derived_partial_2'];

% specify the folder for the output ESS container which contains partial
% runs. Replace this with your folder name.
combinedDirectory = [tempdir filesep 'dummy_level_derived_combined'];

obj = levelDerivedStudy;
obj = obj.combinePartialRuns({partialLevelDerivedFolder1 partialLevelDerivedFolder2}, combinedDirectory);
