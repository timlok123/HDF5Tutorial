#include <mpi.h>
#include <hdf5.h>
#include <iostream>
#include <vector>

void check_hdf5_version() {
    unsigned majnum, minnum, relnum;
    H5get_libversion(&majnum, &minnum, &relnum);
    std::cout << "HDF5 Version: " << majnum << "." << minnum << "." << relnum << std::endl;
}

int main(int argc, char** argv) {
    MPI_Init(&argc, &argv);

    int rank, size;
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Verify MPI
    std::cout << "Hello from rank " << rank << "/" << size << std::endl;

    // Verify HDF5
    if (rank == 0) {
        check_hdf5_version();
        std::cout << "HDF5 and MPI are working correctly!" << std::endl;
    }

    MPI_Finalize();
    return 0;
}