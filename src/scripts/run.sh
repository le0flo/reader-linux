#!/bin/sh

PREFIX="distro"
DEVICE="virt"
CPU="cortex-a53"
MEMORY="2G"

KERNEL_PATH="$PREFIX/linux-7.0.10/arch/arm64/boot/Image"
INITRAMFS_PATH="$PREFIX/init.cpio"

echo -e "\n*** QEMU emulated device: $DEVICE\n*** Allocated memory: $MEMORY\n"

qemu-system-aarch64 \
  -machine $DEVICE \
  -cpu $CPU \
  -m $MEMORY \
  -device "virtio-gpu-pci" \
  -device "virtio-keyboard-pci" \
  -device "virtio-mouse-pci" \
  -kernel $KERNEL_PATH \
  -initrd $INITRAMFS_PATH \
  -append "console=tty0 rdinit=/init"
