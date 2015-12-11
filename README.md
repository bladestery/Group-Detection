# Group-Detection

Weights : Weight Matrix dump for each Epoch

rnnlib_source_forge_version : modified RNNLIB

tSNE_matlab : tSNE implementation for matlab

noTest.c : creates text file containing the names of all files in directory

	   used for writing .config file for RNNLIB

withTest.c : creates text file containing the names of all flies in directory

	     uses dataset starting with '3' as test dataset

transcription.config : .config file used for RNNLIB

		       specifies all parameters for RNN

		       additional modification may be needed in (depending on desired network)
		       rnnlib_source_forge_version/src/MultilayerNet.hpp
		       rnnlib_source_forge_version/src/Mdrnn.hpp

trk2avi.m : displays tracklets from CUHK dataset as video by group

trk2nc.m : creates netCDF files from CUHK dataset in ./../dotnc folder

plot_hinton.py : creates hinton diagrams for Weights in ./Weights 

error_test.sh : script for testing the RNN, run with save file as argument

video_info_t0.xls : excel file containing metadata for trk2avi.m and trk2nc.m.
                   
                    must be used in conjunction with CUHK crowd dataset
