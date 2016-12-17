function writeStrAttribute(fileId, dataset, attribute, value)
% Writes a string attribute to the specified HDF5 file
%
% writeStrAttribute(fileId, dataset, value)
%
% Input:
%   fileId            The file id
%   dataset           The path of the dataset
%   attribute         The name of the attribute
%   value             The value of the attribute
%

valueType = H5T.copy('H5T_FORTRAN_S1');
H5T.set_size(valueType, numel(value));
memType = H5T.copy ('H5T_C_S1');
H5T.set_size (memType, numel(value))
spaceId = H5S.create('H5S_SCALAR');
datasetId = H5D.open(fileId, dataset);
attributeId = H5A.create(datasetId, attribute, valueType, spaceId, ...
    'H5P_DEFAULT');
H5A.write(attributeId, valueType, value);
H5A.close(attributeId);
H5D.close(datasetId);
H5S.close(spaceId);

end % writeStrAttribute

