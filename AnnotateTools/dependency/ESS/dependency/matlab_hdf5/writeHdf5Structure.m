function writeHdf5Structure(file, root, structure)
% Creates a HDF5 file and writes the contents of a structure to it
%
% writeHdf5Structure(file, root, structure)
%
% Input:
%   file            The name of the file
%   root            The name of the structure
%   structure       The structure containing the data
%

fileId = H5F.create(file, 'H5F_ACC_TRUNC', 'H5P_DEFAULT', 'H5P_DEFAULT');
writeGroup(fileId, ['/', strrep(root, '/', '')]);
addDataset(fileId, ['/', strrep(root, '/', '')], structure);
H5F.close(fileId);

    function addDataset(fileId, path, structure)
        % Writes the structure fields to the file under the specified path
        fieldNames = fieldnames(structure);
        for a = 1:length(fieldNames)
            switch class(structure.(fieldNames{a}))
                case 'cellstr'
                    writeCellStr(fileId, [path, '/', fieldNames{a}], ...
                        {structure.(fieldNames{a})})
                case 'char'
                    writeStr(fileId, [path, '/', fieldNames{a}], ...
                        structure.(fieldNames{a}));
                case 'double'
                    writeDouble(fileId, ...
                        [path, '/', fieldNames{a}], ...
                        structure.(fieldNames{a}));
                case 'logical'  
                    writeDouble(fileId, ...
                        [path, '/', fieldNames{a}], ...
                        structure.(fieldNames{a}));
                case 'single'
                    writeSingle(fileId, ...
                        [path, '/', fieldNames{a}], ...
                        structure.(fieldNames{a}));
                case 'struct'
                    if isscalar(structure.(fieldNames{a}))
                        writeGroup(fileId, [path, '/', fieldNames{a}]);
                        addDataset(fileId, [path, '/', fieldNames{a}], ...
                            structure.(fieldNames{a}));
                    elseif ~isscalar(structure.(fieldNames{a})) && ...
                            ~isNestedStructure(structure.(fieldNames{a}))
                        writeStructure(fileId, ...
                            [path, '/', fieldNames{a}], ...
                            structure.(fieldNames{a}));
                    end
            end
        end
    end % addDataset

    function nestedStructure = isNestedStructure(structure)
        % Checks to see if a structure contains a nested field
        nestedStructure = false;
        fieldNames = fieldnames(structure);
        for a = 1:length(structure)           
            for b = 1:length(fieldNames)
                if isstruct(structure(a).(fieldNames{b}))
                    nestedStructure = true;
                end
            end
        end
    end % isNestedStructure

end % writeHdf5Structure

