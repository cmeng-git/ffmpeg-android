#!/bin/bash
echo -e "\n\n** BUILD STARTED: x264 for ${1} **"
. settings.sh $*

X264_VERSION=155

pushd x264
make clean
./configure \
  --prefix=$PREFIX \
  --includedir=$PREFIX/include/x264 \
  --cross-prefix=$CROSS_PREFIX \
  --sysroot=$NDK_SYSROOT \
  --host=$HOST \
  --enable-pic \
  --disable-asm \
  --enable-static \
  --enable-shared \
  --disable-opencl \
  --disable-cli || exit 1

make -j${HOST_NUM_CORES} install || exit 1
popd

pushd ./android/$1/lib
if [[ -f libx264.so.$X264_VERSION ]]; then
  mv libx264.so.$X264_VERSION libx264_$X264_VERSION.so
  sed -i 's/libx264.so.155/libx264_155.so/g' libx264_$X264_VERSION.so
  rm libx264.so
  ln -f -s libx264_$X264_VERSION.so libx264.so
fi
popd

echo -e "** BUILD COMPLETED: x264 for ${1} **\n"
