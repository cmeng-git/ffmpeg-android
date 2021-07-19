#!/bin/bash

. _settings.sh "$@"

pushd lame || exit
LAME_VER="$(grep 'PACKAGE_VERSION=' < ./configure | sed 's/^.*\([1-9]\.[0-9]*\).*$/\1/')"
echo -e "\n\n** BUILD STARTED: lame-v${LAME_VER} for ${1} **"

make clean

# prefix path must be absolute for lame
./configure \
  --prefix=${PREFIX} \
  --host="${HOST}" \
  --with-pic \
  --enable-static \
  --enable-nasm \
  --disable-analyzer-hooks \
  --disable-frontend \
  --disable-shared || exit 1

make -j${HOST_NUM_CORES} install || exit 1
echo -e "** BUILD COMPLETED: lame-v${LAME_VER} for ${1} **\n"
popd || exit
