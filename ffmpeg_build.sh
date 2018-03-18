#!/bin/bash
#
# Copyright 2016 Eng Chong Meng
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo -e "\n\n** BUILD STARTED: ffmpeg for ${1} **"
. settings.sh $*

pushd ffmpeg
make clean

MODULES=""
for m in "$@"
  do
    case $m in
      x264)
        MODULES="$MODULES --enable-gpl --enable-version3 --enable-libx264"
      ;;
      png)
        MODULES="$MODULES --enable-libpng"
      ;;
      lame)
        MODULES="$MODULES --enable-libmp3lame"
      ;;
    esac
 done

./configure \
  --prefix=$PREFIX \
  --cross-prefix=$CROSS_PREFIX \
  --sysroot=$NDK_SYSROOT \
  --target-os=linux \
  --arch=$NDK_ARCH \
  --cpu=$CPU \
  --enable-cross-compile \
  --disable-debug \
  --disable-doc \
  --enable-static \
  --disable-shared \
  --enable-pic \
  --disable-runtime-cpudetect \
  --enable-pthreads \
  --enable-hardcoded-tables \
  $MODULES \
  --disable-programs \
  --disable-ffplay \
  --disable-ffprobe \
  --enable-x86asm \
  --extra-cflags="-I$PREFIX/include $CFLAGS" \
  --extra-ldflags="-L$PREFIX/lib $LDFLAGS" \
  --extra-libs="-lgcc" \
  --extra-cxxflags="$CXXFLAGS" \
  --pkg-config=$FFMPEG_PKG_CONFIG || exit 1

make -j${HOST_NUM_CORES} && make install || exit 1
popd

echo -e "** BUILD COMPLETED: ffmpeg for ${1} **\n"
