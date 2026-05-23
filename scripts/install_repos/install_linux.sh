#!/bin/bash
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
REPO_DIR="$BASE_DIR/repos"
mkdir -p "$REPO_DIR"

echo "Downloading Linux Kernel..."
cd "$REPO_DIR"
# You can update this URL to your preferred kernel version
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.8.tar.xz
tar -xJf linux-6.8.tar.xz
mv linux-6.8 linux
rm linux-6.8.tar.xz
echo "Linux kernel extracted to $REPO_DIR/linux"
