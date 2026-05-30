#!/bin/bash

set -e

KERNEL="osboot/bzImage"
SINGLE="osboot/single.gz"
MULTI="osboot/multi.gz"
OUTPUT="osboot/farewell.iso"
ISODIR="iso_build"

echo "=== Building Bootable ISO ==="

rm -rf "${ISODIR}"
mkdir -p "${ISODIR}/boot/grub"

cp "${KERNEL}" "${ISODIR}/boot/bzImage"
cp "${SINGLE}" "${ISODIR}/boot/single.gz"
cp "${MULTI}" "${ISODIR}/boot/multi.gz"

cat > "${ISODIR}/boot/grub/grub.cfg" << 'EOF'
set default=0
set timeout=5

menuentry "Farewell Party - Single User" {
    linux /boot/bzImage
    initrd /boot/single.gz
}

menuentry "Farewell Party - Multi User" {
    linux /boot/bzImage
    initrd /boot/multi.gz
}
EOF

echo "=== Creating ISO with xorriso ==="
grub-mkrescue -o "${OUTPUT}" "${ISODIR}"

rm -rf "${ISODIR}"

echo "=== Done! ISO saved to ${OUTPUT} ==="
