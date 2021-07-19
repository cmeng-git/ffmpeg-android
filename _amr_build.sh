#!/bin/bash
. _settings.sh "$@"

pushd opencore-amr || exit

AMR_API="$(grep 'PACKAGE_VERSION=' < ${LIB_OPENCORE}/configure | sed 's/^.*\([0-9]\.[0-9]\.[0-9]*\).*$/\1/')"
echo -e "\n\n** BUILD STARTED: opencore-amr-v${AMR_API} for ${1} **"

# --disable-asm disable
# Must exclude the option for arm64-v8a.
# The option is used by configure, config.mak and Makefile files to define AS and to compile required *.S assembly files;
# Otherwise will have undefined references e.g. x264_8_pixel_sad_16x16_neon if --disable-asm is specified
# However must include the option for x86 and x86_64;
# Otherwise have relocate text, requires dynamic R_X86_64_PC32 etc when use in aTalk

DISASM=""
if [[ $1 =~ x86.* ]]; then
   DISASM="--disable-asm"
fi

make clean
./configure \
  --prefix=${PREFIX} \
  --includedir=${PREFIX}/include/x264 \
  --cross-prefix=${CROSS_PREFIX} \
  --sysroot=${NDK_SYSROOT} \
  --extra-cflags="-isystem ${NDK_SYSROOT}/usr/include/${NDK_ABIARCH} -isystem ${NDK_SYSROOT}/usr/include" \
  --host=${HOST} \
  --enable-pic \
  --enable-static \
  --enable-shared \
  --disable-opencl \
  --disable-thread \
  ${DISASM} \
  --disable-cli || exit 1

make -j${HOST_NUM_CORES} install || exit 1
echo -e "** BUILD COMPLETED: opencore-amr-v${AMR_API} for ${1} **\n"
popd || true
