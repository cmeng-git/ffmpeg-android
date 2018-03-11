#!/bin/bash
. settings.sh

# Applying required patches
patch  -p0 -N --dry-run --silent -f fontconfig/src/fcxml.c < android_donot_use_lconv.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f fontconfig/src/fcxml.c < android_donot_use_lconv.patch
fi

for ((i=0; i < ${#ARCHS[@]}; i++))
do
  if [[ $# -eq 0 ]] || [[ "$1" == "${ARCHS[i]}" ]]; then
    # Do not build 64 bit arch if ANDROID_API is less than 21 - minimum supported API level for 64 bit.
    [[ ${ANDROID_API} < 21 ]] && ( echo "${ARCHS[i]}" | grep 64 > /dev/null ) && continue;
    rm -rf ${TOOLCHAIN_PREFIX}
    # $1 = architecture
    # $2 = required for procced to start setup default compiler environment variables
    ./x264_build.sh "${ARCHS[i]}" 1 || exit 1
    #./libpng_build.sh "${ARCHS[i]}" 1 || exit 1
    ./lame_build.sh "${ARCHS[i]}" 1 || exit 1
    ./ffmpeg_build.sh "${ARCHS[i]}" 1 || exit 1
  fi
done
# rm -rf ${TOOLCHAIN_PREFIX}

echo -e "*** BUILD COMPLETED SUCCESS ***\n"

