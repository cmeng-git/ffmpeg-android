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

# generate the libs and includes of all ffmpeg options for ./configure
OPTS=("x264" "lame")
LIBS=""
INCLUDES=""

for x in "${OPTS[@]}"
  do
    OUT_DIR="${BASEDIR}/build/${x}/android/${1}"
    LIBS="${LIBS}-L${OUT_DIR}/lib "
    INCLUDES="${INCLUDES}-I${OUT_DIR}/include "
  done

# remove trailing whitespace characters - not required
#LIBS="${LIBS%"${LIBS##*[![:space:]]}"}" 
#INCLUDES="${INCLUDES%"${INCLUDES##*[![:space:]]}"}" 

pushd ffmpeg
make clean

case $1 in
  armeabi)
    CPU='armv5'
    HOST='arm-linux'
    NDK_ARCH="arm"
    NDK_ABIARCH='arm-linux-androideabi'
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    TARGET="armv7-android-gcc --disable-neon --disable-neon-asm"
    CFLAGS="$CFLAGS -march=armv5 -marm -finline-limit=64"
  ;;
  armeabi-v7a)
    CPU=armv7-a
  ;;
  arm64-v8a)
    CPU='arm64-v8a'
  ;;
  x86)
    CPU='i686'
  ;;
  x86_64)
    CPU='x86_64'
  ;;
  mips)
    # cpu incorrect
    CPU='mips32r2'
  ;;
  mips64)
    # cpu incorrect
    CPU='mips64'
  ;;
esac

# Do not use temporary
#  --cpu="$CPU" \

./configure \
  --prefix="${BASEDIR}/build/ffmpeg/android/${1}" \
  --cross-prefix="$CROSS_PREFIX" \
  --sysroot="${NDK_SYSROOT}"  \
  --target-os="$TARGET_OS" \
  --arch="$NDK_ARCH" \
  --objcc=gcc \
  --disable-debug \
  --disable-doc \
  --enable-gpl \
  --enable-version3 \
  --enable-static \
  --disable-shared \
  --enable-pic \
  --disable-runtime-cpudetect \
  --enable-pthreads \
  --enable-hardcoded-tables \
  --enable-libx264 \
  --disable-ffserver \
  --disable-ffplay \
  --disable-ffprobe \
  --enable-yasm \
  --extra-cflags="${INCLUDES} $CFLAGS" \
  --extra-ldflags=" ${LIBS} $LDFLAGS" \
  --extra-libs="-lm" \
  --extra-cxxflags="$CXXFLAGS" \
  --pkg-config="${FFMPEG_PKG_CONFIG}" || exit 1

make -j${NUMBER_OF_CORES} && make install || exit 1
popd

echo -e "** BUILD COMPLETED: ffmpeg for ${1} **\n"
