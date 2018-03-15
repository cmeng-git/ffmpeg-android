#!/bin/bash

echo "============================================"
echo "Updating submodules"
git submodule update --init
echo "============================================"
echo "Updating lame and libpng"
# rm -rf libpng-*
rm -rf lame-*

# wget -O- ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.34.tar.xz | tar xJ
wget -O- http://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz | tar xz
echo "======== Completed sub modules update ===================================="

