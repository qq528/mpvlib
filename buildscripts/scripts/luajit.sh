#!/bin/bash -e

. ../../include/path.sh

if [ "$1" == "build" ]; then
	true
elif [ "$1" == "clean" ]; then
	# 不带 TARGET_SYS 时按宿主 Darwin 解析，会误报缺少 MACOSX_DEPLOYMENT_TARGET
	make clean TARGET_SYS=Linux
	exit 0
else
	exit 255
fi

# LuaJIT only supports in-tree builds and does not keep
# target-specific artifacts apart, so we always do a clean build.
$0 clean

# 宿主自举工具 minilua 会继承环境 LDFLAGS，里面的 Android 链接参数
# 在 macOS 宿主上非法；静态模式下目标侧只归档不链接，可以安全清掉。
unset LDFLAGS

# LuaJIT's host tools must have the same pointer size as the target.
host_cc=gcc
[[ "$ndk_triple" == "arm"* || "$ndk_triple" == "i686"* ]] && host_cc="gcc -m32"

# -fPIC on the static library too, since it is linked into libmpv.so.
make -j$cores \
	HOST_CC="$host_cc" \
	CROSS="$ndk_triple-" \
	STATIC_CC="$CC -fPIC" DYNAMIC_CC="$CC -fPIC" \
	TARGET_LD="$CC" TARGET_AR="$AR rcus" TARGET_STRIP=llvm-strip \
	TARGET_SYS=Linux BUILDMODE=static \
	PREFIX="$prefix_dir"

make PREFIX="$prefix_dir" install
