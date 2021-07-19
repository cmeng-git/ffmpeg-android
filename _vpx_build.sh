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

### The following scripts are based on vpx v1.6.1, v1.7.0 and v1.8.x configure file options ###
# aTalk v2.6.1 uses libvpx-1.10.0
# aTalk v1.8.1 and below uses libvpx-master i.e. 1.6.1+ (10/13/2017)
# aTalk v1.8.2 uses libvpx-1.8.0
# aTalk v2.3.2 uses libvpx-1.8.2
# aTalk v2.6.1 uses libvpx-1.10.0

## Both problems #1 & #2 below have been fixed by patches from: https://android.googlesource.com/platform/external/libvpx/+/ca30a60d2d6fbab4ac07c63bfbf7bbbd1fe6a583
## However the compiled libjnvpx.so has problem when exec on x86_64 android platform:
## i.e. org.atalk.android A/libc: Fatal signal 31 (SIGSYS), code 1 in tid 5833 (Loop thread: ne), pid 4781 (g.atalk.android)

# 1. libvpx >v1.6.1 has the following errors when build with aTalk; v1.6.1 failed with --enable-pic
# ./i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(deblock_sse2.asm.o): relocation R_386_GOTOFF against preemptible symbol vpx_rv cannot be used when making a shared object
# ./i686-linux-android/4.9.x/../../../../i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(subpixel_mmx.asm.o): relocation R_386_GOTOFF against preemptible symbol # vp8_bilinear_filters_x86_8 cannot be used when making a shared object
# ./i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(subpixel_mmx.asm.o): relocation R_386_GOTOFF against preemptible symbol vp8_bilinear_filters_x86_8 cannot be used when making a shared object
# ./i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(subpixel_sse2.asm.o): relocation R_386_GOTOFF against preemptible symbol vp8_bilinear_filters_x86_8 cannot be used when making a shared object
# ./i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(subpixel_sse2.asm.o): relocation R_386_GOTOFF against preemptible symbol vp8_bilinear_filters_x86_8 cannot be used when making a shared object

# 2. However libvpx-1.6.1 x86_64 has the same error
# ./x86_64-linux-android/bin/ld: error: vpx/android/x86_64/lib/libvpx.a(deblock_sse2.asm.o): requires dynamic R_X86_64_PC32 reloc against 'vpx_rv' which may overflow at runtime; recompile with -fPIC

# set -x

. _settings.sh "$@"

# libvpx v1.10.0
pushd libvpx || exit

if [[ -f "./build/make/version.sh" ]]; then
  version=`"./build/make/version.sh" --bare .`
fi
echo -e "\n\n** BUILD STARTED: vpx-${version} for ${1} **"

case $1 in
  # libvpx does not provide armv5 build option
  armeabi)
    TARGET="armv7-android-gcc --disable-neon --disable-neon-asm"
  ;;
  # need to add --disable-neon-asm for libvpx v1.8.2, otherwise:
  # clang70: error: linker command failed with exit code 1 (use -v to see invocation)
  # ./lib/crtbegin_dynamic.o:crtbegin.c:function _start_main: error: undefined reference to 'main'
  # make[1]: *** [vpx_dsp/arm/intrapred_neon_asm.asm.S.o] Error 1
  # make[1]: *** [vpx_dsp/arm/vpx_convolve_copy_neon_asm.asm.S.o] Error 1
  armeabi-v7a)
    TARGET="armv7-android-gcc --enable-neon --disable-neon-asm"
  ;;
  arm64-v8a)
    # valid arguments to '-mfpu=' are: crypto-neon-fp-armv8 fp-armv8 fpv4-sp-d16 neon neon-fp-armv8 neon-fp16 neon-vfpv4 vfp vfp3 vfpv3
    # vfpv3-d16 vfpv3-d16-fp16 vfpv3-fp16 vfpv3xd vfpv3xd-fp16 vfpv4 vfpv4-d16
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
  # ==> (Unable to invoke compiler: /arm-linux-androideabi-gcc)
  # https://bugs.chromium.org/p/webm/issues/detail?id=1476
  
  # fixed by patch 10.libvpx_configure.sh.patch
  # https://github.com/google/ExoPlayer/issues/3520 (VP9 builds failure with android-ndk-r16 #3520)
  # https://github.com/android-ndk/ndk/issues/190#issuecomment-375164450 (unknown type name __uint128_t on ndk-build #190)
  # Has configure error with Target=arm64-android-gcc which uses incorrect cc i.e. arm-linux-androideabi-gcc;

  # ./asm/sigcontext.h:39:3: error: unknown type name '__uint128_t'
  # GCC has builtin support for the types __int128, unsigned __int128, __int128_t and __uint128_t. Use them to define your own types:
  # typedef __int128 int128_t;
  # typedef unsigned __int128 uint128_t;
  # Standalone toolchains fixed the problem?

  # need --as=yasm which is required by x86 and x86-64; cannot use define in _settings.sh which uses clang
  # see https://github.com/webmproject/libvpx

  # --sdk-path=${NDK} when specified - configure will use SDK toolchains and gcc/g++ as the default compiler/linker
  # must specified --extra-cflags and --libc if use --sdk-path
  # --sdk-path=${NDK} \
  # --extra-cflags="-isystem ${NDK}/sysroot/usr/include/${NDK_ABIARCH} -isystem ${NDK}/sysroot/usr/include" \
  # must specified -libc from standalone toolchains, libvpx configure.sh cannot get the right arch to use

  # SDK toolchains has error with ndk-r18b; however ndk-R17c and ndk-r16b are ok (gcc/g++)
  # SDK toolchains ndk-r18b is working with libvpx v1.10.0 & v1.8.2 without the sdk option

  # Standalone toolchains built has problem with ABIS="armeabi-v7a"
  # /tmp/vpx-conf-31901-2664.o(.ARM.exidx.text.main+0x0): error: undefined reference to '__aeabi_unwind_cpp_pr0'
  #
  # Cannot define option add_ldflags "-Wl,--fix-cortex-a8"
  # Standalone: arm-linux-androideabi-ld: -Wl,--fix-cortex-a8: unknown option

  # Fixed by: https://android.googlesource.com/platform/external/libvpx/+/ca30a60d2d6fbab4ac07c63bfbf7bbbd1fe6a583
  # libvpx has the following errors for x86 and x86_64 when build in aTalk app;
  # ./i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(deblock_sse2.asm.o): relocation R_386_GOTOFF against preemptible symbol vpx_rv cannot be used when making a shared object
  # ./i686-linux-android/4.9.x/../../../../i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(subpixel_mmx.asm.o): relocation R_386_GOTOFF against preemptible symbol # vp8_bilinear_filters_x86_8 cannot be used when making a shared object
  # ./i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(subpixel_mmx.asm.o): relocation R_386_GOTOFF against preemptible symbol vp8_bilinear_filters_x86_8 cannot be used when making a shared object
  # ./i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(subpixel_sse2.asm.o): relocation R_386_GOTOFF against preemptible symbol vp8_bilinear_filters_x86_8 cannot be used when making a shared object
  # ./i686-linux-android/bin/ld: error: vpx/android/x86/lib/libvpx.a(subpixel_sse2.asm.o): relocation R_386_GOTOFF against preemptible symbol vp8_bilinear_filters_x86_8 cannot be used when making a shared object
  # ./x86_64-linux-android/bin/ld: error: vpx/android/x86_64/lib/libvpx.a(deblock_sse2.asm.o): requires dynamic R_X86_64_PC32 reloc against 'vpx_rv' which may overflow at runtime; recompile with -fPIC

  # Need --disable-avx2 to fix x86_64 problem OR enable --enable-runtime-cpu-detect option
  # org.atalk.android A/libc: Fatal signal 4 (SIGILL), code 2 (ILL_ILLOPN), fault addr 0x77b2ac1757e6 in tid 20780 (Loop thread: ne), pid 20363 (g.atalk.android)
  # see https://bugs.chromium.org/p/webm/issues/detail?id=1623#c1
  # OR use option --enable-runtime-cpu-detect for x86/x86_64 ABIS platforms

CPU_DETECT="--disable-runtime-cpu-detect"
if [[ $1 =~ x86.* ]]; then
   CPU_DETECT="--enable-runtime-cpu-detect"
fi

# When use --sdk-path option for libvpx v1.8.0; must use android-ndk-r17c or lower
# For libvpx v1.8.2+: in order to use standalone toolchanis, must not specified --sdk-path (option removed)
#    --sdk-path=${NDK}

if [[ -f "config.log" ]]; then
  config_target="$(grep "Configuring for target" < "config.log" | sed "s/^.* '\(.*\)'$/\1/")"
  if [[ ${TARGET} != "${config_target}" ]]; then
    make clean
  fi
else
  make clean
fi

#  --extra-cflags="-isystem ${NDK_SYSROOT}/usr/include/${NDK_ABIARCH} -isystem ${NDK_SYSROOT}/usr/include" \
#  --libc=${NDK_SYSROOT} \

./configure \
  --prefix=${PREFIX} \
  --target=${TARGET} \
  --as=yasm \
  --enable-pic \
  --disable-docs \
  --enable-static \
  --enable-libyuv \
  --disable-examples \
  --disable-tools \
  --disable-debug \
  --disable-unit-tests \
  --enable-realtime-only \
  --enable-vp8 --enable-vp9 \
  --enable-vp9-postproc \
  --enable-vp9-highbitdepth \
  --disable-webm-io || exit 1

make -j${HOST_NUM_CORES} install || exit 1
echo -e "** BUILD COMPLETED: vpx-${version} for ${1} **\n"
popd || true

