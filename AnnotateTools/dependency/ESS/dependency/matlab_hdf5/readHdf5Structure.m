function hdf5Struct = readHdf5Structure(file)
% Recursively goes through hdf5 file and loads it as structure
%
% readHdf5Structure(file)
%
% Input:
%   file            The name of the file

fileId = H5F.open(file,'H5F_ACC_RDONLY','H5P_DEFAULT');
hdf5Path = '/';
childStructure = getGroupDatasets(fileId, hdf5Path);
hdf5Path = [hdf5Path, childStructure.name];
childStructure = getGroupDatasets(fileId, hdf5Path);
hdf5Struct = createEmptyStructureFields({childStructure.name});
hdf5Struct = readHdf5Data(fileId, hdf5Path, hdf5Struct, childStructure);
H5F.close(fileId);

    function [status, iterationData] = addDatasetToStructure(groupId, ...
            childName, childStructure)
        % Adds dataset information to a structure
        index = length(childStructure);
        childStructure(index + 1).name = childName;
        objectId = H5O.open(groupId, childName, 'H5P_DEFAULT');
        objectInfo = H5O.get_info(objectId);
        switch (objectInfo.type)
            case H5ML.get_constant_value('H5G_GROUP')
                childStructure(index + 1).objectType = 'Group';
            case H5ML.get_constant_value('H5G_DATASET')
                childStructure(index + 1).objectType = 'Dataset';
        end
        iterationData = childStructure;
        status = 0;
        H5O.close(objectId);
    end % addDatasetToStructure

    function outputStructure = createEmptyStructureFields(structureFields)
        % Creates empty fields in a structure array
        for a = 1:length(structureFields)
            outputStructure.(structureFields{a}) = [];
        end
    end % createEmptyStructFields

    function childStructure = getGroupDatasets(fileId, groupPath)
        % Gets all datasets of a group
        groupId = H5G.open(fileId, groupPath);
        [~, ~, childStructure] =  ...
            H5L.iterate(groupId, 'H5_INDEX_NAME', 'H5_ITER_INC', 0, ...
            @addDatasetToStructure,[]);
        H5G.close(groupId);
    end % getGroupDatasets

    function dataset = postProcessDataset(dataset, datasetId, ...
            isStructField)
        % Processes the dataset
        if isstruct(dataset)
            dataset = struct2StructArray(dataset);
        elseif ischar(dataset)
            dataset = dataset';
        elseif ~iscell(dataset) & isnan(dataset)
            dims = [0, 0];
            if ~isStructField
                dims = readAttribute(datasetId, 'dims');
            end
            switch class(dataset)
                case 'single'
                    dataset = single.empty(dims);
                case 'double'
                    dataset = double.empty(dims);
            end
        elseif isscalar(dataset) && isequal('double',class(dataset)) ...
                && (dataset == 0 || dataset == 1)
            datasetIsLogical = readAttribute(datasetId, 'islogical')';
            if strcmpi('true', datasetIsLogical)
                dataset = logical(dataset);
            end
        end
    end % postProcessDataset

    function attributeValue = readAttribute(datasetId, attribute)
        % Reads a attribute
        attributeId = H5A.open(datasetId, attribute);
        attributeValue = H5A.read(attributeId);
    end % readAttribute

    function dataset = readDataset(fileId, datasetPath)
        % Reads a dataset
        datasetId = H5D.open(fileId, datasetPath);
        dataset = H5D.read(datasetId);
        dataset = postProcessDataset(dataset, datasetId, false);
        H5D.close(datasetId);
    end % readDataset

    function parentStructure = readHdf5Data(fileId, hdf5Path, ...
            parentStructure, childStructure)
        % Reads hdf5 groups and datasets
        for a = 1:length(childStructure);
            if strcmpi(childStructure(a).objectType, 'Group')
                grandChildStructure = getGroupDatasets(fileId, ...
                    [hdf5Path, '/', childStructure(a).name]);
                if isempty(grandChildStructure)
                    parentStructure.(childStructure(a).name) = [];
                else
                    parentStructure.(childStructure(a).name) = ...
                        createEmptyStructureFields({grandChildStructure.name});
                end;
                parentStructure.(childStructure(a).name) = ...
                    readHdf5Data(fileId, ...
                    [hdf5Path, '/', childStructure(a).name], ....
                    parentStructure.(childStructure(a).name), ...
                    grandChildStructure);
            else
                parentStructure.(childStructure(a).name) = ...
                    readDataset(fileId, ...
                    [hdf5Path, '/', childStructure(a).name]);
            end
        end
    end % readHdf5Data

    function structureArray = struct2StructArray(structure)
        % Converts a scalar structure to a structure array
        fieldNames = fieldnames(structure);
        structValues = cell(length(fieldNames), 1, ...
            length(structure.(fieldNames{1})));
        for a = 1:length(structure.(fieldNames{1}))
            for b = 1:length(fieldNames)
                if iscellstr(structure.(fieldNames{b}))
                    structValues{b, 1, a} = ...
                        structure.(fieldNames{b}){a};
                else
                    structValues{b, 1, a} = ...
                        postProcessDataset(...
                        structure.(fieldNames{b})(a), [], true);
                end
            end
        end
        structureArray = cell2struct(structValues,fieldNames,1);
    end % struct2StructArray

end % readHdf5Structure

