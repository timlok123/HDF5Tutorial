#include <H5Cpp.h>
#include <vector>

int main() {
    const std::string fileName = "simulation_data.h5";
    const std::string datasetName = "simulation";

    // Create a file
    H5::H5File file(fileName, H5F_ACC_TRUNC);

    // Create data to store
    std::vector<double> data(100, 3.14); // Example data
    hsize_t dims[1] = {data.size()};

    // Create a dataset
    H5::DataSpace dataspace(1, dims);
    H5::DataSet dataset = file.createDataSet(datasetName, H5::PredType::NATIVE_DOUBLE, dataspace);

    // Write data to the dataset
    dataset.write(data.data(), H5::PredType::NATIVE_DOUBLE);

    return 0;
}