# DESIGN.md
# Goal-Based Savings Tracker — Design System & UI Scope Reynaldo

## 1. Arah Desain

Goal-Based Savings Tracker dirancang sebagai aplikasi pencatat tabungan yang terasa ringan, modern, optimistis, dan mudah dipahami. Antarmuka harus membuat pengguna dapat melihat tiga hal dengan cepat:

1. Berapa total uang yang sedang ditabung.
2. Target mana yang sedang dikejar.
3. Target mana yang sudah mencapai 100% dan siap diselesaikan.

Desain mengutamakan hierarki informasi, keterbacaan nominal Rupiah, komponen rounded yang konsisten, dan interaksi yang jelas. Hindari tampilan yang terlalu ramai, dekorasi berlebihan, atau penggunaan warna yang tidak memiliki fungsi.

**Cakupan dokumen:** panduan fondasi visual, tema global, Dashboard, komponen bersama, dan integrasi tampilan yang menjadi koordinasi Reynaldo. Desain detail halaman Tambah/Edit, kalkulator, Detail Target, form transaksi, dan riwayat dikerjakan oleh Argo dan Adit dengan mengikuti design token dan aturan bersama di sini.

## 2. Prinsip UI/UX

- **Clarity first:** nominal, progres, dan status harus mudah dibaca.
- **One primary action:** setiap area memiliki satu aksi utama yang paling menonjol.
- **Consistent components:** radius, jarak, warna, dan gaya tombol konsisten.
- **Feedback:** aksi simpan atau penyelesaian memberikan SnackBar atau dialog yang sesuai.
- **Accessible contrast:** teks tetap terbaca di atas latar belakang.
- **Responsive:** gunakan layout fleksibel dan hindari ukuran lebar yang dipatok untuk satu perangkat.
- **Calm and positive:** nuansa segar dan suportif, bukan kompetitif atau menekan pengguna.

## 3. Visual Direction

<details>
<summary>Karakter visual</summary>

- Modern personal finance utility.
- Clean, bright, friendly.
- Dominasi latar terang dengan aksen hijau/teal.
- Kartu putih dengan border tipis atau elevation sangat halus.
- Rounded corner konsisten.
- Progress bar sederhana dan animasi singkat.
- Ikon menggunakan satu keluarga ikon yang konsisten.
</details>

Jangan menggunakan:
- Gradient mencolok pada setiap kartu.
- Shadow gelap dan tebal.
- Terlalu banyak warna aksen dalam satu layar.
- Font dekoratif untuk nominal atau informasi utama.
- Animasi panjang yang memperlambat interaksi.
- Emoji sebagai pengganti ikon antarmuka utama.

## 4. Color Palette

Gunakan palet berikut sebagai token awal. Implementasi akhir dapat disesuaikan bersama tim, tetapi nama token dan maknanya harus tetap konsisten.

| Token | Hex | Fungsi |
|---|---|---|
| `primary` | `#16856B` | Tombol utama, progress, elemen aktif |
| `primaryDark` | `#116B56` | State pressed dan aksen kuat |
| `primarySoft` | `#E5F5EF` | Latar highlight positif |
| `secondary` | `#3B82A0` | Aksen sekunder dan informasi |
| `background` | `#F6F8F7` | Latar halaman |
| `surface` | `#FFFFFF` | Kartu dan modal |
| `textPrimary` | `#17211E` | Judul dan teks utama |
| `textSecondary` | `#687570` | Keterangan dan label |
| `border` | `#E4EAE7` | Garis pembatas |
| `success` | `#16856B` | Target tercapai dan aksi sukses |
| `warning` | `#D99127` | Peringatan yang membutuhkan perhatian |
| `danger` | `#D9534F` | Penarikan atau aksi berisiko |
| `disabled` | `#AAB5B0` | Kontrol nonaktif |

Aturan pemakaian:
- `primary` digunakan untuk CTA dan indikator progres, bukan untuk semua teks.
- `success` digunakan untuk status tercapai, bukan sebagai dekorasi.
- `danger` hanya untuk aksi penarikan atau tindakan destruktif.
- Pastikan rasio kontras teks memadai, terutama teks kecil di atas `primarySoft`.

## 5. Typography

Gunakan font sans-serif yang bersih dan tersedia secara konsisten. Rekomendasi: **Inter** jika font asset ditambahkan ke proyek; jika belum, gunakan font default Android/Flutter.

| Style | Ukuran | Weight | Penggunaan |
|---|---:|---|---|
| Display | 28–32 px | Bold | Total saldo utama |
| H1 | 24 px | Bold | Judul halaman |
| H2 | 20 px | SemiBold | Judul section |
| H3 | 16–18 px | SemiBold | Nama kartu target |
| Body | 14–16 px | Regular | Informasi utama |
| Caption | 12 px | Regular | Label, tanggal, helper |
| Button | 14–16 px | SemiBold | Label tombol |
| Amount | 20–28 px | Bold | Nominal penting |

Ketentuan:
- Gunakan `tabular figures` jika font mendukung agar digit nominal sejajar.
- Nominal utama tidak boleh terpotong.
- Hindari penggunaan terlalu banyak ukuran font dalam satu layar.
- Gunakan line-height yang nyaman untuk teks penjelasan.

## 6. Spacing, Radius, dan Elevation

### Spacing scale

Gunakan kelipatan 4 atau 8 agar ritme layout konsisten.

| Token | Nilai |
|---|---:|
| `space4` | 4 px |
| `space8` | 8 px |
| `space12` | 12 px |
| `space16` | 16 px |
| `space20` | 20 px |
| `space24` | 24 px |
| `space32` | 32 px |

### Radius

| Token | Nilai | Penggunaan |
|---|---:|---|
| `radiusSmall` | 10 px | Chip dan label |
| `radiusMedium` | 14 px | Input dan tombol |
| `radiusLarge` | 18 px | Kartu |
| `radiusXLarge` | 24 px | Kartu ringkasan utama |
| `radiusFull` | 999 px | Pill dan progress |

### Elevation dan border

- Utamakan border `#E4EAE7` satu pixel untuk memisahkan surface.
- Gunakan shadow tipis hanya pada kartu yang perlu terlihat terangkat.
- Hindari shadow besar dan blur berlebihan.
- Jangan mencampur banyak gaya border dalam satu layar.

## 7. Global Theme dan Komponen Dasar

Reynaldo menyiapkan `ThemeData` global di `main.dart`.

Konfigurasi yang perlu diseragamkan:
- `ColorScheme` berbasis warna primer.
- `Scaffold` background menggunakan `background`.
- AppBar dengan surface terang dan judul yang jelas.
- Filled button untuk aksi utama.
- Outlined/text button untuk aksi sekunder.
- Input decoration dengan border dan radius konsisten.
- SnackBar dengan pesan singkat dan mudah dipahami.
- Dialog konfirmasi dengan aksi batal dan lanjut yang jelas.

Komponen harus menggunakan tema global jika memungkinkan. Hindari hardcode warna berbeda-beda di setiap screen.

## 8. Dashboard — Scope Reynaldo

### 8.1 Struktur informasi

Urutan konten Dashboard:

1. Header aplikasi dan sapaan/judul ringkas.
2. Kartu ringkasan total tabungan aktif.
3. Area highlight target tercapai (jika ada).
4. Tab `Sedang Berjalan` dan `Selesai`.
5. Daftar kartu target sesuai tab.
6. Empty state jika daftar pada tab terpilih kosong.

### 8.2 Kartu ringkasan total tabungan

Isi:
- Label `Total Tabungan Aktif`.
- Nominal total dalam format Rupiah.
- Keterangan singkat seperti `Dari seluruh target yang sedang berjalan`.

Gaya:
- Surface putih atau `primary` dengan kontras teks yang kuat.
- Nominal menjadi elemen paling dominan.
- Radius 24 px.
- Padding 20–24 px.
- Tidak menambahkan grafik yang tidak diperlukan.

Definisi nilai:
- Hanya menjumlahkan `currentAmount` dari target `active`.
- Target yang telah mencapai 100% tetapi belum dikonfirmasi selesai tetap masuk total aktif.

### 8.3 Tab status

- Dua pilihan: `Sedang Berjalan` dan `Selesai`.
- Tab aktif memakai warna primer dan indikator yang jelas.
- Tab nonaktif memakai teks sekunder.
- Jumlah item boleh ditampilkan sebagai count kecil jika tidak membuat tampilan ramai.
- Perubahan tab tidak boleh menghapus state data.

### 8.4 Kartu target reguler

Informasi minimum:
- Nama target.
- Label wadah penyimpanan.
- Saldo terkumpul.
- Nominal tujuan.
- Persentase/progress bar.

Gaya:
- Surface putih.
- Border tipis.
- Radius 18 px.
- Padding 16 px.
- Progress bar rounded.
- Teks nominal dan tujuan ditata agar mudah dibandingkan.

### 8.5 Kartu highlight 100%

Kartu ini hanya muncul untuk target berstatus `active` dengan `currentAmount >= targetAmount`.

Informasi:
- Nama target.
- Penanda `Target tercapai`.
- Nominal terkumpul dan nominal tujuan.
- Progress visual 100%.
- Tombol konfirmasi, misalnya `Tandai Selesai`.

Gaya:
- Latar `primarySoft`.
- Aksen `primary` atau `success`.
- Border dapat menggunakan warna primer dengan intensitas rendah.
- Gunakan ikon centang atau trophy sederhana.
- Hindari confetti atau animasi berlebihan.

Perilaku:
- Kartu berada di atas daftar target aktif reguler.
- Highlight tetap terlihat sampai pengguna mengonfirmasi penyelesaian.
- Setelah konfirmasi berhasil, kartu hilang dari daftar aktif dan target masuk tab Selesai.
- Dialog konfirmasi ditampilkan sebelum perubahan status.

### 8.6 Empty state

Jika belum ada target:
- Gunakan ilustrasi/ikon sederhana atau bentuk dekoratif minimal.
- Judul: `Belum ada target tabungan`.
- Deskripsi: `Buat target pertamamu untuk mulai mencatat progres menabung.`
- Sediakan CTA menuju halaman Tambah Target yang disediakan Argo.

Jika tab Selesai kosong:
- Tampilkan pesan `Belum ada target yang selesai.`
- Jangan menampilkan area kosong yang terlalu tinggi.

## 9. Motion dan Feedback

Animasi hanya digunakan untuk memperjelas perubahan.

| Interaksi | Rekomendasi |
|---|---|
| Progress berubah | Animated progress 250–400 ms |
| Perpindahan tab | Transisi ringan 150–250 ms |
| Kartu muncul/hilang | Fade/size transition singkat |
| Dialog konfirmasi | Animasi default Material |
| Penyimpanan berhasil | SnackBar singkat |
| Penyimpanan gagal | SnackBar dengan pesan yang jelas |

Aturan:
- Hormati performa perangkat Android kelas menengah.
- Jangan menjalankan animasi berulang tanpa kebutuhan.
- Jangan mengandalkan warna/animasi saja untuk menyampaikan status.
- Semua aksi penting tetap harus memberikan feedback tekstual.

Contoh pesan:
- `Target berhasil ditandai selesai.`
- `Data gagal disimpan. Silakan coba lagi.`
- `Target ini sudah mencapai nominal tujuan.`

## 10. Iconography

Gunakan Material Symbols atau Material Icons secara konsisten.

Rekomendasi penggunaan:
- Wallet / account balance untuk total tabungan.
- Flag / target untuk target.
- Check circle untuk target tercapai.
- Calendar untuk tanggal.
- Cash / savings untuk wadah simpanan.
- Arrow up/down untuk transaksi jika digunakan modul anggota lain.

Jangan mencampur ikon outline dan filled secara acak dalam satu kelompok komponen.

## 11. Responsive Layout

- Gunakan `SafeArea` pada halaman utama.
- Gunakan `SingleChildScrollView` atau `ListView` untuk konten yang dapat memanjang.
- Gunakan `Expanded`, `Flexible`, dan `Wrap` ketika diperlukan.
- Hindari lebar/tinggi tetap untuk komponen yang berisi teks dinamis.
- Nominal panjang harus dapat mengecil atau membungkus secara wajar tanpa overflow.
- Pastikan tab, tombol, dan kartu tetap nyaman disentuh.
- Uji setidaknya pada lebar layar kecil dan layar Android umum.

## 12. Accessibility dan Usability

- Ukuran area sentuh tombol idealnya minimal 48 × 48 logical pixels.
- Jangan menggunakan warna sebagai satu-satunya pembeda status.
- Berikan label teks pada ikon aksi yang tidak umum.
- Pastikan teks sekunder masih terbaca.
- Dialog konfirmasi harus menjelaskan dampak aksi.
- Gunakan format Rupiah konsisten pada semua halaman.
- Tanggal ditampilkan dalam bahasa Indonesia yang mudah dipahami.

## 13. Kontrak Visual Antaranggota

### Reynaldo
- Menetapkan `ThemeData`, warna, typography, spacing, radius, dan gaya feedback.
- Menyediakan helper format Rupiah/tanggal/progres.
- Mengembangkan Dashboard dan state status target.
- Mengkoordinasikan komponen kartu dan navigasi agar konsisten.

### Argo
- Mengikuti global theme untuk halaman Tambah/Edit.
- Menggunakan style input, tombol, dan dialog yang sama.
- Kalkulator harus menampilkan hasil dengan hierarki nominal dan tanggal yang jelas.
- Tidak membuat palet warna atau radius baru tanpa kesepakatan.

### Adit
- Mengikuti global theme untuk Detail Target dan transaksi.
- Setor dan Tarik harus memiliki pembeda visual yang jelas.
- Aksi Tarik menggunakan warna danger secara terbatas.
- Riwayat transaksi menggunakan format tanggal dan Rupiah dari helper bersama.

## 14. Checklist Implementasi Design

- [ ] ThemeData global dibuat di `main.dart`.
- [ ] ColorScheme dan token warna konsisten.
- [ ] Typography dan hierarki nominal ditetapkan.
- [ ] Spacing dan radius digunakan konsisten.
- [ ] Dashboard mengikuti urutan informasi yang ditetapkan.
- [ ] Kartu ringkasan total tabungan mudah dibaca.
- [ ] Tab Sedang Berjalan dan Selesai memiliki state aktif yang jelas.
- [ ] Kartu target menampilkan progres dan nominal.
- [ ] Kartu highlight 100% memiliki penanda dan CTA.
- [ ] Dialog konfirmasi penyelesaian tersedia.
- [ ] SnackBar sukses/gagal konsisten.
- [ ] Empty state tersedia untuk kedua tab.
- [ ] Layout diuji pada layar kecil tanpa overflow.
- [ ] Halaman Argo dan Adit menggunakan tema dan helper bersama.
