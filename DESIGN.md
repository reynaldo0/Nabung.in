# DESIGN.md
# Nabung.in — Design System & Spesifikasi UI/UX (Scope Reynaldo & Argo)

## 1. Arah Desain

**Nabung.in** dirancang sebagai aplikasi pencatat tabungan personal yang ringan, modern, optimistis, dan mudah dipahami[cite: 14]. Antarmuka memprioritaskan keterbacaan nominal Rupiah, hierarki informasi yang jelas, sudut komponen membulat (*rounded*) yang konsisten, serta stabilitas tata letak pada berbagai ukuran layar ponsel[cite: 14].

Pengguna harus dapat menangkap tiga informasi utama dalam hitungan detik[cite: 14]:
1. Berapa total akumulasi uang yang sedang ditabung[cite: 14].
2. Target mana saja yang sedang berjalan beserta persentase progresnya[cite: 14].
3. Target mana yang sudah mencapai **100%** dan siap dikonfirmasi selesai[cite: 14].

**Cakupan dokumen:** Mengatur fondasi visual global, Dashboard, komponen kartu bersama, serta spesifikasi antarmuka halaman **Tambah/Edit Target** dan **Kalkulator Rencana 2 Arah** (Scope Reynaldo & Argo), sekaligus menyediakan panduan standar antarmuka untuk integrasi halaman **Detail Target & Transaksi** (Scope Adit)[cite: 14].

---

## 2. Prinsip UI/UX

- **Clarity first:** Nominal, persentase progres, dan label status harus terbaca jelas tanpa terpotong[cite: 14].
- **One primary action:** Setiap layar memiliki satu tombol aksi utama (*Call to Action*) yang paling menonjol[cite: 14].
- **Consistent components:** Radius, jarak antar-elemen (*spacing*), token warna, dan gaya input mengikuti `ThemeData` global di `main.dart`[cite: 14].
- **Clear feedback:** Setiap aksi penyimpanan, pembaruan, atau penyelesaian target menampilkan `SnackBar` atau dialog konfirmasi yang informatif[cite: 14].
- **Responsive & anti-overflow:** Menggunakan `SafeArea`, `Expanded`, `Flexible`, `Wrap`, dan `FittedBox` agar nominal besar tidak memicu *RenderFlex overflow*[cite: 14].
- **Stable viewport physics:** Mematikan efek melar elastis (*stretch overscroll* Android 12+) secara global agar komponen kartu tetap kokoh saat ditarik mentok atas/bawah namun tetap dapat di-*scroll* dengan lancar.

---

## 3. Karakter Visual & Larangan Desain

- **Gaya visual:** *Modern personal finance utility* — cerah, bersih, bersahabat, dengan dominasi latar terang (`#F6F8F7`) dan aksen hijau-teal (`#16856B`)[cite: 14].
- **Permukaan (*Surface*):** Kartu putih (`#FFFFFF`) dengan garis tepi tipis (`1 px` `#E4EAE7`)[cite: 14].
- **Ikonografi:** Menggunakan keluarga **Material Icons** (`Icons.*`) secara konsisten di seluruh aplikasi[cite: 14].

**Larangan desain:**
- Tidak menggunakan **emoji** (`🎯`, `🐷`, `🎉`, dll.) sebagai pengganti ikon antarmuka utama[cite: 14].
- Tidak menggunakan gradasi warna mencolok pada setiap kartu atau bayangan hitam yang terlalu pekat[cite: 14].
- Tidak menggunakan font dekoratif untuk nominal angka maupun informasi utama[cite: 14].
- Tidak membuat palet warna atau ukuran radius baru di luar token yang disepakati[cite: 14].

---

## 4. Color Palette (Design Tokens)

Seluruh layar wajib merujuk pada token warna berikut[cite: 14]:

| Token | Hex | Fungsi Utama |
| :--- | :--- | :--- |
| `primary` | `#16856B` | Tombol utama, *progress bar*, indikator tab aktif, dan aksen merek **Nabung.in**[cite: 14] |
| `primaryDark` | `#116B56` | State ditekan (*pressed*) dan teks kontras tinggi di atas `primarySoft`[cite: 14] |
| `primarySoft` | `#E5F5EF` | Latar kartu *highlight* target tercapai 100%, latar *progress bar*, dan wadah ikon[cite: 14] |
| `secondary` | `#3B82A0` | Aksen informasi sekunder dan label wadah **Rekening Bank**[cite: 14] |
| `background` | `#F6F8F7` | Latar belakang utama seluruh halaman (`Scaffold`)[cite: 14] |
| `surface` | `#FFFFFF` | Latar kartu target, form, dan dialog konfirmasi[cite: 14] |
| `textPrimary` | `#17211E` | Judul halaman, nama target, dan nominal utama[cite: 14] |
| `textSecondary` | `#687570` | Sub-judul, label keterangan, dan tanggal[cite: 14] |
| `border` | `#E4EAE7` | Garis tepi kartu, pembatas tab, dan *border* kolom input[cite: 14] |
| `success` | `#16856B` | Status target tercapai dan transaksi setoran masuk[cite: 14] |
| `warning` | `#D99127` | Penanda informasi kalkulator dan label wadah **E-Wallet**[cite: 14] |
| `danger` | `#D9534F` | Khusus aksi penarikan dana darurat dan penghapusan data[cite: 14] |
| `disabled` | `#AAB5B0` | Tombol atau kontrol dalam kondisi nonaktif[cite: 14] |

### Token Warna Label Wadah Simpanan (`savingLocation`)

| Nilai Model (`savingLocation`) | Label UI | Warna Aksen |
| :--- | :--- | :--- |
| `cash` | `Cash` | `#16856B` (*Primary Teal*)[cite: 14] |
| `e_wallet` | `E-Wallet` | `#D99127` (*Amber Warning*)[cite: 14] |
| `bank_account` | `Rekening Bank` | `#3B82A0` (*Secondary Blue*)[cite: 14] |
| `deposit` | `Deposito` | `#7C5CBF` (*Muted Purple*)[cite: 14] |

---

## 5. Typography & Aturan Format Nominal

Menggunakan font sans-serif sistem yang bersih dan mudah dibaca[cite: 14]:

| Style | Ukuran | Weight | Penggunaan |
| :--- | ---: | :--- | :--- |
| Display / Hero Amount | 28–32 px | Bold (`w800`) | Nominal total tabungan pada kartu ringkasan Dashboard[cite: 14] |
| H1 / AppBar Title | 22–24 px | Bold (`w800`) | Judul aplikasi **Nabung.in** dan judul utama layar[cite: 14] |
| H2 / Section Title | 18–20 px | SemiBold (`w700`) | Judul bagian (*Siap dirayakan*, *Target lainnya*, *Rencana Menabung*)[cite: 14] |
| H3 / Card Title | 16–18 px | SemiBold (`w700`) | Nama target pada kartu dan judul dialog[cite: 14] |
| Body | 14–16 px | Regular (`w400`) | Deskripsi, catatan transaksi, dan teks form[cite: 14] |
| Caption | 12–13 px | Regular/Medium | Label wadah simpanan, persentase progres, tanggal, dan sub-teks ringkasan[cite: 14] |
| Button | 14–16 px | SemiBold (`w700`) | Label pada tombol aksi[cite: 14] |

### Aturan Penampilan Nominal Rupiah
- **Nominal $< 1\text{ Triliun}$ ($< 1.000.000.000.000$):** Ditampilkan lengkap dengan pemisah ribuan titik, misalnya `Rp 15.000.000` atau `Rp 246.959.396.312`[cite: 14].
- **Nominal $\ge 1\text{ Triliun}$ ($\ge 1.000.000.000.000$):** Otomatis diringkas menjadi format tiga angka di belakang koma dengan koma desimal Indonesia, misalnya `Rp 1,250 Triliun` atau `Rp 5,609 Triliun`, agar tata letak kartu tetap proporsional di layar ponsel berukuran kecil.
- **Proteksi Overflow:** Nominal utama wajib dibungkus `FittedBox(fit: BoxFit.scaleDown)` agar tidak pernah memicu garis kuning-hitam *overflow*[cite: 14].

---

## 6. Spacing, Radius, dan Perilaku Scroll

### Skala Jarak (*Spacing*)
Menggunakan kelipatan `4 px` (`4`, `8`, `12`, `16`, `20`, `24`, `32`) untuk menjaga ritme tata letak antar-komponen[cite: 14].

### Skala Radius (*Border Radius*)
| Token | Nilai | Penggunaan |
| :--- | ---: | :--- |
| `radiusSmall` | `10 px` | Badge wadah simpanan dan chip pilihan[cite: 14] |
| `radiusMedium` | `14 px` | Kolom input (`TextFormField`), tombol (`FilledButton`/`OutlinedButton`), dan kotak hasil kalkulator[cite: 14] |
| `radiusLarge` | `18 px` | Kartu target reguler (`GoalCard`)[cite: 14] |
| `radiusHighlight` | `20 px` | Kartu *highlight* target tercapai (`CompletedHighlightCard`)[cite: 14] |
| `radiusXLarge` | `24 px` | Kartu ringkasan total tabungan utama (`_SummaryCard`)[cite: 14] |
| `radiusFull` | `999 px` | *Progress bar* dan indikator *pill*[cite: 14] |

### Perilaku Scroll Global
- Aplikasi menerapkan `_FixedClampingScrollBehavior` pada `MaterialApp` menggunakan `ClampingScrollPhysics()` tanpa efek peregangan elastis (*stretch indicator*).
- Halaman tetap dapat di-*scroll* dengan lancar saat daftar target atau riwayat melebihi tinggi layar, namun elemen kartu tidak melar secara visual ketika ditarik di batas atas maupun bawah.

---

## 7. Spesifikasi Layar & Komponen (Scope Reynaldo & Argo)

### 7.1 Dashboard (`DashboardScreen`)
1. **Header:** Menampilkan ikon `Icons.savings_rounded` dalam wadah `#E5F5EF` beserta judul **Nabung.in**[cite: 14].
2. **Kartu Ringkasan Total Tabungan (`_SummaryCard`):**
   - Latar `#16856B`, radius `24 px`, padding `22 px`[cite: 14].
   - Menampilkan label `Total Tabungan Aktif`, nominal total dengan `FittedBox`, dan sub-teks status dinamis di bagian bawah:
     - Saat tab **Sedang Berjalan** aktif: `"X target siap dibeli • Y target sedang berjalan"`.
     - Saat tab **Selesai** aktif: `"Total dari Z target yang telah diselesaikan"`.
3. **Tab Status:** `SegmentedButton` untuk beralih antara **Berjalan** dan **Selesai** beserta jumlah item masing-masing[cite: 14].
4. **Area Highlight 100% (`CompletedHighlightCard`):** Muncul paling atas ketika terdapat target aktif dengan `currentAmount >= targetAmount`, berlatar `#E5F5EF` dengan garis tepi `#B7E2D3`, ikon `Icons.check_circle`, dan tombol `Tandai Selesai`[cite: 14].
5. **Daftar Kartu Target (`GoalCard`):** Kartu putih beradius `18 px` yang menampilkan nama target, *badge* wadah simpanan, informasi rencana cicilan (jika tersedia), nominal terkumpul vs target, persentase, *progress bar* beranimasi (`350 ms`), dan tanggal target[cite: 14]. Kedua kartu mendukung interaksi ketuk (`onTap`) untuk membuka halaman Detail[cite: 14].

### 7.2 Halaman Tambah & Edit Target (`AddEditGoalScreen` — Scope Argo)
1. **Header & Konteks Mode:** Menggunakan `AppBar` standar tema dengan judul **`Target baru`** (saat membuat baru) atau **`Edit target`** (saat memperbarui target yang sudah ada).
2. **Input Utama:**
   - **Nama Target:** `TextFormField` pertama dengan validasi wajib diisi.
   - **Nominal Tujuan (Rp):** `TextFormField` kedua dengan format pemisah ribuan otomatis saat diketik dan validasi nilai $> 0$.
   - **Wadah Simpanan:** Pilihan `ChoiceChip` untuk `Cash`, `E-Wallet`, `Rekening Bank`, dan `Deposito`[cite: 14].
3. **Kalkulator Rencana 2 Arah (*Selalu Tampil & Aktif Default*):**
   - Menampilkan `SegmentedButton` pemilih strategi: **`Atur Nominal Cicilan`** (aktif *default* saat halaman dibuka) vs **`Atur Tanggal Target`**.
   - Pemilih frekuensi menabung: **`Harian`**, **`Mingguan`**, dan **`Bulanan`** (*default*).
   - **Kartu Hasil Perhitungan *Real-Time*:** Kotak berlatar `#E5F5EF` dengan garis tepi `#B7E2D3` dan ikon `Icons.calculate_outlined` yang langsung menampilkan:
     - *Mode Nominal Cicilan:* Jumlah periode menabung dan perkiraan tanggal target tercapai.
     - *Mode Tanggal Target:* Nominal wajib yang harus disisihkan setiap periode hingga tanggal target.
4. **Tombol Aksi Utama:** `FilledButton` lebar penuh di bagian bawah dengan label **`Simpan target`** (untuk mode tambah) atau **`Simpan perubahan`** (untuk mode edit).

---

## 8. Panduan Antarmuka Integrasi (Scope Adit)

Untuk menjaga konsistensi visual ketika modul **Detail Target & Riwayat Transaksi** dikembangkan oleh Adit[cite: 14]:
- **Halaman Detail (`GoalDetailScreen`):** Menggunakan `Scaffold` berlatar `#F6F8F7`, kartu ringkasan progres beradius `18 px`, dan tata letak 2 kolom sejajar untuk menampilkan **Terkumpul** dan **Sisa Kekurangan** agar aman dari *overflow* pada nominal besar[cite: 14].
- **Tombol Setor & Tarik:** Tombol **Setor Nabung** menggunakan `FilledButton` (`#16856B`), sedangkan tombol **Tarik Dana** menggunakan aksen `danger` (`#D9534F`) secara terbatas[cite: 14].
- **Pop-up Transaksi (`TransactionSheet`):** Menggunakan `showModalBottomSheet` dengan sudut atas membulat `24 px` dan menyertakan tombol *chip* **Isi Cepat (Sesuai Rencana)** apabila `goal.savingAmount != null`[cite: 14].
- **Riwayat Aktivitas:** Menggunakan ikon `Icons.arrow_upward_rounded` (`#16856B`) untuk setoran dan `Icons.arrow_downward_rounded` (`#D9534F`) untuk penarikan, dengan format tanggal dan Rupiah dari `currency_formatter.dart`[cite: 14].