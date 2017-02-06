function theNames = getDataFromPath(thePaths, baseName)
% Extracts the fileNames without the 

   theNames = getNames(thePaths);
   thePositions = strfind(theNames, baseName);
   theMask = cellfun(@isempty, thePositions);



end