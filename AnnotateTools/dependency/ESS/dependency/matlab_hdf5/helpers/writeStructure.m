function writeStructure(fileId, dataset, value)
% Writes a structure dataset to the specified HDF5 file
%
% writeStructure(fileId, dataset, value)
%
% Input:
%   fileId            The file id
%   dataset           The path of the dataset
%   value             The value of the dataset
%

dim = length(value);
[value, dataTypes, dataSizes] = getStructureInfo(value);
[memType, fileType] = constructStructure(value, dataTypes, dataSizes);
spaceId = H5S.create_simple(1, dim, []);
datasetId = H5D.create (fileId, dataset, fileType, spaceId, 'H5P_DEFAULT');
H5D.write(datasetId, memType, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', value);
H5D.close(datasetId);
H5S.close(spaceId);

    function offset = computeOffsets(dataSizes)
        % Computes the offset sizes of the fields
        offset(1)=0;
        offset(2:length(dataSizes))= ...
            cumsum(dataSizes(1:(length(dataSizes)-1)));
    end % computeOffsets

    function [memType, fileType] = constructStructure(structure, ...
            dataTypes, dataSizes)
        % Constructs a structure dataset
        offset = computeOffsets(dataSizes);
        memType = constructStructureMemory(structure, offset, dataTypes, ...
            dataSizes);
        fileType = constructStructureType(structure, offset, dataTypes, ...
            dataSizes);
    end % constructStructure

    function memType = constructStructureMemory(structure, offset, ...
            dataTypes, dataSizes)
        % Constructs memory type for structure dataset
        fieldNames = fieldnames(structure);
        memType = H5T.create ('H5T_COMPOUND', sum(dataSizes));
        for a = 1:length(fieldNames)
            H5T.insert(memType, fieldNames{a}, offset(a), dataTypes{a});
        end
    end % constructStructureMemory

    function fileType = constructStructureType(structure, offset, ...
            dataTypes, dataSizes)
        % Constructs data type for structure dataset
        fieldNames = fieldnames(structure);
        fileType = H5T.create ('H5T_COMPOUND', sum(dataSizes));
        for a = 1:length(fieldNames)
            H5T.insert(fileType, fieldNames{a}, offset(a), dataTypes{a});
        end
    end % constructStructureType

    function [scalarStructure, dataTypes, dataSizes] = ...
            getStructureInfo(structure)
        % Gets the structure information
        scalarStructure = [];
        fieldNames = fieldnames(structure);
        dataTypes = cell(1, length(fieldNames));
        dataSizes = zeros(1, length(fieldNames));
        for a = 1:length(fieldNames)
            index = findFirstNonEmptyIndex(structure, fieldNames{a});
            switch class(structure(index).(fieldNames{a}))
                case 'char'
                    scalarStructure.(fieldNames{a}) = ...
                        {structure.(fieldNames{a})};
                    emptyIndecies = cellfun(@isempty, ...
                        scalarStructure.(fieldNames{a}));
                    if any(emptyIndecies)
                        [scalarStructure.(fieldNames{a}){emptyIndecies}] = ...
                            deal('');
                    end
                    dataTypes{a} = H5T.copy ('H5T_C_S1');
                    H5T.set_size (dataTypes{a}, 'H5T_VARIABLE');
                    dataSizes(a) = H5T.get_size(dataTypes{a});
                case 'double'
                    scalarStructure.(fieldNames{a}) = ...
                        {structure.(fieldNames{a})};
                    emptyIndecies = cellfun(@isempty, ...
                        scalarStructure.(fieldNames{a}));
                    if any(emptyIndecies)
                        [scalarStructure.(fieldNames{a}){emptyIndecies}] = ...
                            deal(nan);
                    end
                    scalarStructure.(fieldNames{a}) = ...
                        cell2mat(scalarStructure.(fieldNames{a}));
                    dataTypes{a} = H5T.copy('H5T_NATIVE_DOUBLE');
                    dataSizes(a) = H5T.get_size(dataTypes{a});
                case 'single'
                    scalarStructure.(fieldNames{a}) = ...
                        {structure.(fieldNames{a})};
                    emptyIndecies = cellfun(@isempty, ...
                        scalarStructure.(fieldNames{a}));
                    if any(emptyIndecies)
                        scalarStructure.(fieldNames{a}){emptyIndecies} = ...
                            deal(nan);
                    end
                    scalarStructure.(fieldNames{a}) = ...
                        cell2mat(scalarStructure.(fieldNames{a}));
                    dataTypes{a} = H5T.copy('H5T_NATIVE_FLOAT');
                    dataSizes(a) = H5T.get_size(dataTypes{a});
            end
        end
    end % getStructureInfo

    function index = findFirstNonEmptyIndex(structureArray, fieldName)
        % Finds the first non-empty index of a field in a structure array
        index = 1;
        for a = 1:length(structureArray)
            if ~isempty(structureArray(a).(fieldName))
                index = a;
                return
            end
        end
    end % findFirstNonEmptyIndex

end % writeStructure

