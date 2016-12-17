function s = rename_field_to_force_array(s, fieldname)
% s = rename_field_to_force_array(s, fieldname)
% s is an structure array.
forceArrayDirectve = '___Array___';

for i=1:length(s)
    s(i).([fieldname forceArrayDirectve]) = s(i).(fieldname);
end;

s = rmfield(s, fieldname);