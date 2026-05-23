#!/bin/bash
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
REPO_DIR="$BASE_DIR/repos"
mkdir -p "$REPO_DIR"

echo "Downloading BusyBox..."
cd "$REPO_DIR"
wget https://busybox.net/downloads/busybox-1.36.1.tar.bz2
tar -xjf busybox-1.36.1.tar.bz2
# We keep the versioned folder for build stability
echo "BusyBox extracted to $REPO_DIR/busybox-1.36.1"
rm busybox-1.36.1.tar.bz2
