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
# set -x

# https://gcc.gnu.org/onlinedocs/gcc-4.9.4/gcc/Link-Options.html#Link-Options
# Data relocation and protection (RELRO): LDLFAGS="-z relro -z now"
# i686-linux-android-ld: -Wl,-z,relro -Wl,-z,now: unknown options
# lame checks stdlib for linkage! omit -nostdlib

# LDFLAGS='-pie -fuse-ld=gold -Wl,-z,relro -Wl,-z,now -nostdlib -lc -lm -ldl -llog'
# -fuse-ld=gold: use ld.gold linker but unavailable for ABI mips and mips64
LDFLAGS='-pie -lc -lm -ldl -llog'

. _settings.sh $*

pushd ffmpeg
if [[ -f "./ffbuild/version.sh" ]]; then
  VERSION=$(./ffbuild/version.sh .)
else
  VERSION=$(./version.sh .)
fi
echo -e "\n\n** BUILD STARTED: ffmpeg-v${VERSION} for ${1} **"

case $1 in
  armeabi)
    LDFLAGS="${LDFLAGS} -Wl,-z,relro -Wl,-z,now"
  ;;
  armeabi-v7a)
    LDFLAGS="${LDFLAGS} -Wl,-z,relro -Wl,-z,now -Wl,--fix-cortex-a8"
  ;;
  arm64-v8a)
    #  -Wl,--unresolved-symbols=ignore-in-shared-libs fixes x264 undefined references for arm64-v8a
    LDFLAGS="${LDFLAGS} -Wl,-z,relro -Wl,-z,now  -Wl,--unresolved-symbols=ignore-in-shared-libs"
  ;;
  x86)
    LDFLAGS="${LDFLAGS}"
  ;;
  x86_64)
    LDFLAGS="${LDFLAGS}"
  ;;
  mips)
    LDFLAGS="${LDFLAGS} -Wl,-z,relro -Wl,-z,now"
  ;;
  mips64)
    LDFLAGS="${LDFLAGS} -Wl,-z,relro -Wl,-z,now"
  ;;
esac
# export LDFLAGS="-Wl,-rpath-link=${NDK_SYSROOT}/usr/lib -L${NDK_SYSROOT}/usr/lib ${LDFLAGS}"

INCLUDES=""
LIBS=""
MODULES=""

for m in "$@"
  do
    PREFIX_=${BASEDIR}/jni/$m/android/$1
    # PREFIX_=../jni/$m/android/$1
    [ -d ${PREFIX}/lib/pkgconfig ] || mkdir -p ${PREFIX}/lib/pkgconfig

    case $m in
      x264)
        INCLUDES="${INCLUDES} -I${PREFIX_}/include/$m"
        LIBS="${LIBS} -L${PREFIX_}/lib"
        cp -r ${PREFIX_}/lib/pkgconfig ${PREFIX}/lib
        MODULES="${MODULES} --enable-libx264 --enable-version3"
      ;;
      vpx)
        INCLUDES="${INCLUDES} -I${PREFIX_}/include"
        LIBS="${LIBS} -L${PREFIX_}/lib"
        cp -r ${PREFIX_}/lib/pkgconfig ${PREFIX}/lib
        MODULES="${MODULES} --enable-libvpx"
      ;;
      png)
        INCLUDES="${INCLUDES} -I${PREFIX_}/include"
        LIBS="${LIBS} -L${PREFIX_}/lib"
        cp -r ${PREFIX_}/lib/pkgconfig ${PREFIX}/lib
        MODULES="${MODULES} --enable-libpng"
      ;;
      lame)
        INCLUDES="${INCLUDES} -I${PREFIX_}/include"
        LIBS="${LIBS} -L${PREFIX_}/lib"
        # cp -r ${PREFIX_}/lib/pkgconfig ${PREFIX}/lib/pkgconfig
        MODULES="${MODULES} --enable-libmp3lame"
      ;;
    esac
 done


# libvpx does not support the build of share library
#
# --enable-gpl required for libpostproc build
# --disable-postproc: https://trac.ffmpeg.org/wiki/Postprocessing
# Anyway, most of the time it won't help to postprocess h.264, HEVC, VP8, or VP9 video.

# do no set ld option and use as=gcc for clang
TC_OPTIONS="--nm=${NM} --ar=${AR} --as=${CROSS_PREFIX}gcc --strip=${STRIP} --cc=${CC} --cxx=${CXX}"
# Below option not valid for ffmpeg-v1.0.10 (aTalk)
# CODEC_DISABLED='--disable-alsa --disable-appkit --disable-avfoundation --disable-libv4l2 --disable-audiotoolbox'
# --disable-programs   --enable-x86asm \

FFMPEG_PKG_CONFIG=${BASEDIR}/ffmpeg-pkg-config
# FFMPEG_PKG_CONFIG=../ffmpeg-pkg-config
# PREFIX="../jni/ffmpeg/android/$1"
#  --disable-ffserver \ # valid for ffmpeg-1.0.10 only

#  Must include option --disable-asm for x86, otherwise
# libavcodec/x86/cabac.h:193:9: error: inline assembly requires more registers than available
# ffmpeg-1.0.10 has inline assembly error when using clang
DISASM=""
if [[ $1 =~ x86.* ]] || [[ "${VERSION}" == 1.0.10 ]]; then
   DISASM="--disable-asm"
fi

PROGRAM="--disable-programs"
if [[ ${VERSION} == 1.0.10 ]]; then
  PROGRAM="--disable-ffserver"
fi

make clean
./configure \
  --prefix=${PREFIX} \
  --cross-prefix=${CROSS_PREFIX} \
  --sysroot=${NDK_SYSROOT} \
  --target-os=android \
  --arch=${NDK_ARCH} \
  --cpu=${CPU} \
  ${DISASM} \
  ${TC_OPTIONS} \
  --enable-cross-compile \
  --enable-static \
  --disable-shared \
  --enable-pic \
  --disable-doc \
  --disable-debug \
  --disable-runtime-cpudetect \
  --disable-pthreads \
  --enable-hardcoded-tables \
  ${MODULES} \
  ${PROGRAM} \
  --enable-gpl \
  --disable-postproc \
  --disable-ffmpeg \
  --disable-ffplay \
  --disable-ffprobe \
  --extra-cflags="${INCLUDES} ${CFLAGS}" \
  --extra-ldflags="${LIBS} ${LDFLAGS}" \
  --extra-cxxflags="$CXXFLAGS" \
  --extra-libs="-lgcc" \
  --pkg-config=${FFMPEG_PKG_CONFIG} || exit 1

make -j${HOST_NUM_CORES} && make install || exit 1
popd

echo -e "** BUILD COMPLETED: ffmpeg-v${VERSION} for ${1} **\n"
