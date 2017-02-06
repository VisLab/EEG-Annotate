function [structOut, errors] = checkAnnotateDefaults(structIn, structOut, defaults)
% Check structIn input parameters against defaults put in structOut
errors = cell(0);
fNames = fieldnames(defaults);
for k = 1:length(fNames)
    try
       nextValue = getAnnotateStructureParameters(structIn, fNames{k}, ...
                                          defaults.(fNames{k}).value);
       validateattributes(nextValue, defaults.(fNames{k}).classes, ...
                         defaults.(fNames{k}).attributes);
       structOut.(fNames{k}) = nextValue;
    catch mex
        errors{end+1} = [fNames{k} ' invalid: ' mex.message]; %#ok<AGROW>
    end
end