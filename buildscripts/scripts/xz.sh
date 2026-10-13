#!/bin/bash -e

. ../../include/path.sh

build=_build$ndk_suffix

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	rm -rf "$build"
	exit 0
else
	exit 255
fi

# git 克隆的源码不含发行包自带的 configure，先按需生成
[ -f configure ] || ./autogen.sh

mkdir -p "$build"
cd "$build"

CFLAGS="${CFLAGS:-} -fPIC" ../configure \
	--host="$ndk_triple" \
	--prefix=/usr/local \
	--enable-static \
	--disable-shared \
	--disable-xz \
	--disable-xzdec \
	--disable-lzmadec \
	--disable-lzmainfo \
	--disable-scripts \
	--disable-doc \
	--disable-nls \
	--enable-threads=no

make -j"$cores"
make DESTDIR="$prefix_dir" install
