#!/usr/bin/env bash
# Build script for grizzarch archiso
# Run this on an Arch Linux system with archiso installed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE_DIR="$SCRIPT_DIR/profile"
WORK_DIR="$SCRIPT_DIR/work"
OUT_DIR="$SCRIPT_DIR/out"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           Grizzarch Archiso Build Script                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if running on Arch
if [ ! -f /etc/arch-release ]; then
    echo "❌ Error: This script must be run on Arch Linux"
    exit 1
fi

# Check if archiso is installed
if ! command -v mkarchiso &> /dev/null; then
    echo "❌ Error: archiso is not installed"
    echo "   Install it with: sudo pacman -S archiso"
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Error: This script must be run as root (use sudo)"
    exit 1
fi

echo "✓ Arch Linux detected"
echo "✓ archiso installed"
echo "✓ Running as root"
echo ""

# Validate profile structure
echo "==> Validating profile structure..."
if [ ! -f "$PROFILE_DIR/profiledef.sh" ]; then
    echo "❌ Error: profiledef.sh not found"
    exit 1
fi

if [ ! -f "$PROFILE_DIR/packages.x86_64" ]; then
    echo "❌ Error: packages.x86_64 not found"
    exit 1
fi

echo "✓ Profile structure valid"
echo ""

# Clean previous builds
if [ -d "$WORK_DIR" ]; then
    echo "==> Cleaning previous build artifacts..."
    rm -rf "$WORK_DIR"
fi

mkdir -p "$OUT_DIR"

# Build the ISO
echo "==> Building ISO with mkarchiso..."
echo ""
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

# Report results
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                   Build Complete!                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "ISO created in: $OUT_DIR"
ls -lh "$OUT_DIR"/*.iso 2>/dev/null || echo "No ISO found (check for errors above)"
echo ""
echo "Next steps:"
echo "  1. Write to USB: sudo dd if=$OUT_DIR/grizzarch-*.iso of=/dev/sdX bs=4M status=progress oflag=sync"
echo "  2. Boot from USB and run: archinstall"
echo "  3. Select the 'grizzarch' profile or use automated install"
echo ""
echo "See archiso/QUICKSTART.md for installation instructions"
