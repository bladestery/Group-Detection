# Group-Detection

Weights : Weight Matrix Dump for each Epoch

rnnlib_source_forge_version : modified RNNLIB

tSNE_matlab : tSNE implementation for matlab

noTest.c : creates text file containing the names of all files in directory

	   used for writing .config file for RNNLIB

withTest.c : creates text file containing the names of all flies in directory

	     uses dataset starting with '3_' as test dataset

transcription.config : .config file used for RNNLIB

		       specifies all parameters for RNN

		       additional modification needed in

		       rnnlib_source_forge_version/src/MultilayerNet.hpp

		       rnnlib_source_forge_version/src/Mdrnn.hpp

trk2avi.m : displays trackllets from CUHK dataset as video by group

trk2nc.m : creates netCDF files from CUHK dataset in ./../dotnc folder

plot_hinton.py : creates hinton diagrams for modified version of Weights in ./Weights 