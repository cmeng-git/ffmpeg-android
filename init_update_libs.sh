#!/bin/bash

# aTalk v2.6.1 is compatible with the following module versions in ():
# a. ffmpeg v4.4 (4.4)
# b. Libvpx v1.10.0 (1.10.0)
# c. X264 v161 (161)

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

wget -O- https://www.ffmpeg.org/releases/ffmpeg-4.4.tar.bz2 | tar xj --strip-components=1 --one-top-level=ffmpeg
wget -O- https://github.com/webmproject/libvpx/archive/v1.10.0.tar.gz | tar xz --strip-components=1 --one-top-level=libvpx
git clone https://code.videolan.org/videolan/x264.git --branch stable
wget -O- https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz | tar xz --strip-components=1 --one-top-level=lame
wget -O- https://sourceforge.net/projects/opencore-amr/files/opencore-amr/opencore-amr-0.1.5.tar.gz | tar xz --strip-components=1 --one-top-level=opencore-amr
# wget -O- ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.34.tar.xz | tar xz

# pre-run configure for ffmpeg to create some script file
pushd ffmpeg || return
./configure
popd || exit

echo "======== Completed sub modules update ===================================="

