function [outStructArray, id] = uniqe_struct(inStructArray)
% finds unique tuples, each defined by fields of an structure, in an structure array.

if length(inStructArray) < 1
    outStructArray = [];
    id = [];
    return
end;

outStructArray = inStructArray(1);

id = nan(length(inStructArray), 1);

for i=1:length(inStructArray)

    for j=1:length(outStructArray)
        if isequaln(outStructArray(j), inStructArray(i))
            id(i) = j;
        end;
    end;
    
    if isnan(id(i))
        outStructArray(end+1) = inStructArray(i);
        id(i) = length(outStructArray);
    end;
end;