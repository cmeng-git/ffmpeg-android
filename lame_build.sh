#!/bin/bash
echo -e "\n\n** BUILD STARTED: lame for ${1} **"
. settings.sh $*

pushd lame-3.99.5
make clean

./configure \
  --prefix=$PREFIX \
  --host="$HOST" \
  --with-pic \
  --enable-static \
  --disable-shared || exit 1

make -j${HOST_NUM_CORES} install || exit 1
popd
echo -e "** BUILD COMPLETED: lame for ${1} **\n"
