#!/bin/bash

set -e

OUTPUT="osboot/multi.gz"
ROOTFS="rootfs_multi"

echo "=== Building Multi-User Filesystem ==="

rm -rf "${ROOTFS}"
mkdir -p "${ROOTFS}"

mkdir -p "${ROOTFS}"/{bin,dev,proc,sys,etc,tmp,root}
mkdir -p "${ROOTFS}"/home/{henn,hann,viii,kids}

cp $(which busybox) "${ROOTFS}/bin/busybox"

cd "${ROOTFS}/bin"
for applet in $(./busybox --list); do
    ln -sf busybox "${applet}" 2>/dev/null || true
done
cd ../../

# /etc/passwd
printf 'root:x:0:0:root:/root:/bin/sh\n' > "${ROOTFS}/etc/passwd"
printf 'henn:x:1001:1001::/home/henn:/bin/sh\n' >> "${ROOTFS}/etc/passwd"
printf 'hann:x:1002:1002::/home/hann:/bin/sh\n' >> "${ROOTFS}/etc/passwd"
printf 'viii:x:1003:1003::/home/viii:/bin/sh\n' >> "${ROOTFS}/etc/passwd"
printf 'kids:x:1004:1004::/home/kids:/bin/sh\n' >> "${ROOTFS}/etc/passwd"

# /etc/shadow
ROOT_PASS=$(openssl passwd -1 root123)
HENN_PASS=$(openssl passwd -1 henn123)
HANN_PASS=$(openssl passwd -1 hann123)
VIII_PASS=$(openssl passwd -1 viii123)
KIDS_PASS=$(openssl passwd -1 kids123)

printf "root:${ROOT_PASS}:0:0:99999:7:::\n" > "${ROOTFS}/etc/shadow"
printf "henn:${HENN_PASS}:0:0:99999:7:::\n" >> "${ROOTFS}/etc/shadow"
printf "hann:${HANN_PASS}:0:0:99999:7:::\n" >> "${ROOTFS}/etc/shadow"
printf "viii:${VIII_PASS}:0:0:99999:7:::\n" >> "${ROOTFS}/etc/shadow"
printf "kids:${KIDS_PASS}:0:0:99999:7:::\n" >> "${ROOTFS}/etc/shadow"
chmod 640 "${ROOTFS}/etc/shadow"

# /etc/group
printf 'root:x:0:\nhenn:x:1001:\nhann:x:1002:\nviii:x:1003:\nkids:x:1004:\n' > "${ROOTFS}/etc/group"

# Set permissions home dirs
chown -R 1001:1001 "${ROOTFS}/home/henn"
chown -R 1002:1002 "${ROOTFS}/home/hann"
chown -R 1003:1003 "${ROOTFS}/home/viii"
chown -R 1004:1004 "${ROOTFS}/home/kids"

# Access control sesuai soal
chmod 700 "${ROOTFS}/root"
chmod 755 "${ROOTFS}/home/henn"
chmod 750 "${ROOTFS}/home/hann"
chmod 750 "${ROOTFS}/home/viii"
chmod 750 "${ROOTFS}/home/kids"

# Banner via /etc/profile
printf '#!/bin/sh\necho "================================"\necho "  Farewell Party"\necho "  Welcome, $(whoami)."\necho "================================"\n' > "${ROOTFS}/etc/profile"
chmod +x "${ROOTFS}/etc/profile"

# Copy party package manager
cp /home/aadyfan/soal_1/party_pkg.sh "${ROOTFS}/bin/party"
chmod +x "${ROOTFS}/bin/party"

# Copy hello_fuse
cp /home/aadyfan/soal_1/hello_fuse "${ROOTFS}/bin/hello_fuse"

# Copy FUSE libraries
mkdir -p "${ROOTFS}/lib"
find /lib/aarch64-linux-gnu/ -name "libfuse*" -exec cp {} "${ROOTFS}/lib/" \; 2>/dev/null || true
find /usr/lib/aarch64-linux-gnu/ -name "libfuse*" -exec cp {} "${ROOTFS}/lib/" \; 2>/dev/null || true
cp /usr/bin/fusermount3 "${ROOTFS}/bin/fusermount3" 2>/dev/null || true
ln -sf fusermount3 "${ROOTFS}/bin/fusermount" 2>/dev/null || true

for lib in $(ldd /home/aadyfan/soal_1/hello_fuse | grep -o '/lib[^ ]*'); do
    cp "${lib}" "${ROOTFS}/lib/" 2>/dev/null || true
done

# /init
printf '#!/bin/sh\nmount -t proc none /proc\nmount -t sysfs none /sys\nmount -t devtmpfs none /dev 2>/dev/null || mdev -s\nmknod /dev/fuse c 10 229 2>/dev/null || true\nifconfig eth0 up\nip addr add 10.0.2.15/24 dev eth0\nip route add default via 10.0.2.2\necho "nameserver 8.8.8.8" > /etc/resolv.conf\necho "================================"\necho "  Farewell Party"\necho "  Welcome, root."\necho "================================"\nexec /bin/sh\n' > "${ROOTFS}/init"
chmod +x "${ROOTFS}/init"

echo "=== Packing into ${OUTPUT} ==="
cd "${ROOTFS}"
find . | cpio -o -H newc | gzip > "../${OUTPUT}"
cd ..

rm -rf "${ROOTFS}"

echo "=== Done! Multi-user filesystem saved to ${OUTPUT} ==="