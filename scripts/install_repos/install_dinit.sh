#!/bin/bash
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
REPO_DIR="$BASE_DIR/repos"
mkdir -p "$REPO_DIR"

echo "Cloning dinit..."
cd "$REPO_DIR"
# Replace with your actual dinit repository URL
git clone https://github.com/davmac314/dinit.git
echo "dinit cloned to $REPO_DIR/dinit"
