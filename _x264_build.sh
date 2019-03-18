#!/bin/bash
echo -e "\n\n** BUILD STARTED: x264 for ${1} **"
. _settings.sh $*

pushd x264
X264_API="$(grep '#define X264_BUILD' < x264.h | sed 's/^.* \([1-9][0-9]*\).*$/\1/')"

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
  --disable-thread \
  --disable-cli || exit 1

make -j${HOST_NUM_CORES} install || exit 1
popd

pushd ./android/$1/lib
if [[ -f libx264.so.$X264_API ]]; then
  mv libx264.so.$X264_API libx264_$X264_API.so
  sed -i "s/libx264.so.${X264_API}/libx264_${X264_API}.so/g" libx264_$X264_API.so
  rm libx264.so
  ln -f -s libx264_$X264_API.so libx264.so
fi
popd

echo -e "** BUILD COMPLETED: x264 for ${1} **\n"
