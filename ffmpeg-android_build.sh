#!/bin/bash
. settings.sh

# Applying required patches
echo -e "\n*** Applying patches... ***"
. ffmpeg_android_patch.sh

for ((i=0; i < ${#ABIS[@]}; i++))
do
  if [[ $# -eq 0 ]] || [[ "$1" == "${ABIS[i]}" ]]; then
    # Do not build 64-bit ABI if ANDROID_API is less than 21 - minimum supported API level for 64 bit.
    [[ ${ANDROID_API} < 21 ]] && ( echo "${ABIS[i]}" | grep 64 > /dev/null ) && continue;
    rm -rf ${TOOLCHAIN_PREFIX}
    # $1 = architecture
    # $2 = required for procced to start setup default compiler environment variables
    ./x264_build.sh "${ABIS[i]}" 1 || exit 1
    #./libpng_build.sh "${ABIS[i]}" 1 || exit 1
    ./lame_build.sh "${ABIS[i]}" 1 || exit 1
    ./ffmpeg_build.sh "${ABIS[i]}" 1 || exit 1
  fi
done
echo -e "*** BUILD COMPLETED ***\n"

