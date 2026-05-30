# SISOP-5-2026-IT-006

# SISOP-5-2026-IT-006

**NAMA: ABHISTA ATHALLAH DYFAN**
**NRP: 5027251006**

---

## Soal 1 - Farewell Party

### Penjelasan

Membuat sebuah OS sederhana berbasis Linux Kernel 6.1.1 yang dapat di-boot menggunakan QEMU, dengan single-user dan multi-user filesystem, bootable ISO, package manager sendiri bernama `party`, serta support FUSE.

---

### kernel.sh

Script untuk mendownload dan mengcompile Linux Kernel versi 6.1.1. Output kernel disimpan di `osboot/bzImage`.

```bash
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.1.tar.xz
tar -xf linux-6.1.1.tar.xz
cd linux-6.1.1
make defconfig
make -j$(nproc)
```

Kernel dikompilasi untuk arsitektur ARM64 (karena menggunakan UTM di Apple Silicon), sehingga output berupa `arch/arm64/boot/Image` yang kemudian disalin ke `osboot/bzImage`.

---

### single.sh

Script untuk membuat single-user filesystem menggunakan BusyBox. Output disimpan di `osboot/single.gz`.

Struktur direktori yang dibuat:
- `bin/`, `dev/`, `proc/`, `sys/`, `etc/`, `tmp/`, `root/`

Spesifikasi:
- User: `root` (hanya root)
- Access: root bisa akses apapun
- Banner: saat login muncul ascii art **Farewell Party** dan **Welcome, root.**

BusyBox digunakan untuk menyediakan shell environment. Filesystem dikemas menggunakan `cpio` dan `gzip`:

```bash
find . | cpio -o -H newc | gzip > ../osboot/single.gz
```

Network dikonfigurasi otomatis saat boot:
```bash
ifconfig eth0 up
ip addr add 10.0.2.15/24 dev eth0
ip route add default via 10.0.2.2
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

---

### multi.sh

Script untuk membuat multi-user filesystem menggunakan BusyBox. Output disimpan di `osboot/multi.gz`.

Spesifikasi user dan password:

| User | Password |
|------|----------|
| root | root123  |
| henn | henn123  |
| hann | hann123  |
| viii | viii123  |
| kids | kids123  |

Spesifikasi akses:

| User | Access |
|------|--------|
| root | Akses penuh ke semua direktori |
| henn | Full akses /home/*, gabisa akses /root |
| hann | Full akses /home/{hann,viii,kids}, gabisa akses /root & /home/henn |
| viii | Full akses /home/{viii,kids}, gabisa akses /root & /home/{henn,hann} |
| kids | Full akses /home/kids, gabisa akses /root & /home/{henn,hann,viii} |
| ALL  | Selain specs diatas hanya bisa read dan execute, full akses tmp/ |

Banner saat login menampilkan **Farewell Party** dan **Welcome, \<USER\>.**

---

### iso.sh

Script untuk membuat bootable ISO dari single dan multi filesystem. Output disimpan di `osboot/farewell.iso`.

Menggunakan `grub-mkrescue` dan `xorriso` untuk membuat ISO yang bisa melakukan load kedua filesystem:

```bash
grub-mkrescue -o osboot/farewell.iso iso_build/
```

GRUB dikonfigurasi dengan dua menu entry:
- Farewell Party - Single User
- Farewell Party - Multi User

---

### qemu.sh

Script untuk menjalankan OS menggunakan QEMU dengan tiga mode:

| Perintah | Fungsi |
|----------|--------|
| `./qemu.sh --single` | Boot single-user filesystem langsung |
| `./qemu.sh --multi` | Boot multi-user filesystem langsung |
| `./qemu.sh --all` | Boot dari ISO, bisa pilih single atau multi |


### backup.sh

Script untuk mengarsipkan semua file hasil build ke dalam satu file zip.

File yang diarsipkan: `bzImage`, `single.gz`, `multi.gz`, `farewell.iso`

Format nama backup:
farewell_backup_[DDMMYYYY-HHMMSS].zip

### Fitur Tambahan

#### Internet Access
OS dapat mengakses internet dengan melakukan konfigurasi network otomatis saat boot. Test yang berhasil:
ping 8.8.8.8        # berhasil
wget example.com    # berhasil

#### Package Manager `party`
Package manager sederhana bernama `party` yang sudah include di dalam filesystem.

```bash
party install <package>
party remove <package>
party list
```

#### FUSE
OS support FUSE (Filesystem in Userspace). Program `hello_fuse` sudah include di dalam filesystem dan dapat dijalankan:

```bash
mkdir -p /tmp/mnt
hello_fuse /tmp/mnt &
cat /tmp/mnt/hello
# Output: Hello from FUSE!
```
