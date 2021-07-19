#!/bin/bash
# set -x

# aTalk v2.6.1 is compatible with the following module versions:
# a. ffmpeg-v4.4
# b. x264-v161.3049 #define X264_VERSION "r3049 55d517b"
# c. Libvpx-v1.10.0

if [[ $# -eq 3 ]]; then
  VERSION_FFMPEG=$1
  VERSION_X264=$2
  VERSION_VPX=$3
else
  VERSION_FFMPEG=4.4
  VERSION_X264=163
  VERSION_VPX=v1.10.0
fi

VERSION_LAME=3.100
VERSION_OPENCORE='0.1.5'

LIB_FFMPEG=ffmpeg
LIB_X264=x264
LIB_VPX=libvpx
LIB_LAME=lame
LIB_OPENCORE=opencore-amr

# ================================================================================
echo -e "\n========== init library for: $LIB_FFMPEG ($VERSION_FFMPEG) =========="
if [[ -d $LIB_FFMPEG ]]; then
  version_ffmpeg=$(cat ${LIB_FFMPEG}/RELEASE)
  if [[ $VERSION_FFMPEG == "$version_ffmpeg" ]]; then
    echo -e "\n========== Current ffmpeg source is: $LIB_FFMPEG ($version_ffmpeg) =========="
  else
    rm -rf $LIB_FFMPEG
  fi
fi

if [[ ! -d $LIB_FFMPEG ]]; then
  echo -e "\n========== Fetching library source for: $LIB_FFMPEG ($VERSION_FFMPEG) =========="
  wget -O- https://www.ffmpeg.org/releases/ffmpeg-${VERSION_FFMPEG}.tar.bz2 | tar xj --strip-components=1 --one-top-level=ffmpeg
fi

# ================================================================================
echo -e "\n========== init library for: $LIB_X264 ($VERSION_X264) =========="
if [[ -d $LIB_X264 ]]; then
  version_x264="$(grep '#define X264_BUILD' < ${LIB_X264}/x264.h | sed 's/^.* \([1-9][0-9]*\).*$/\1/')"
  if [[ $VERSION_X264 == "$version_x264" ]]; then
    echo -e "\n========== Current x264 source is: $LIB_X264 ($version_x264) =========="
  else
    rm -rf $LIB_X264
  fi
fi

if [[ ! -d $LIB_X264 ]]; then
  echo -e "\n==========  Fetching library source for: $LIB_X264 ($VERSION_X264) =========="
  git clone https://code.videolan.org/videolan/x264.git --branch stable
fi

# ================================================================================
echo -e "\n========== init library for: $LIB_VPX ($VERSION_VPX) =========="
if [[ -d ${LIB_VPX} ]] && [[ -f "${LIB_VPX}/build/make/version.sh" ]]; then
  version_vpx=`"${LIB_VPX}/build/make/version.sh" --bare "${LIB_VPX}"`
  if [[ (${VERSION_VPX} == "${version_vpx}") ]]; then
    echo -e "\n========== Current libvpx source is: ${LIB_VPX} (${version_vpx}) =========="
  else
    rm -rf $LIB_VPX
  fi
else
  rm -rf $LIB_VPX
fi

if [[ ! -d ${LIB_VPX} ]]; then
  echo -e "\n========== Fetching library source for: ${LIB_VPX} (${VERSION_VPX}) =========="
  wget -O- https://github.com/webmproject/libvpx/archive/refs/tags/${VERSION_VPX}.tar.gz | tar xz --strip-components=1 --one-top-level=${LIB_VPX}
fi

# ================================================================================
echo -e "\n========== init library for: $LIB_LAME ($VERSION_LAME) =========="
if [[ -d $LIB_LAME ]]; then
  version_lame="$(grep 'PACKAGE_VERSION=' < ${LIB_LAME}/configure | sed 's/^.*\([1-9]\.[0-9]*\).*$/\1/')"
  if [[ (${VERSION_LAME} == "${version_lame}") ]]; then
    echo -e "\n========== Current lame source is: ${LIB_LAME} (${version_lame}) =========="
  else
    rm -rf $LIB_LAME
  fi
fi

if [[ ! -d $LIB_LAME ]]; then
  echo -e "\n========== Fetching library source for: ${LIB_LAME} (${VERSION_VPX}) =========="
  wget -O- https://sourceforge.net/projects/lame/files/lame/${VERSION_LAME}/lame-${VERSION_LAME}.tar.gz | tar xz --strip-components=1 --one-top-level=${LIB_LAME}
fi

# ================================================================================
echo -e "\n========== init library for: $LIB_OPENCORE ($VERSION_OPENCORE) =========="
if [[ -d $LIB_OPENCORE ]]; then
  version_opencore="$(grep 'PACKAGE_VERSION=' < ${LIB_OPENCORE}/configure | sed 's/^.*\([0-9]\.[0-9]\.[0-9]*\).*$/\1/')"
  if [[ (${VERSION_OPENCORE} == "${version_opencore}") ]]; then
    echo -e "\n========== Current opencore source is: ${LIB_OPENCORE} (${version_opencore}) =========="
  else
    rm -rf $LIB_LIB_OPENCORE
  fi
fi

if [[ ! -d $LIB_OPENCORE ]]; then
  echo -e "\n========== Fetching library source for: ${LIB_OPENCORE} (${VERSION_VPX}) =========="
  wget -O- https://sourceforge.net/projects/opencore-amr/files/opencore-amr/opencore-amr-${VERSION_OPENCORE}.tar.gz | tar xz --strip-components=1 --one-top-level=${LIB_OPENCORE}
fi

# rm -rf libpng-*
# wget -O- ftp://ftp-osl.osuosl.org/pub/libpng/src/libpng16/libpng-1.6.34.tar.xz | tar xz
echo "========== Completed sub modules update =========="


