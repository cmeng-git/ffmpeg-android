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

# export ANDROID_NDK="/opt/android/android-ndk-r15c" - last working is r15c without errors
# r16b => Unable to invoke compiler: /opt/android/android-ndk-r16b/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/bin/arm-linux-androideabi-gcc but build?

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
    # vpx needs additional options not valid in ffmpeg
    # valid arguments to '-mfpu=' are: crypto-neon-fp-armv8 fp-armv8 fpv4-sp-d16 neon neon-fp-armv8 neon-fp16 neon-vfpv4 vfp vfp3 vfpv3 vfpv3-d16 vfpv3-d16-fp16 vfpv3-fp16 vfpv3xd vfpv3xd-fp16 vfpv4 vfpv4-d16
    export CFLAGS="${CFLAGS} -mfloat-abi=softfp -mfpu=neon-vfpv4"
    TARGET="arm64-android-gcc"
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
  # https://bugs.chromium.org/p/webm/issues/detail?id=1476
  # --extra-cflags fix for r16b; but essentially NOP for NDK below r16; however it failed arm64-android-gcc build
  # ./asm/sigcontext.h:39:3: error: unknown type name '__uint128_t'
  # --as=yasm requires by x86 and x86-64 instead of clang

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
  --extra-cflags="-isystem ${NDK}/sysroot/usr/include/${NDK_ABIARCH} -isystem ${NDK}/sysroot/usr/include" \
  --disable-webm-io || exit 1

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

