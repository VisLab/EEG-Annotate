function s = renameField(s, oldField, newField)

[s.(newField)] = s.(oldField);
s = rmfield(s,oldField);