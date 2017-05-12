#!/bin/csh -f

echo "The build depends on CUDA so make sure to run this on a machine with cuda installed!"

setenv LD_LIBRARY_PATH /imec/software/gcc/4.9.2/LINUX6/lib64:/opt/cuda-8.0/lib64
setenv LD_RUN_PATH "/imec/software/gcc/4.9.2/LINUX6/lib64:$LD_RUN_PATH"
source ~soceval/public/bazel.csh
source ~soceval/public/python3.csh

# Configure TF
# See bzl script for the values for most questions (not sure why it does not pick up these automatically...)
# NB need to set up LD_LIBRARY_PATH etc properply before you run configure, else build trouble later on
./configure

# NB this will also download a bunch of dependencies, some of which might not build without adding a few compiler/linker flags
# This will populte bazel-tensorflow where we will need to edit a few things...
./bzl build -s -c opt --copt=-mavx --copt=-mfma --copt=-mfpmath=both --copt=-msse4.2 --config=cuda -k //tensorflow/tools/pip_package:build_pip_package 
# Note we should be able to also add --copt=-mavx2 (the cpu supports it) but then the assembler craps out because it does not know avx2 instructions

# Build tf to see how far we get

# This will fail with linking on protobufs fixes needed:
# (And keep in mind any call to bazel clean undoes all these changes)!
# Edit: protobuf
# ----------------
# Edit bazel-tensorflow/external/protobuf/protobuf.bzl and change
#  if args:
#    ctx.action(
#        inputs=inputs,
#        outputs=ctx.outputs.outs,
#        arguments=args + import_flags + [s.path for s in srcs],
#        executable=ctx.executable.protoc,
#        mnemonic="ProtoCompile",
#        env=ctx.configuration.default_shell_env,  # <<== add this line!
#    )


# Then build tf properly
./bzl build //tensorflow/tools/pip_package:build_pip_package

# Create pip wheel package
bazel-bin/tensorflow/tools/pip_package/build_pip_package `pwd`


# To install:
# make sure you have a python3 env
pip install tensorflow-1.0.0-cp35-cp35m-linux_x86_64.whl
# Set up the env correctly before running to find libc and cuda libs
setenv LD_LIBRARY_PATH /imec/software/gcc/4.9.2/LINUX6/lib64:/opt/cuda-8.0/lib64
