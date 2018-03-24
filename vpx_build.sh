#!/bin/bash
#
# Copyright 2016 cmeng
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

# export ANDROID_NDK="/opt/android/android-ndk-r15c" - last working version without errors; but build failed for mips and mips64
# r16b => Unable to invoke compiler: /opt/android/android-ndk-r16b/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc
# --extra-cflags fix for ndk-r16b; however it still failed arm64-android-gcc build

echo -e "\n\n** BUILD STARTED: vpx for ${1} **"
. settings.sh $*

pushd libvpx-1.7.0
make clean

case $1 in
  # libvpx does not provide armv5 build option
  armeabi)
    TARGET="armv7-android-gcc --disable-neon --disable-neon-asm"
  ;;
  armeabi-v7a)
    TARGET="armv7-android-gcc"
  ;;
  arm64-v8a)
    # vpx needs additional neon options but not valid in ffmpeg
    # valid arguments to '-mfpu=' are: crypto-neon-fp-armv8 fp-armv8 fpv4-sp-d16 neon neon-fp-armv8 neon-fp16 neon-vfpv4 vfp vfp3 vfpv3 vfpv3-d16 vfpv3-d16-fp16 vfpv3-fp16 vfpv3xd vfpv3xd-fp16 vfpv4 vfpv4-d16
    export CFLAGS="${CFLAGS} -mfloat-abi=softfp -mfpu=neon-vfpv4"
    TARGET="arm64-android-gcc"
    #TARGET="armv8-linux-gcc"
  ;;
  x86)
    TARGET="x86-android-gcc"
  ;;
  x86_64)
    TARGET="x86_64-android-gcc"
  ;;
  mips)
    TARGET="mips32-linux-gcc"
  ;;
  mips64)
    TARGET="mips64-linux-gcc"
  ;;
esac

  # --sdk-path=${TOOLCHAIN_PREFIX} must use ${NDK} actual path else cannot find CC for arm64-android-gcc
  # ==> (Unable to invoke compiler: /arm-linux-androideabi-gcc)
  # https://bugs.chromium.org/p/webm/issues/detail?id=1476

  # Has configure error with Target=arm64-android-gcc which uses incorrect cc i.e. arm-linux-androideabi-gcc;

  # ./asm/sigcontext.h:39:3: error: unknown type name '__uint128_t'
  # GCC has builtin support for the types __int128, unsigned __int128, __int128_t and __uint128_t. Use them to define your own types:
  # typedef __int128 int128_t;
  # typedef unsigned __int128 uint128_t;

  # need --as=yasm which is required by x86 and x86-64; cannot use define in settings.sh which uses clang

./configure \
  --sdk-path=${NDK} \
  --prefix=${PREFIX} \
  --target=${TARGET} \
  --as=yasm \
  --disable-runtime-cpu-detect \
  --disable-docs \
  --enable-static \
  --disable-shared \
  --disable-examples \
  --disable-tools \
  --disable-debug \
  --disable-unit-tests \
  --enable-realtime-only \
  --enable-vp9-postproc --enable-vp9-highbitdepth \
  --disable-webm-io || exit 1

#  --extra-cflags="-isystem ${NDK}/sysroot/usr/include/${NDK_ABIARCH} -isystem ${NDK}/sysroot/usr/include" \

make -j${HOST_NUM_CORES} install || exit 1

# OUTPUT_ROOT=${TOOLS_ROOT}/output/android/${ABI}
# [ -d ${OUTPUT_ROOT}/include ] || mkdir -p ${OUTPUT_ROOT}/include/vpx \
#	&& mkdir -p ${OUTPUT_ROOT}/include/common \
#	&& mkdir -p ${OUTPUT_ROOT}/include/mkvmuxer \
#	&& mkdir -p ${OUTPUT_ROOT}/include/mkvparser \
#	&& mkdir -p ${OUTPUT_ROOT}/include/libmkv
   # cp -r ./third_party/libwebm/common/*.h ${OUTPUT_ROOT}/include/common
   # cp -r ./third_party/libwebm/mkvmuxer/*.h ${OUTPUT_ROOT}/include/mkvmuxer
   # cp -r ./third_party/libwebm/mkvparser/*.h ${OUTPUT_ROOT}/include/mkvparser

## cp -r ./third_party/libmkv/*.h ${OUTPUT_ROOT}/include/libmkv
  
popd
echo -e "** BUILD COMPLETED: vpx for ${1} **\n"

