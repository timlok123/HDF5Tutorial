# =============================================
# MPI + HDF5 Makefile for C++ Projects
# Features:
# - Auto-detects HDF5/MPI paths
# - Supports debug/release builds
# - Colorized output
# - Handles OpenMPI C++ warnings
# =============================================

# ------ Configuration ------
CXX         := mpicxx
BUILD_TYPE  ?= release
TARGET      := build/mpi_hdf5

# ------ Paths ------
SRC_DIR     := src
INC_DIR     := include
BUILD_DIR   := build
BIN_DIR     := bin

# ------ Library Detection ------
# HDF5 paths (MPI version)
HDF5_LIB_PATH := $(shell h5pcc -show 2>/dev/null | tr ' ' '\n' | grep -e "-L" | head -1 | sed 's/-L//')
HDF5_INC_PATH := $(shell h5pcc -show 2>/dev/null | tr ' ' '\n' | grep -e "-I" | head -1 | sed 's/-I//')

# Fallback to pkg-config if needed
ifeq ($(HDF5_LIB_PATH),)
    HDF5_LIB_PATH := $(shell pkg-config --variable=libdir hdf5-openmpi 2>/dev/null)
    HDF5_INC_PATH := $(shell pkg-config --variable=includedir hdf5-openmpi 2>/dev/null)
endif

# ------ Compiler Flags ------
COMMON_FLAGS := -Wall -Wextra -I$(INC_DIR) -I$(HDF5_INC_PATH) \
                $(shell mpicxx --showme:compile)

# Release flags
RELEASE_FLAGS := -O3 -DNDEBUG -march=native

# Debug flags
DEBUG_FLAGS := -O0 -g3 -DDEBUG -fsanitize=address

# Suppress OpenMPI C++ binding warnings
CXX_WARNINGS := -Wno-cast-function-type -DOMPI_SKIP_MPICXX

# Select flags
ifeq ($(BUILD_TYPE),debug)
    CXXFLAGS := $(COMMON_FLAGS) $(DEBUG_FLAGS) $(CXX_WARNINGS)
else
    CXXFLAGS := $(COMMON_FLAGS) $(RELEASE_FLAGS) $(CXX_WARNINGS)
endif

# ------ Linker Flags ------
LDFLAGS := $(shell mpicxx --showme:link) -L$(HDF5_LIB_PATH) -Wl,-rpath,$(HDF5_LIB_PATH)
LIBS    := -lhdf5 -lhdf5_hl -lz -ldl -lm

# ------ File Discovery ------
SRCS := $(shell find $(SRC_DIR) -name '*.cpp')
OBJS := $(patsubst $(SRC_DIR)/%.cpp,$(BUILD_DIR)/%.o,$(SRCS))
DEPS := $(OBJS:.o=.d)

# ------ Build Rules ------
all: $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p $(@D)
	@printf "\033[1;32m[LINKING]\033[0m %s\n" $@
	@$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS) $(LIBS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.cpp
	@mkdir -p $(@D)
	@printf "\033[1;36m[COMPILE]\033[0m %s\n" $<
	@$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

-include $(DEPS)

# ------ Utility Targets ------
clean:
	@printf "\033[1;31m[CLEANING]\033[0m\n"
	@rm -rf $(BUILD_DIR) $(BIN_DIR)

run: $(TARGET)
	@mpirun -np 4 $(TARGET)

debug: BUILD_TYPE := debug
debug: all

.PHONY: all clean run debug