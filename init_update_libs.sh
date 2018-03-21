#!/bin/bash

echo -e "\n================= Updating submodules ==========================="
git submodule update --init

# get submodule branch update if any
# git submodule update --remote

echo "============================================"
echo "Updating libvpx, lame and libpng"
# rm -rf libpng-*
rm -rf libvpx-*
rm -rf lame-*

# wget -O- ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.34.tar.xz | tar xz
wget -O- https://github.com/webmproject/libvpx/archive/v1.7.0.tar.gz | tar xz
wget -O- http://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz | tar xz

echo "======== Completed sub modules update ===================================="

