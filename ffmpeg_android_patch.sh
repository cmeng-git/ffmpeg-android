#!/bin/bash
set -x
# Applying required patches

# ===============================
# ffmpeg patches
# ===============================
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

patch  -p0 -N --dry-run --silent -f ./ffmpeg/libaudevice/v4l2.c < ./patches/04.ffmpeg_v4l2.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f ./ffmpeg/libaudevice/v4l2.c < ./patches/03.ffmpeg_v4l2.patch
fi

# ===============================
# libvpx patches
# ===============================
patch  -p0 -N --dry-run --silent -f ./libvpx/build/make/configure.sh < ./patches/11.libvpx_configure.sh.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f ./libvpx/build/make/configure.sh < ./patches/11.libvpx_configure.sh.patch
fi

# ===============================
# x264 patches
# ===============================
patch  -p0 -N --dry-run --silent -f ./x264/configure < ./patches/21.x264_configure.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f ./x264/configure < ./patches/21.x264_configure.patch
fi

# ===============================
# lame patches
# ===============================
patch  -p0 -N --dry-run --silent -f ./lame/configure < ./patches/31.lame_configure.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f ./lame/configure < ./patches/31.lame_configure.patch
fi

# ===============================
# fontconfig patches
# ===============================
patch  -p0 -N --dry-run --silent -f ./fontconfig/src/fcxml.c < ./patches/41.fontconfig_fcxml.patch 1>/dev/null
if [ $? -eq 0 ]; then
  patch -p0 -f ./fontconfig/src/fcxml.c < ./patches/41.fontconfig_fcxml.patch
fi
