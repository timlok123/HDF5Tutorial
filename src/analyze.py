import h5py

# Open the HDF5 file
with h5py.File('simulation_data.h5', 'r') as f:
    # Read the dataset
    data = f['simulation'][:]
    print("Data:", data)