#!/bin/bash
set -x
# Applying required patches

# ffmpeg patches
patch  -p0 -N --dry-run --silent -f ./ffmpeg/libavcodec/aaccoder.c < ./patches/01.ffmpeg_aacoder.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f ./ffmpeg/libavcodec/aaccoder.c < ./patches/01.ffmpeg_aacoder.patch
fi

patch  -p0 -N --dry-run --silent -f ./ffmpeg/libavcodec/hevc_mvs.c < ./patches/02.ffmpeg_hevc_mvs.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f ./ffmpeg/libavcodec/hevc_mvs.c < ./patches/02.ffmpeg_hevc_mvs.patch
fi

patch  -p0 -N --dry-run --silent -f ./ffmpeg/libavcodec/opus_pvq.c < ./patches/03.ffmpeg_opus_pvq.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f ./ffmpeg/libavcodec/opus_pvq.c < ./patches/03.ffmpeg_opus_pvq.patch
fi

# fontconfig patches
patch  -p0 -N --dry-run --silent -f ./fontconfig/src/fcxml.c < ./patches/11.fontconfig_fcxml.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f ./fontconfig/src/fcxml.c < ./patches/11.fontconfig_fcxml.patch
fi


