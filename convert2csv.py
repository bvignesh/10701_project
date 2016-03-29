import scipy.io as sio  #to read the mat file
import numpy as np

##opening the file##
#fname = input('Enter the name of the file to be converted - ')  #replace with raw_input for python2
fname = 'cba1ff01.mat'  #hardcoded for test phase
array = sio.loadmat(fname)
#print(array[1,5])
#print(array[2,5])
#print(array[3,5])
#print(array[4,5])
keys = array.keys()
print(keys)
print(type(array['EEG']))
print(array['EEG'].ndim)
print((array['EEG'][0,0].size))
print(array['EEG'][0,0])
#print(len(array['EEG'].item((1,:))))
#print(len(array['EEG'].item((2,:))))
##reading contents##



