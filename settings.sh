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
set -x
if [ "$ANDROID_NDK" = "" ]; then
	echo "You need to set ANDROID_NDK environment variable, exiting"
	echo "Use: export ANDROID_NDK=/your/path/to/android-ndk"
	exit 1
fi
set -u

# Never mix two api level to build static library for use on the same apk.
# Set to API:-15 for aTalk minimun support for platform API-15
# Does not build 64-bit arch if ANDROID_API is less than 21 - the minimum supported API level for 64-bit.
ANDROID_API=15
NDK_TOOLCHAIN_ABI_VERSION=4.9

NUMBER_OF_CORES=$(nproc)
TARGET_OS=linux
BASEDIR=`pwd`

CFLAGS='-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fno-strict-overflow -fstack-protector-all'
LDFLAGS='-Wl,-z,relro -Wl,-z,now -pie'
FFMPEG_PKG_CONFIG="${BASEDIR}/ffmpeg-pkg-config"

# Built with command i.e. ./ffmpeg-android_build.sh or following with parameter [ARCHS(x)]
# Create custom ARCHS or uncomment to build all supported architectures for ffmpeg.
ARCHS=("armeabi" "armeabi-v7a" "arm64-v8a" "x86" "x86_64" "mips" "mips64")
#ARCHS=("armeabi-v7a" "x86" "mips")

NDK=${ANDROID_NDK}
TOOLCHAIN_PREFIX=${BASEDIR}/toolchain-android
NDK_SYSROOT=${TOOLCHAIN_PREFIX}/sysroot

# Do not procced on first call without the required 2 parameters
[[ $# -lt 2 ]] && return 

case $1 in
  armeabi)
    HOST='arm-linux'
    NDK_ARCH="arm"
    NDK_ABIARCH='arm-linux-androideabi'
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    TARGET="armv7-android-gcc --disable-neon --disable-neon-asm"
    CFLAGS="$CFLAGS -march=armv5 -marm -finline-limit=64"
  ;;
  armeabi-v7a)
    HOST='arm-linux'
    NDK_ARCH='arm'
    NDK_ABIARCH='arm-linux-androideabi'
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    TARGET="armv7-android-gcc"
    CFLAGS="$CFLAGS -march=armv7-a -marm -mfloat-abi=softfp -mfpu=neon -mtune=cortex-a8 -mthumb -D__thumb__"

    # arm v7vfpv3
    # CFLAGS="$CFLAGS -march=$CPU -marm -mfloat-abi=softfp -mfpu=vfpv3-d16"

    # arm v7 + neon (neon also include vfpv3-32)
    # CFLAGS="$CFLAGS -march=$CPU -marm -mfloat-abi=softfp -mfpu=neon"-mtune=cortex-a8 -mthumb -D__thumb__" 
  ;;
  arm64-v8a)
    HOST='aarch64-linux'
    NDK_ARCH='arm64'
    NDK_ABIARCH='aarch64-linux-android'
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    CFLAGS="$CFLAGS "
  ;;
  x86)
    HOST='i686-linux'
    NDK_ARCH='x86'
    NDK_ABIARCH='x86'
    NDK_CROSS_PREFIX="i686-linux-android"
    CFLAGS="$CFLAGS -O2 -march=i686 -m32 -mtune=intel -msse3 -mfpmath=sse"
  ;;
  x86_64)
    HOST='x86_64-linux'
    NDK_ARCH='x86_64'
    NDK_ABIARCH='x86_64'
    NDK_CROSS_PREFIX="x86_64-linux-android"
    CFLAGS="$CFLAGS -O2 -march=x86_64 -m64  -msse4.2 -mpopcnt-mtune=intel"
  ;;
  mips)
    HOST='mipsel-linux'
    NDK_ARCH='mips'
    NDK_ABIARCH="mipsel-linux-android"
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    CFLAGS="$CFLAGS -EL -march=mips32 -mips32 -mhard-float"
  ;;
  mips64)
    HOST='mips64-linux'
    NDK_ARCH='mips64'
    NDK_ABIARCH='mips64el-linux-android'
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    CFLAGS="$CFLAGS -EL -march=mips64 -mips64 -mhard-float"
  ;;
esac

[ -d ${TOOLCHAIN_PREFIX} ] || $NDK/build/tools/make-standalone-toolchain.sh \
  --toolchain=${NDK_ABIARCH}-${NDK_TOOLCHAIN_ABI_VERSION} \
  --platform=android-${ANDROID_API} \
  --install-dir=${TOOLCHAIN_PREFIX} \
  --arch=$NDK_ARCH

CROSS_PREFIX=${TOOLCHAIN_PREFIX}/bin/${NDK_CROSS_PREFIX}-
CXXFLAGS=""

export PKG_CONFIG_LIBDIR="${TOOLCHAIN_PREFIX}/lib/pkgconfig"

export CC="${CROSS_PREFIX}gcc --sysroot=${NDK_SYSROOT}"
export LD="${CROSS_PREFIX}ld"
export RANLIB="${CROSS_PREFIX}ranlib"
export STRIP="${CROSS_PREFIX}strip"
export OBJDUMP="${CROSS_PREFIX}objdump"
export AR="${CROSS_PREFIX}ar"
export AS="${CROSS_PREFIX}as"
export CXX="${CROSS_PREFIX}g++"
export CPP="${CROSS_PREFIX}cpp"
export GCONV="${CROSS_PREFIX}gconv"
export NM="${CROSS_PREFIX}nm"
export SIZE="${CROSS_PREFIX}size"

