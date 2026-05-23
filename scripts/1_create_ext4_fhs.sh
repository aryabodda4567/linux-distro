#!/bin/bash

# Dynamically find the project root directory
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FHS_DIR="$BASE_DIR/ext4_template"

echo "[1] Creating FHS directory structure in $FHS_DIR..."

mkdir -p "$FHS_DIR"
cd "$FHS_DIR" || exit

# Create core FHS directories
mkdir -p bin boot dev etc home lib lib64 media mnt opt proc root sbin srv sys tmp usr var

# Create standard subdirectories
mkdir -p usr/bin usr/sbin usr/lib usr/local
mkdir -p var/log var/run var/tmp

echo "[1] FHS structure created successfully."
