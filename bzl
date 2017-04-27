#!/bin/csh -f

setenv TF_NEED_CUDA 1
setenv TF_NEED_OPENCL 0
setenv CC /imec/software/gcc/4.9.2/bin/gcc
setenv CXX /imec/software/gcc/4.9.2/bin/cpp
setenv GCC_HOST_COMPILER_PATH /imec/software/gcc/4.9.2/bin/gcc
setenv CUDA_TOOLKIT_PATH /opt/cuda-8.0
setenv TF_CUDA_VERSION 8.0
setenv TF_CUDNN_VERSION `grep CUDNN_MAJOR $CUDA_TOOLKIT_PATH/include/cudnn.h | head -n 1 | awk '{print $3}'`
setenv CUDNN_INSTALL_PATH $CUDA_TOOLKIT_PATH
setenv TF_CUDA_COMPUTE_CAPABILITIES 5.2,3.7,5.0
setenv CUDA_PATH $CUDA_TOOLKIT_PATH
setenv CUDA_COMPUTE_CAPABILITIES $TF_CUDA_COMPUTE_CAPABILITIES

setenv EXTRA_BAZEL_ARGS "--jobs 8 -config=opt --copt=-DGPR_BACKWARDS_COMPATIBILITY_MODE --verbose_failures --genrule_strategy=standalone --spawn_strategy=standalone --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-mfpmath=both --copt=-msse4.2"

bazel --output_base=/scratch/`whoami` $*
