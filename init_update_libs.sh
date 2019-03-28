#!/bin/bash

# aTalk v1.7.3 is only compatible with the following module versions:
# a. ffmpeg v1.0.10
# b. libvpx-1.6.1+ (master-20171013.tar.gz) see vpx-android for detail
# c. x264 - not required, use android h264 instead

echo -e "\n================= Updating submodules ==========================="
git submodule update --init

# get submodule branch update if any
# git submodule update --remote

echo "============================================"
echo "Updating ffmpeg, libvpx, x264, and lame"
rm -rf ffmpeg
rm -rf libvpx
rm -rf x264
rm -rf lame
# rm -rf libpng-*

wget -O- https://www.ffmpeg.org/releases/ffmpeg-4.1.1.tar.gz | tar xz --strip-components=1 --one-top-level=ffmpeg
wget -O- https://github.com/webmproject/libvpx/archive/v1.8.0.tar.gz | tar xz --strip-components=1 --one-top-level=libvpx
git clone https://code.videolan.org/videolan/x264.git --branch stable
wget -O- http://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz | tar xz --strip-components=1 --one-top-level=lame
# wget -O- ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.34.tar.xz | tar xz

echo "======== Completed sub modules update ===================================="

