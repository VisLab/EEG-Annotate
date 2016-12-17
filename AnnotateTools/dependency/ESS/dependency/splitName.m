function [givenName, familyName, additionalName] = splitName(name)
% [familyName, givenName, additionalName] = splitName(name)
% split a person name to parts adhering to schema.org/Person schema
if isempty(name)
    name = '';
end;

splitName = strsplit(name);

if length(splitName) > 3
    warning('The name %s does not seem to follow a (name family) or (name middle family) pattern and it will be likely parsed incorrectly.', name);
    splitName = splitName(1:3);
end;

switch length(splitName)
    case 1
        % name just hs one part, asume it is family name
        familyName = splitName{1};
        givenName = '';
        additionalName = '';
    case 2
        % no middle name, just first name-space-family name
        givenName = splitName{1};
        familyName = splitName{2};
        additionalName = '';
    case 3
        % assume first name- space-middle name-space - family name
        givenName = splitName{1};
        familyName = splitName{3};
        additionalName =  splitName{2};
end
end