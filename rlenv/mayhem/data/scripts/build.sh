#!/bin/bash
set -euo pipefail

# RLENV Build Script
# This script rebuilds the application from source located at /rlenv/source/abc/
#
# Original image: ghcr.io/mayhemheroes/abc:master
# Git revision: deb6749b92021d5a5942da39436c56112d314a19

# ============================================================================
# REQUIRED: Change to Source Directory
# ============================================================================
cd /rlenv/source/abc

# ============================================================================
# Clean Previous Build (recommended)
# ============================================================================
# Clean any existing build artifacts
make clean 2>/dev/null || true
rm -f libabc.a src/demo.o src/demo /demo 2>/dev/null || true

# ============================================================================
# Build Commands (NO NETWORK, NO PACKAGE INSTALLATION)
# ============================================================================
# Build the static library
make -j8 libabc.a

# Change to source directory and compile demo
cd src
cp ../libabc.a .
gcc -Wall -g -c demo.c -o demo.o
g++ -g -o demo demo.o libabc.a -lm -ldl -lreadline -lpthread

# ============================================================================
# Copy Artifacts (use 'cat >' for busybox compatibility)
# ============================================================================
cat demo > /demo

# ============================================================================
# Set Permissions
# ============================================================================
chmod 777 /demo 2>/dev/null || true

# ============================================================================
# REQUIRED: Verify Build Succeeded
# ============================================================================
if [ ! -f /demo ]; then
    echo "Error: Build artifact not found at /demo"
    exit 1
fi

if [ ! -x /demo ]; then
    echo "Warning: Build artifact is not executable"
fi

echo "Build completed successfully: /demo"
