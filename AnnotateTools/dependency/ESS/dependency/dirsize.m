function [x, sizeasString]= dirsize(path)
s = dir(path);
name = {s.name};
isdir = [s.isdir] & ~strcmp(name,'.') & ~strcmp(name,'..');
this_size = sum([s(~isdir).bytes]);
sub_f_size = 0;
if(~all(isdir == 0))
    subfolder = strcat(path, filesep(), name(isdir));
    sub_f_size = sum([cellfun(@dirsize, subfolder)]);
end
x = this_size + sub_f_size;

precision = 4;

if nargout >1
    if x < 1024
        sizeasString = [num2str(x, precision) ' Bytes'];
    elseif x<1024^2
        sizeasString = [num2str(x/1024,precision) ' KB'];
    elseif x<1024^3
        sizeasString = [num2str(x/1024^2,precision) ' MB'];
    elseif x<1024^4
        sizeasString = [num2str(x/1024^3, precision) ' GB'];
    elseif x<1024^5
        sizeasString = [num2str(x/1024^4,precision) ' TB'];
    elseif x<1024^6
        sizeasString = [num2str(x/1024^5, precision) ' PB'];
    elseif x<1024^7
        sizeasString = [num2str(x/1024^6, precision) ' YB'];
    elseif x<1024^8
        sizeasString = [num2str(x/1024^4, precision) ' ZB'];
    elseif x<1024^9
        sizeasString = num2str(x);
    end;
end;
end % dirsize