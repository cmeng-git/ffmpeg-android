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
# Set to API:15 for aTalk minimun support for platform API-15
# Does not build 64-bit arch if ANDROID_API is less than 21 - the minimum supported API level for 64-bit.
ANDROID_API=21
NDK_ABI_VERSION=4.9

# Built with command i.e. ./ffmpeg-android_build.sh or following with parameter [ABIS(x)]
# Create custom ABIS or uncomment to build all supported abi for ffmpeg.
# Do not change naming convention of the ABIS; see:
# https://developer.android.com/ndk/guides/abis.html#Native code in app packages
# Android recomended architecture support; others are deprecated
# ABIS=("armeabi-v7a" "arm64-v8a" "x86" "x86_64")
ABIS=("armeabi" "armeabi-v7a" "arm64-v8a" "x86" "x86_64" "mips" "mips64")

BASEDIR=`pwd`
TOOLCHAIN_PREFIX=${BASEDIR}/toolchain-android

#===========================================
# Do not procced on first call without the required 2 parameters
[[ $# -lt 2 ]] && return

NDK=${ANDROID_NDK}
HOST_NUM_CORES=$(nproc)

CFLAGS='-fPIE -fPIC -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -fno-strict-overflow -fstack-protector-all'
LDFLAGS='-pie -Wl,-z,relro -Wl,-z,now -nostdlib -lc -lm -ldl -llog'

# Do not modify any of the NDK_ARCH, CPU and -march unless you are sure.
# The settings are used by <ARCH>-linux-android-gcc and submodule configure
# https://en.wikipedia.org/wiki/List_of_ARM_microarchitectures
# $NDK/toolchains/llvm/prebuilt/...../includellvm/ARMTargetParser.def etc
# ARCH - should be one from $ANDROID_NDK/platforms/android-$API/arch-* [arm / arm64 / mips / mips64 / x86 / x86_64]"
case $1 in
  # Deprecated in r16. Will be removed in r17
  armeabi)
    CPU='armv5'
    HOST='arm-linux'
    NDK_ARCH="arm"
    NDK_ABIARCH='arm-linux-androideabi'
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    CFLAGS="$CFLAGS -march=$CPU -marm"
  ;;
  armeabi-v7a)
    CPU='armv7-a'
    HOST='arm-linux'
    NDK_ARCH='arm'
    NDK_ABIARCH='arm-linux-androideabi'
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    CFLAGS="$CFLAGS -march=$CPU -marm -mfloat-abi=softfp -mfpu=neon -mtune=cortex-a8 -mthumb -D__thumb__"

    # arm v7vfpv3
    # CFLAGS="$CFLAGS -march=$CPU -marm -mfloat-abi=softfp -mfpu=vfpv3-d16"

    # arm v7 + neon (neon also include vfpv3-32)
    # CFLAGS="$CFLAGS -march=$CPU -marm -mfloat-abi=softfp -mfpu=neon"-mtune=cortex-a8 -mthumb -D__thumb__" 
  ;;
  arm64-v8a)
    # Valid cpu = armv8-a cortex-a35, cortex-a53, cortec-a57 etc. but -march=armv8-a is required
    # x264 build has own undefined references e.g. x264_8_pixel_sad_16x16_neon - show up when build ffmpeg 
    CPU='cortex-a57'
    HOST='aarch64-linux'
    NDK_ARCH='arm64'
    NDK_ABIARCH='aarch64-linux-android'
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    # -march valid only for armv8-a, armv8.1-a, armv8.2-a (armv8-a only valid for lame build).
    CFLAGS="$CFLAGS -march=armv8-a"
  ;;
  x86)
    CPU='i686'
    HOST='i686-linux'
    NDK_ARCH='x86'
    NDK_ABIARCH='x86'
    NDK_CROSS_PREFIX="i686-linux-android"
    CFLAGS="$CFLAGS -O2 -march=$CPU -mtune=intel -mssse3 -mfpmath=sse -m32"
  ;;
  x86_64)
    CPU='x86-64'
    HOST='x86_64-linux'
    NDK_ARCH='x86_64'
    NDK_ABIARCH='x86_64'
    NDK_CROSS_PREFIX="x86_64-linux-android"
    CFLAGS="$CFLAGS -O2 -march=$CPU -mtune=intel -msse4.2 -mpopcnt -m64"
  ;;

  # MIPS is deprecated in NDK r16 and will be removed in r17.
  # https://en.wikipedia.org/wiki/List_of_MIPS_architecture_processors
  # mips64el-linux-android-gcc: note: valid arguments to '-march=' are: 10000 1004kc 1004kf 1004kf1_1 1004kf2_1 10k 12000 12k 14000 14k 16000 16k 2000 20kc 24kc 24kec 24kef 24kef1_1 24kef2_1 24kefx 24kex 24kf 24kf1_1 24kf2_1 24kfx 24kx 2k 3000 34kc 34kf 34kf1_1 34kf2_1 34kfx 34kn 34kx 3900 3k 4000 4100 4111 4120 4130 4300 4400 4600 4650 4700 4k 4kc 4kec 4kem 4kep 4km 4kp 4ksc 4ksd 5000 5400 5500 5900 5k 5kc 5kf 6000 6k 7000 74kc 74kf 74kf1_1 74kf2_1 74kf3_2 74kfx 74kx 7k 8000 8k 9000 9k from-abi i6400 loongson2e loongson2f loongson3a m14k m14kc m14ke m14kec m4k mips1 mips2 mips3 mips32 mips32r2 mips32r3 mips32r5 mips32r6 mips4 mips64 mips64r2 mips64r3 mips64r5 mips64r6 native octeon octeon+ octeon2 octeon3 orion p5600 r10000 r1004kc r1004kf r1004kf1_1 r1004kf2_1 r10k r12000 r12k r14000 r14k r16000 r16k r2000 r20kc r24kc r24kec r24kef r24kef1_1 r24kef2_1 r24kefx r24kex r24kf r24kf1_1 r24kf2_1 r24kfx r24kx r2k r3000 r34kc r34kf r34kf1_1 r34kf2_1 r34kfx r34kn r34kx r3900 r3k r4000 r4100 r4111 r4120 r4130 r4300 r4400 r4600 r4650 r4700 r4k r4kc r4kec r4kem r4kep r4km r4kp r4ksc r4ksd r5000 r5400 r5500 r5900 r5k r5kc r5kf r6000 r6k r7000 r74kc r74kf r74kf1_1 r74kf2_1 r74kf3_2 r74kfx r74kx r7k r8000 r8k r9000 r9k rm7000 rm7k rm9000 rm9k sb1 sb1a sr71000 sr71k vr4100 vr4111 vr4120 vr4130 vr4300 vr5000 vr5400 vr5500 vr5k xlp xlr
  mips)
    # unknown cpu - optimization disable
    CPU='p5600'
    HOST='mips-linux'
    NDK_ARCH='mips'
    NDK_ABIARCH="mipsel-linux-android"
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    CFLAGS="$CFLAGS -EL -march=$CPU -mhard-float"
  ;;
  mips64)
    # -march=mips64r6 works for clangs but complain by ffmpeg (use -march=$CPU), reverse when -march=i6400 - so omit it in CFLAG works for both
    CPU='i6400'
    HOST='mips64-linux'
    NDK_ARCH='mips64'
    NDK_ABIARCH='mips64el-linux-android'
    NDK_CROSS_PREFIX="${NDK_ABIARCH}"
    CFLAGS="$CFLAGS -EL -mfp64 -mhard-float"
  ;;
esac

# cmeng: must ensure AS JNI uses the same STL library or "system" if specified
# Create standalone toolchains for the specified architecture - use .py instead of the old .sh
  [ -d ${TOOLCHAIN_PREFIX} ] || python $NDK/build/tools/make_standalone_toolchain.py \
    --arch ${NDK_ARCH} \
    --api ${ANDROID_API} \
    --stl=libc++ \
    --install-dir=${TOOLCHAIN_PREFIX}

# old .sh replaced with .py
#[ -d ${TOOLCHAIN_PREFIX} ] || $NDK/build/tools/make-standalone-toolchain.sh \
#  --toolchain=${NDK_ABIARCH}-${NDK_ABI_VERSION} \
#  --platform=android-$ANDROID_API \
#  --install-dir=${TOOLCHAIN_PREFIX}

# Direct NDK path without copying - not advise to use this
# OS_ARCH=`basename $ANDROID_NDK/toolchains/arm-linux-androideabi-$NDK_ABI_VERSION/prebuilt/*`
# PREBUILT=$ANDROID_NDK/toolchains/$NDK_ABIARCH-$NDK_ABI_VERSION/prebuilt/$OS_ARCH
# export PLATFORM=$ANDROID_NDK/platforms/android-$ANDROID_API/arch-$NDK_ARCH
# export CROSS_PREFIX=$PREBUILT/bin/$NDK_CROSS_PREFIX-

NDK_SYSROOT=${TOOLCHAIN_PREFIX}/sysroot
PREFIX=$BASEDIR/build/ffmpeg/android/$1
FFMPEG_PKG_CONFIG=${BASEDIR}/ffmpeg-pkg-config

# Add the standalone toolchain to the search path.
export PATH=$TOOLCHAIN_PREFIX/bin:$PATH
export CROSS_PREFIX=$TOOLCHAIN_PREFIX/bin/$NDK_CROSS_PREFIX-
export CFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
export CXXFLAGS="$CFLAGS"

# lame work with gcc/g+ and have problem when export LDFLAGS!
if [[ $0 = *"lame"* ]]; then
  export LDFLAGS=""
else
  export LDFLAGS="-Wl,-rpath-link=$NDK_SYSROOT/usr/lib -L$NDK_SYSROOT/usr/lib $LDFLAGS"
fi

export CC="${CROSS_PREFIX}clang"
export CXX="${CROSS_PREFIX}clang++"
export AS="${CROSS_PREFIX}clang"
export AR="${CROSS_PREFIX}ar"
export LD="${CROSS_PREFIX}ld"
export RANLIB="${CROSS_PREFIX}ranlib"
export STRIP="${CROSS_PREFIX}strip"
export OBJDUMP="${CROSS_PREFIX}objdump"
export CPP="${CROSS_PREFIX}cpp"
export GCONV="${CROSS_PREFIX}gconv"
export NM="${CROSS_PREFIX}nm"
export SIZE="${CROSS_PREFIX}size"
export PKG_CONFIG="${CROSS_PREFIX}pkg-config"
export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig

