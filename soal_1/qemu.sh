#!/bin/bash

KERNEL="osboot/bzImage"
SINGLE="osboot/single.gz"
MULTI="osboot/multi.gz"
ISO="osboot/farewell.iso"

QEMU_NET="-netdev user,id=net0 -device virtio-net-pci,netdev=net0"

if [ "$1" == "--single" ]; then
    echo "=== Booting Single-User Filesystem ==="
    qemu-system-aarch64 \
        -M virt \
        -cpu cortex-a57 \
        -m 512M \
        -kernel "${KERNEL}" \
        -initrd "${SINGLE}" \
        -append "console=ttyAMA0 rdinit=/init" \
        ${QEMU_NET} \
        -nographic

elif [ "$1" == "--multi" ]; then
    echo "=== Booting Multi-User Filesystem ==="
    qemu-system-aarch64 \
        -M virt \
        -cpu cortex-a57 \
        -m 512M \
        -kernel "${KERNEL}" \
        -initrd "${MULTI}" \
        -append "console=ttyAMA0 rdinit=/init" \
        ${QEMU_NET} \
        -nographic

elif [ "$1" == "--all" ]; then
    echo "=== Booting from ISO ==="
    echo "1) Single User"
    echo "2) Multi User"
    printf "Pilih: "
    read CHOICE
    if [ "$CHOICE" == "1" ]; then
        qemu-system-aarch64 \
            -M virt \
            -cpu cortex-a57 \
            -m 512M \
            -kernel "${KERNEL}" \
            -initrd "${SINGLE}" \
            -append "console=ttyAMA0 rdinit=/init" \
            ${QEMU_NET} \
            -nographic
    else
        qemu-system-aarch64 \
            -M virt \
            -cpu cortex-a57 \
            -m 512M \
            -kernel "${KERNEL}" \
            -initrd "${MULTI}" \
            -append "console=ttyAMA0 rdinit=/init" \
            ${QEMU_NET} \
            -nographic
    fi

else
    echo "Usage: ./qemu.sh [--single | --multi | --all]"
fi