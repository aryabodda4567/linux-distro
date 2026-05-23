#!/bin/bash

# Dynamically find the project root directory
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DISK_DIR="$BASE_DIR/disk"
DISK_IMG="$DISK_DIR/rootfs.img"
FHS_DIR="$BASE_DIR/ext4_template"
MOUNT_DIR="$BASE_DIR/temp_mount"

echo "[2] Allocating 2GB disk image..."
mkdir -p "$DISK_DIR"
dd if=/dev/zero of="$DISK_IMG" bs=1M count=2048

echo "[2] Formatting disk to ext4..."
mkfs.ext4 "$DISK_IMG"

echo "[2] Mounting virtual drive to transfer FHS..."
mkdir -p "$MOUNT_DIR"
sudo mount -o loop "$DISK_IMG" "$MOUNT_DIR"

echo "[2] Copying FHS layout into the ext4 drive..."
sudo cp -a "$FHS_DIR"/* "$MOUNT_DIR"/

echo "[2] Safely unmounting drive..."
sudo umount "$MOUNT_DIR"

echo "[2] Cleaning up temporary FHS directory..."
rm -rf "$FHS_DIR"

echo "[2] Stage-2 ext4 disk successfully compiled and packed."
