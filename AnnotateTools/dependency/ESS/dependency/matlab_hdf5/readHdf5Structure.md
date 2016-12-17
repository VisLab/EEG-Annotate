#readHdf5Structure

*readHdf5Structure* is a function that stores a MATLAB structure in a hdf5 file. 

## Dependencies
* [HDF5](http://www.hdfgroup.org/HDF5/)
* MATLAB 

## Functions and Methods
hdf5Struct = readHdf5Structure(file)

### Input
* `file`: the name of the hdf5 file to read in

### Output
* `hdf5Struct`: a structure containing the contents from the hdf5 file

## Examples

a = readHdf5Structure('/path/to/hdf5file/hdf5file.h5');

## Notes
