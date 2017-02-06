function theNames = getNames(thePaths)
    theNames = cell(size(thePaths));
    for j = 1:length(theNames)
        [~, theNames{j}, ~] = fileparts(thePaths{j});
    end
end