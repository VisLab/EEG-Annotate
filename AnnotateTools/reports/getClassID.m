%% measure the mean average precision (MAP) for the retrieval system
% 
function classID = getClassID(classList, c)

    classID = -1;
    
    for i=1:length(classList)
        for j=1:length(classList{i})
            if strcmp(classList{i}{j}, c)
                classID = i;
                return;
            end
        end
    end
end
