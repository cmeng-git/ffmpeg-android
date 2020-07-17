#!/bin/bash

# aTalk v2.3.2 is only compatible with the following module versions:
# a. ffmpeg v4.1.1
# b. libvpx-1.8.2
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
rm -rf opencore-amr
# rm -rf libpng-*

wget -O- https://www.ffmpeg.org/releases/ffmpeg-4.1.1.tar.gz | tar xz --strip-components=1 --one-top-level=ffmpeg
wget -O- https://github.com/webmproject/libvpx/archive/v1.8.2.tar.gz | tar xz --strip-components=1 --one-top-level=libvpx
git clone https://code.videolan.org/videolan/x264.git --branch stable
wget -O- https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz | tar xz --strip-components=1 --one-top-level=lame
# wget -O- https://sourceforge.net/projects/opencore-amr/files/opencore-amr/opencore-amr-0.1.5.tar.gz | tar xz --strip-components=1 --one-top-level=opencore-amr
# wget -O- ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.34.tar.xz | tar xz

echo "======== Completed sub modules update ===================================="

