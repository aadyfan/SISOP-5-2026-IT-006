#!/bin/bash

set -e

OUTPUT="osboot/single.gz"
ROOTFS="rootfs_single"

echo "=== Building Single-User Filesystem ==="

rm -rf "${ROOTFS}"
mkdir -p "${ROOTFS}"

mkdir -p "${ROOTFS}"/{bin,dev,proc,sys,etc,tmp,root}

cp $(which busybox) "${ROOTFS}/bin/busybox"

cd "${ROOTFS}/bin"
for applet in $(./busybox --list); do
    ln -sf busybox "${applet}" 2>/dev/null || true
done
cd ../../

printf '#!/bin/sh\nmount -t proc none /proc\nmount -t sysfs none /sys\nmount -t devtmpfs none /dev 2>/dev/null || mdev -s\nifconfig eth0 up\nip addr add 10.0.2.15/24 dev eth0\nip route add default via 10.0.2.2\necho "nameserver 8.8.8.8" > /etc/resolv.conf\necho "================================"\necho "  Farewell Party"\necho "  Welcome, root."\necho "================================"\nexec /bin/sh\n' > "${ROOTFS}/init"
chmod +x "${ROOTFS}/init"

printf 'root:x:0:0:root:/root:/bin/sh\n' > "${ROOTFS}/etc/passwd"
printf 'root:root123:0:0:99999:7:::\n' > "${ROOTFS}/etc/shadow"
chmod 640 "${ROOTFS}/etc/shadow"

cp ~/soal_1/party_pkg.sh "${ROOTFS}/bin/party"
chmod +x "${ROOTFS}/bin/party"


mkdir -p "${ROOTFS}/lib" "${ROOTFS}/usr/lib" "${ROOTFS}/sbin"
cp /usr/bin/fusermount3 "${ROOTFS}/bin/fusermount" 2>/dev/null || true
cp /sbin/mount.fuse* "${ROOTFS}/sbin/" 2>/dev/null || true
find /usr/lib/aarch64-linux-gnu/ -name "libfuse*" -exec cp {} "${ROOTFS}/lib/" \; 2>/dev/null || true
find /lib/aarch64-linux-gnu/ -name "libfuse*" -exec cp {} "${ROOTFS}/lib/" \; 2>/dev/null || true

mkdir -p "${ROOTFS}/lib" "${ROOTFS}/dev"
find /lib/aarch64-linux-gnu/ -name "libfuse*" -exec cp {} "${ROOTFS}/lib/" \; 2>/dev/null || true
find /usr/lib/aarch64-linux-gnu/ -name "libfuse*" -exec cp {} "${ROOTFS}/lib/" \; 2>/dev/null || true
cp /usr/bin/fusermount3 "${ROOTFS}/bin/fusermount3" 2>/dev/null || true
ln -sf fusermount3 "${ROOTFS}/bin/fusermount" 2>/dev/null || true

cp ~/soal_1/hello_fuse "${ROOTFS}/bin/hello_fuse"

for lib in $(ldd ~/soal_1/hello_fuse | grep -o '/lib[^ ]*'); do
    cp "${lib}" "${ROOTFS}/lib/" 2>/dev/null || true
done

echo "=== Packing into ${OUTPUT} ==="
cd "${ROOTFS}"
find . | cpio -o -H newc | gzip > "../${OUTPUT}"
cd ..

rm -rf "${ROOTFS}"

echo "=== Done! Single-user filesystem saved to ${OUTPUT} ==="