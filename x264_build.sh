#!/bin/bash
echo -e "\n\n** BUILD STARTED: x264 for ${1} **"
. settings.sh $*

pushd x264
make clean
./configure \
  --prefix=$PREFIX \
  --cross-prefix=$CROSS_PREFIX \
  --sysroot=$NDK_SYSROOT \
  --host=$HOST \
  --enable-pic \
  --disable-asm \
  --enable-static \
  --disable-opencl \
  --disable-cli || exit 1

make -j${HOST_NUM_CORES} install || exit 1
popd
echo -e "** BUILD COMPLETED: x264 for ${1} **\n"
