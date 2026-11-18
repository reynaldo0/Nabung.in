# Nabung.in — Goal-Based Savings Tracker

**Nabung.in** adalah aplikasi mobile berbasis Flutter untuk merencanakan, mencatat, dan memantau progres tabungan berdasarkan target spesifik (*wishlist* atau tujuan finansial) secara mandiri dan *offline-first*.

Berbeda dengan aplikasi pencatat arus kas harian (*cashflow*) maupun layanan perbankan digital, **Nabung.in** berfokus pada visualisasi kedisiplinan menabung. Aplikasi tidak terhubung ke rekening bank/e-wallet dan tidak menghitung bunga deposito maupun potongan biaya administrasi secara otomatis; pilihan wadah simpanan (**Cash**, **E-Wallet**, **Rekening Bank**, dan **Deposito**) murni berfungsi sebagai label penanda lokasi penyimpanan dana.

---

## Empat Fitur Utama

1. **Dashboard Ringkasan & Highlight Target Tercapai (`DashboardScreen`)**
   - Menampilkan kartu total akumulasi dana dari seluruh target berstatus aktif beserta ringkasan status (`X target siap dibeli • Y target sedang berjalan`).
   - Pemisahan daftar tabungan ke dalam tab **Berjalan** dan **Selesai**.
   - Target aktif yang saldonya menyentuh **100%** otomatis naik ke posisi teratas dalam kartu *highlight* khusus hingga pengguna menekan tombol konfirmasi **Tandai Selesai**.
2. **Tambah & Edit Target dengan Kalkulator Rencana 2 Arah (`AddEditGoalScreen`)**
   - Formulir pembuatan maupun pengubahan target tabungan lengkap dengan pemilihan label wadah simpanan (`Cash`, `E-Wallet`, `Rekening Bank`, `Deposito`).
   - **Mode Nominal Cicilan (*Default*):** Pengguna memasukkan nominal rutin yang sanggup ditabung beserta frekuensinya (`Harian`, `Mingguan`, `Bulanan`) untuk menghitung estimasi durasi dan perkiraan tanggal target tercapai.
   - **Mode Tanggal Target (*Deadline*):** Pengguna menentukan tanggal target tercapai beserta frekuensi menabung untuk menghitung nominal wajib per periode.
3. **Halaman Detail Target & Pencatatan Transaksi (`GoalDetailScreen` & `TransactionSheet`)**
   - Menampilkan rincian progres tabungan, sisa nominal kekurangan, dan riwayat aktivitas setoran maupun penarikan secara kronologis[cite: 14].
   - Dilengkapi tombol aksi **Setor Nabung** (termasuk fitur *Isi Cepat* sesuai rencana) dan **Tarik Dana** untuk keperluan darurat[cite: 14].
4. **Penyimpanan Data Lokal Permanen (`StorageService`)**
   - Seluruh data target dan transaksi disimpan secara lokal menggunakan `SharedPreferences` dalam format JSON sehingga tetap aman tanpa koneksi internet maupun login akun[cite: 14].

---

## Struktur Direktori Kode

~~~text
lib/
├── main.dart                                  # Entry point, ThemeData global, & ClampingScrollBehavior
├── models/
│   └── goal_model.dart                        # Struktur GoalModel & TransactionItem (JSON)
├── services/
│   └── storage_service.dart                   # Abstraksi CRUD SharedPreferences lokal
├── utils/
│   └── currency_formatter.dart                # Format Rupiah (hingga Triliun), tanggal, & kalkulator 2 arah
├── widgets/
│   ├── goal_card.dart                         # Kartu target reguler kolaboratif
│   └── completed_highlight_card.dart          # Kartu highlight target tercapai (100%)
└── screens/
    ├── onboarding/
    │   └── onboarding_screen.dart             # Layar pengenalan 4 langkah saat pertama dibuka
    ├── dashboard/
    │   └── dashboard_screen.dart              # Halaman utama ringkasan & daftar target
    ├── add_goal/
    │   └── add_edit_goal_screen.dart          # Halaman Tambah/Edit target & Kalkulator 2 Arah
    └── goal_detail/
        ├── goal_detail_screen.dart            # Halaman rincian target & riwayat transaksi (Adit)
        └── transaction_sheet.dart             # Modal form Setor Nabung & Tarik Dana (Adit)
~~~

---

## Pembagian Tugas Tim (Kolaborasi GitHub)

| Anggota | Peran | Tanggung Jawab Utama |
| :--- | :--- | :--- |
| **Reynaldo** | Tech Lead & Core | Kerangka proyek & repo GitHub, `GoalModel`, `TransactionItem`, `StorageService`, `OnboardingScreen`, fondasi `DashboardScreen`, dan alur konfirmasi target selesai[cite: 14]. |
| **Argo** | UI/UX & Kalkulator | Penyeragaman label & standar UI/UX, perilaku *scroll* kokoh (`ClampingScrollPhysics`), perluasan `currency_formatter.dart` (format `Triliun` & kalkulator 2 arah), `AddEditGoalScreen`, serta penyempurnaan `GoalCard` dan `CompletedHighlightCard`. |
| **Adit** | Transaksi & Riwayat | Halaman `GoalDetailScreen`, modal `TransactionSheet` (Setor Nabung dengan *Isi Cepat* & Tarik Dana darurat), serta tampilan log riwayat transaksi kronologis[cite: 14]. |

---

## Panduan Menjalankan & Menguji Proyek

1. **Instalasi dependensi paket:**
   ~~~bash
   flutter pub get
   ~~~
2. **Analisis statis kode:**
   ~~~bash
   flutter analyze
   ~~~
3. **Jalankan pengujian otomatis (*widget & unit test*):**
   ~~~bash
   flutter test
   ~~~
4. **Jalankan aplikasi pada emulator atau perangkat Android:**
   ~~~bash
   flutter run
   ~~~