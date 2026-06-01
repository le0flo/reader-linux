#!/bin/sh

PREFIX="distro"

KERNEL_NAME="linux-7.0.10"
KERNEL_ARCHIVE="$KERNEL_NAME.tar.xz"
KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v7.x/$KERNEL_ARCHIVE"
KERNEL_DEVICE="virt"

GLIBC_NAME="glibc-2.43"
GLIBC_ARCHIVE="$GLIBC_NAME.tar.xz"
GLIBC_URL="https://ftp.gnu.org/gnu/glibc/$GLIBC_ARCHIVE"

GCC_NAME="gcc-15.2.0"
GCC_ARCHIVE="$GCC_NAME.tar.xz"
GCC_URL="https://ftp.gwdg.de/pub/misc/gcc/releases/$GCC_NAME/$GCC_ARCHIVE"

BUSYBOX_NAME="busybox-1.38.0"
BUSYBOX_ARCHIVE="$BUSYBOX_NAME.tar.bz2"
BUSYBOX_URL="https://busybox.net/downloads/$BUSYBOX_ARCHIVE"

KOREADER_NAME="koreader-linux-arm64-v2026.03"
KOREADER_ARCHIVE="$KOREADER_NAME.tar.xz"
KOREADER_URL="https://github.com/koreader/koreader/releases/download/v2026.03/$KOREADER_ARCHIVE"

create_initrd() {
  mkdir -p initramfs/{boot,dev,data/{books,koreader},opt,proc,sys,usr/lib}
  cd initramfs

  ln -s usr/lib lib
  echo '#!/bin/sh

  mount -t sysfs /sys /sys
  mount -t proc /proc /proc
  mount -t devtmpfs /dev /dev

  export LD_LIBRARY_PATH="/lib:/opt/koreader/lib/koreader/libs"
  export KO_HOME="/data/koreader"
  export SDL_VIDEODRIVER="kmsdrm"

  sh' > init
  chmod +x init

  cd ..
}

fetch_kernel() {
  if [ ! -e $KERNEL_ARCHIVE ]; then
    wget $KERNEL_URL
  fi

  if [ ! -d $KERNEL_NAME ]; then
    tar xvf $KERNEL_ARCHIVE
  fi

  cp ../src/configs/linux-$KERNEL_DEVICE.config $KERNEL_NAME/.config
}

fetch_glibc() {
  if [ ! -e $GLIBC_ARCHIVE ]; then
    wget $GLIBC_URL
  fi

  if [ ! -d $GLIBC_NAME ]; then
    tar xvf $GLIBC_ARCHIVE
  fi

  mkdir -p build-$GLIBC_NAME
}

fetch_gcc() {
  if [ ! -e $GCC_ARCHIVE ]; then
    wget $GCC_URL
  fi

  if [ ! -d $GCC_NAME ]; then
    tar xvf $GCC_ARCHIVE
  fi

  mkdir -p {build-$GCC_NAME,toolchain-$GCC_NAME}
}

fetch_busybox() {
  if [ ! -e $BUSYBOX_ARCHIVE ]; then
    wget $BUSYBOX_URL
  fi

  if [ ! -d $BUSYBOX_NAME ]; then
    tar xvf $BUSYBOX_ARCHIVE
  fi

  cp ../src/configs/busybox.config $BUSYBOX_NAME/.config
}

fetch_koreader() {
  if [ ! -e $KOREADER_ARCHIVE ]; then
    wget $KOREADER_URL
  fi

  if [ ! -d initramfs/opt/koreader ]; then
    mkdir -p initramfs/opt/koreader
    tar xvf $KOREADER_ARCHIVE -C initramfs/opt/koreader
  fi
}

CURRENT_DIR=`pwd`
cd $PREFIX

create_initrd

fetch_kernel
fetch_glibc
fetch_gcc
fetch_busybox
fetch_koreader

cd $CURRENT_DIR

echo -e "\n*** OS components downloaded and configured.\n*** Now you can start building them.\n"
