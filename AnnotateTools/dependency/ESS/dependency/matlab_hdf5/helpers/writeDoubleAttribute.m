function writeDoubleAttribute(fileId, dataset, attribute, value)
% Writes a double attribute to the specified HDF5 file
%
% writeDoubleAttribute(fileId, dataset, value)
%
% Input:
%   fileId            The file id
%   dataset           The path of the dataset
%   attribute         The name of the attribute
%   value             The value of the attribute
%

valueType = H5T.copy('H5T_NATIVE_DOUBLE');
dims = size(value);
flippedDims = fliplr(dims);
spaceId = H5S.create_simple(ndims(value),flippedDims, []);
datasetId = H5D.open(fileId, dataset);
attributeId = H5A.create(datasetId, attribute, valueType, spaceId, ...
    'H5P_DEFAULT');
H5A.write(attributeId, valueType, value);
H5A.close(attributeId);
H5D.close(datasetId);
H5S.close(spaceId);

end % writeDoubleAttribute

