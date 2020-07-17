#!/bin/bash
. _settings.sh

# defined modules to be included in ffmpeg built
# if inlcude ffmpeg, then ffmpeg is built without the codec submodule
MODULES=("vpx" "x264" "lame")
FFMPEG_SA=("ffmpeg")

# Build only the specified module if given as second parameter
if [[ $# -eq 2 ]]; then
  MODULES=("$2")
fi

# Applying required patches
. ffmpeg-android_patch.sh

for ((i=0; i < ${#ABIS[@]}; i++))
  do
    if [[ $# -eq 0 ]] || [[ "$1" == "${ABIS[i]}" ]]; then
      # Do not build 64-bit ABI if ANDROID_API is less than 21 - minimum supported API level for 64 bit.
      [[ ${ANDROID_API} < 21 ]] && ( echo "${ABIS[i]}" | grep 64 > /dev/null ) && continue;
      rm -rf ${TOOLCHAIN_PREFIX}

      # $1 = architecture
      # $2 = required for proceed to start setup default compiler environment variables
      for m in "${MODULES[@]}"
      do
        case $m in
          vpx)
            ./_vpx_build.sh "${ABIS[i]}" $m || exit 1
          ;;
          x264)
            ./_x264_build.sh "${ABIS[i]}" $m || exit 1
          ;;
          png)
            # ./_libpng_build.sh "${ABIS[i]}" $m || exit 1
          ;;
          lame)
            ./_lame_build.sh "${ABIS[i]}" $m || exit 1
          ;;
          amrwb)
            # ./_amr_build.sh "${ABIS[i]}" $m || exit 1
          ;;
        esac
      done

      if [[ " ${MODULES[@]} " =~ " ffmpeg " ]]; then
        ./_ffmpeg_build.sh "${ABIS[i]}" 'ffmpeg' "${FFMPEG_SA[@]}" || exit 1
      else
        ./_ffmpeg_build.sh "${ABIS[i]}" 'ffmpeg' "${MODULES[@]}" || exit 1
      fi
    fi
  done

echo -e "*** BUILD COMPLETED ***\n"

