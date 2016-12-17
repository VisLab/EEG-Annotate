function hedCellArray = split_HEDstring_to_tags(hedString)
% this function handles commas in patenthesis. Commas inside paranthesis
% do not distinguish HED tags.

if isempty(hedString)
    hedCellArray = {};
    return;
end;

% add an extra comma to the end to facilitate segmenting the last tag.
if hedString(end) ~= ','
    hedString = [hedString ','];
end;

parenthesisDepth = 0;
breakPoint = [];
for i=1:length(hedString)
    switch  hedString(i) 
        case'('
        parenthesisDepth = parenthesisDepth + 1;
        case ')'
        parenthesisDepth = parenthesisDepth - 1;
        case ','
            if parenthesisDepth == 0
                breakPoint = [breakPoint i];
            end;
    end;
end;

if parenthesisDepth ~= 0
    error('Numbers of opening and closing parenthesis in string %s are different.', hedString);
end;

if isempty(breakPoint)
    breakPoint = length(hedString);
end;

lastBreakPoint = 0;
hedCellArray = {};
for i=1:length(breakPoint)
    hedCellArray{i} = hedString((lastBreakPoint+1):(breakPoint(i)-1));
    lastBreakPoint = breakPoint(i);
end;

% remove before and after spaces.
hedCellArray = strtrim(hedCellArray);

% remove empty strings
hedCellArray(cellfun(@isempty, hedCellArray)) = [];