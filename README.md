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
Output: 
```
ping -c 3 8.8.8.8
wget example.com
```
<img width="1130" height="381" alt="Screenshot 2026-06-04 at 18 06 48" src="https://github.com/user-attachments/assets/106abb59-a2d1-487d-8305-8a054cafadb5" />
```
party install wget
party list
party remove wget
```
<img width="651" height="244" alt="Screenshot 2026-06-04 at 18 07 41" src="https://github.com/user-attachments/assets/d3080a7e-d4cd-4ff3-bddb-799612b1eee8" />

```
mkdir -p /tmp/mnt
hello_fuse /tmp/mnt &
sleep 1
cat /tmp/mnt/hello
```
<img width="474" height="204" alt="Screenshot 2026-06-04 at 18 10 49" src="https://github.com/user-attachments/assets/9696c7a5-197f-486d-bb23-7acdaa464308" />


## Soal 2 - Season

### Penjelasan

Membuat sistem operasi sederhana berbasis 16-bit menggunakan bootloader dan kernel yang ditulis dalam Assembly dan C. OS ini berjalan di emulator Bochs dan memiliki shell interaktif dengan berbagai command.

---

### kernel.asm

Berisi implementasi fungsi-fungsi low-level yang dipanggil oleh kernel.c.

**`_putInMemory`** — Menulis karakter langsung ke video memory (0xB800) untuk ditampilkan di layar.

**`_getChar`** — Membaca input karakter dari keyboard menggunakan BIOS interrupt 0x16.

```nasm
_getChar:
    push bp
    mov bp, sp
    mov ah, 0x00
    int 0x16
    mov ah, 0
    pop bp
    ret
```

---

### kernel.c

Berisi implementasi shell interaktif dan semua command yang tersedia.

**Fungsi-fungsi utama:**

- `printChar()` — Menulis satu karakter ke video memory dengan warna yang sesuai
- `printString()` — Menulis string ke layar karakter per karakter
- `clearScreen()` — Membersihkan seluruh layar dan reset cursor
- `readString()` — Membaca input dari keyboard sampai Enter ditekan, support backspace
- `strcmp()` — Membandingkan dua string
- `startsWith()` — Mengecek apakah string diawali dengan prefix tertentu
- `atoi()` — Mengkonversi string ke integer
- `intToString()` — Mengkonversi integer ke string (tanpa modulo karena restriction 16-bit)
- `factorial()` — Menghitung faktorial dengan deteksi overflow 16-bit

---

### Command yang tersedia

| Command | Fungsi | Contoh |
|---------|--------|--------|
| `check` | Memastikan sistem berjalan baik | `check` → `ok` |
| `add <a> <b>` | Penjumlahan dua bilangan | `add 5 3` → `8` |
| `sub <a> <b>` | Pengurangan dua bilangan | `sub 10 2` → `8` |
| `fac <n>` | Faktorial bilangan (limit 16-bit) | `fac 6` → `720` |
| `season <name>` | Ganti warna teks | `season winter` |
| `triangle <n>` | Mencetak segitiga dari karakter x | `triangle 5` |
| `clear` | Menghapus seluruh histori layar | `clear` |
| `help` | Menampilkan daftar command | `help` |

---

### Season (Warna)

| Season | Warna |
|--------|-------|
| winter | Biru (0x09) |
| spring | Hijau (0x0A) |
| summer | Kuning (0x0E) |
| fall | Orange (0x06) |
| radiant | Magenta (0x0D) |

---

### Catatan

- Sistem berjalan pada arsitektur 16-bit, sehingga ada batasan integer maksimal 32767
- Jika faktorial melebihi batas 16-bit, sistem mencetak: `know your limit little bro.`
- Tidak menggunakan stdlib, division (/) untuk modulo, dan menggunakan teknik alternatif untuk operasi aritmatika
- Build menggunakan Docker dengan tools `bcc`, `nasm`, dan `ld86`

---

### Cara Build dan Run

```bash
# Build
bash build.sh

# Run
bochs -f bochsrc.txt
```
Output:

```
bochs -f bochsrc.txt
```
check
add 5 3
sub 10 2
fac 6
season winter
triangle 5
```
<img width="730" height="546" alt="Screenshot 2026-06-04 at 18 26 19" src="https://github.com/user-attachments/assets/094cf1a5-e986-4e87-ad25-c95b91efeba3" />

help
