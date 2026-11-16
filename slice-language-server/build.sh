#!/bin/bash

# An array of the target triples
TARGETS=(
  "aarch64-apple-darwin"
  "x86_64-apple-darwin"
  "x86_64-unknown-linux-gnu"
  "aarch64-unknown-linux-gnu"
  "x86_64-pc-windows-gnu"
)

export CROSS_CONTAINER_OPTS="--platform linux/amd64"

# The extension packages the binaries from its own server/target folder.
TARGET_DIR=../vscode-extension/server/target

cargo install cross || exit 1

# Loop through each target and build
for TARGET in "${TARGETS[@]}"; do
  echo "Building for $TARGET..."
  cross build --release --target "$TARGET" --target-dir "$TARGET_DIR" || exit 1
done
