#!/bin/bash
echo -e "\n\n** BUILD STARTED: lame for ${1} **"
. _settings.sh $*

pushd lame
make clean

# prefix path must be absolute for lame
./configure \
  --prefix=$PREFIX \
  --host="$HOST" \
  --with-pic \
  --enable-static \
  --disable-shared || exit 1

make -j${HOST_NUM_CORES} install || exit 1
popd
echo -e "** BUILD COMPLETED: lame for ${1} **\n"
