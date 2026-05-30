#!/bin/bash

set -e

TIMESTAMP=$(date +"%d%m%Y-%H%M%S")
OUTPUT="farewell_backup_${TIMESTAMP}.zip"

echo "=== Creating Backup ==="

cd /home/aadyfan/soal_1

zip "${OUTPUT}" \
    osboot/bzImage \
    osboot/single.gz \
    osboot/multi.gz \
    osboot/farewell.iso

mv "${OUTPUT}" osboot/

echo "=== Done! Backup saved to osboot/${OUTPUT} ==="

