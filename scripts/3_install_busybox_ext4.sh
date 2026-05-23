#!/bin/bash

# Dynamically find the project root directory
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUSYBOX_DIR="$BASE_DIR/repos/busybox-1.36.1"
DISK_IMG="$BASE_DIR/disk/rootfs.img"
MOUNT_DIR="$BASE_DIR/temp_mount"

echo "[3] Compiling BusyBox statically..."
cd "$BUSYBOX_DIR" || exit
make -j$(nproc)

echo "[3] Mounting Stage-2 virtual drive..."
mkdir -p "$MOUNT_DIR"
sudo mount -o loop "$DISK_IMG" "$MOUNT_DIR"

echo "[3] Installing BusyBox directly into the ext4 FHS..."
sudo make CONFIG_PREFIX="$MOUNT_DIR" install

echo "[3] Unmounting and cleaning up..."
sudo umount "$MOUNT_DIR"
rm -rf "$MOUNT_DIR"

echo "[3] BusyBox environment successfully integrated into Stage-2 OS."
