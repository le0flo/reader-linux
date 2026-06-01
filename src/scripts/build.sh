#!/bin/sh

PREFIX="distro"

TARGET_ARCH="aarch64-unknown-linux-gnu"

KERNEL_NAME="linux-7.0.10"
GLIBC_NAME="glibc-2.43"
GCC_NAME="gcc-15.2.0"
BUSYBOX_NAME="busybox-1.38.0"
KOREADER_NAME="koreader-linux-arm64-v2026.03"

NPROC=`nproc`

compile_kernel() {
  make -C $KERNEL_NAME -j$NPROC
  make -C $KERNEL_NAME \
    headers_install \
    INSTALL_HDR_PATH=../initramfs/usr
}

compile_glibc() {
  cd build-$GLIBC_NAME

  ../$GLIBC_NAME/configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --host=$TARGET_ARCH \
    --build="$(gcc -dumpmachine)" \
    --with-headers=$PWD/../initramfs/usr/include \
    --disable-werror \
    BUILD_CC="gcc" \
    CC="${CROSS_COMPILE}gcc" \
    AR="${CROSS_COMPILE}ar" \
    RANLIB="${CROSS_COMPILE}ranlib" \
    NM="${CROSS_COMPILE}nm" \
    OBJCOPY="${CROSS_COMPILE}objcopy" \
    OBJDUMP="${CROSS_COMPILE}objdump" \
    READELF="${CROSS_COMPILE}readelf" \
    STRIP="${CROSS_COMPILE}strip" \
    AS="${CROSS_COMPILE}as"

  make -j$NPROC slibdir=/lib rtlddir=/lib
  make install DESTDIR=$PWD/../initramfs slibdir=/lib rtlddir=/lib

  cd ..
}

compile_gcc() {
  cd build-$GCC_NAME

  ../$GCC_NAME/configure \
    --build="$(gcc -dumpmachine)" \
    --host="$(gcc -dumpmachine)" \
    --target=$TARGET_ARCH \
    --prefix="$PWD/../toolchain-$GCC_NAME" \
    --with-sysroot="$PWD/../initramfs" \
    --with-native-system-header-dir=/usr/include \
    --disable-werror \
    --disable-bootstrap \
    --disable-multilib \
    --disable-nls \
    --enable-shared \
    --disable-libsanitizer \
    --disable-libquadmath \
    --disable-libgomp \
    --disable-libatomic \
    --disable-libitm \
    --disable-libssp \
    --enable-languages=c,c++ \
    CC="${HOST_CC}" \
    CXX="${HOST_CXX}"

  make -j$NPROC all-target-libgcc all-target-libstdc++-v3
  make install-target-libgcc install-target-libstdc++-v3

  cd ..

  cp toolchain-$GCC_NAME/$TARGET_ARCH/lib64/* initramfs/lib/.
}

compile_busybox() {
  make -C $BUSYBOX_NAME -j$NPROC
  make -C $BUSYBOX_NAME install
}

package_initrd() {
  cd initramfs

  find | cpio -o -H newc > ../init.cpio

  cd ..
}

CURRENT_DIR=`pwd`
cd $PREFIX

compile_kernel
compile_glibc
compile_gcc
compile_busybox

package_initrd

cd $CURRENT_DIR

echo -e "\n*** OS components compiled and installed.\n*** Now you can try the newly built system.\n"
