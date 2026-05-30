#!/bin/bash

set -e

KERNEL_VERSION="6.1.1"
KERNEL_DIR="linux-${KERNEL_VERSION}"
KERNEL_TAR="${KERNEL_DIR}.tar.xz"
OUTPUT="osboot/bzImage"

echo "=== Downloading Linux Kernel ${KERNEL_VERSION} ==="
if [ ! -f "${KERNEL_TAR}" ]; then
    wget "https://cdn.kernel.org/pub/linux/kernel/v6.x/${KERNEL_TAR}"
fi

echo "=== Extracting ==="
if [ ! -d "${KERNEL_DIR}" ]; then
    tar -xf "${KERNEL_TAR}"
fi

echo "=== Configuring Kernel ==="
cd "${KERNEL_DIR}"
make defconfig

echo "=== Compiling Kernel ==="
make -j$(nproc)

echo "=== Copying bzImage to osboot/ ==="
cd ..
mkdir -p osboot

if [ -f "${KERNEL_DIR}/arch/arm64/boot/Image" ]; then
    cp "${KERNEL_DIR}/arch/arm64/boot/Image" "${OUTPUT}"
elif [ -f "${KERNEL_DIR}/arch/x86/boot/bzImage" ]; then
    cp "${KERNEL_DIR}/arch/x86/boot/bzImage" "${OUTPUT}"
fi

echo "=== Done! Kernel saved to ${OUTPUT} ==="
