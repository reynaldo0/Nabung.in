# REQUIREMENT.md
# Goal-Based Savings Tracker — Scope Reynaldo (Tech Lead)

## 1. Informasi Proyek

| Item | Keterangan |
|---|---|
| Nama aplikasi | Goal-Based Savings Tracker |
| Platform | Android (Flutter) |
| Tipe aplikasi | Pencatatan tabungan berbasis target |
| Penyimpanan | Lokal/offline menggunakan SharedPreferences |
| Backend | Tidak ada |
| Autentikasi | Tidak ada |
| Penanggung jawab dokumen | Reynaldo — Ketua / Tech Lead |

Dokumen ini mendefinisikan kebutuhan dan batas pekerjaan **Reynaldo saja**. Fitur yang menjadi tanggung jawab Argo (UI/UX dan kalkulator rencana) serta Adit (transaksi dan riwayat) hanya dijelaskan pada bagian kontrak integrasi agar struktur aplikasi dan model data dapat disepakati bersama. Implementasi fitur tersebut bukan bagian dari scope Reynaldo.

## 2. Tujuan dan Gambaran Sistem

Aplikasi membantu pengguna mencatat perkembangan tabungan berdasarkan tujuan tertentu, misalnya membeli perangkat, menyiapkan biaya pendidikan, atau kebutuhan pribadi. Pengguna memasukkan target nominal dan mencatat saldo yang benar-benar telah disisihkan.

Aplikasi berfungsi sebagai **tracker dan alat bantu pencatatan**, bukan rekening bank, dompet digital, atau sistem pemindahan uang. Label Cash, E-Wallet, Rekening Bank, dan Deposito hanya menunjukkan lokasi/wadah penyimpanan menurut pengguna. Aplikasi tidak terhubung ke lembaga keuangan dan tidak menghitung bunga maupun biaya administrasi.

## 3. Batasan Scope Reynaldo

### 3.1 Termasuk dalam scope

1. Membuat dan mengonfigurasi proyek Flutter.
2. Menyiapkan repository GitHub, struktur folder, aturan penamaan, dan pola integrasi.
3. Menentukan model data bersama untuk target dan transaksi.
4. Membuat konversi model ke/dari JSON.
5. Membuat layanan penyimpanan lokal berbasis SharedPreferences.
6. Menyediakan operasi CRUD target dan penyimpanan daftar transaksi.
7. Menyediakan helper format Rupiah, tanggal, dan fungsi perhitungan dasar yang dipakai bersama.
8. Mengembangkan Dashboard sebagai halaman utama.
9. Menampilkan total saldo tabungan dari target yang masih aktif.
10. Menampilkan tab Sedang Berjalan dan Selesai.
11. Menampilkan kartu target melalui komponen yang disepakati.
12. Menampilkan highlight target yang saldonya telah mencapai atau melebihi nominal tujuan.
13. Mengatur urutan target agar target yang sudah mencapai 100% tampil di bagian teratas.
14. Menyediakan aksi konfirmasi penyelesaian target dan memindahkan statusnya ke Selesai.
15. Menghubungkan Dashboard dengan model, storage, dan halaman fitur anggota tim.

### 3.2 Tidak termasuk dalam scope

- Implementasi halaman Tambah/Edit Target dan formulirnya.
- Implementasi kalkulator rencana dua arah (nominal cicilan dan tanggal target).
- Perhitungan estimasi tanggal selesai atau nominal cicilan per periode pada UI Tambah/Edit.
- Implementasi halaman Detail Target.
- Implementasi form Setor Nabung dan Tarik Dana.
- Implementasi isi cepat nominal setoran.
- Implementasi tampilan riwayat transaksi.
- Sinkronisasi rekening, e-wallet, atau bank.
- Login, registrasi, backend, API, dan sinkronisasi cloud.
- Perhitungan bunga deposito, biaya admin, atau imbal hasil.

Fitur di luar scope dapat dihubungkan melalui kontrak model dan service yang ditetapkan dalam dokumen ini, tetapi implementasinya menjadi tanggung jawab anggota terkait.

## 4. Pengguna dan Skenario Utama

### 4.1 Pengguna

Pengguna aplikasi adalah individu yang ingin merencanakan dan memantau tabungan secara mandiri.

### 4.2 Skenario yang didukung oleh scope Reynaldo

1. Pengguna membuka aplikasi dan melihat ringkasan tabungan.
2. Dashboard membaca data target dari penyimpanan lokal.
3. Dashboard menghitung total saldo target yang masih aktif.
4. Dashboard memisahkan target aktif dan target selesai.
5. Ketika saldo target mencapai nominal tujuan, target ditandai siap diselesaikan dan ditampilkan pada area highlight.
6. Pengguna memilih konfirmasi bahwa tujuan telah tercapai/dibeli.
7. Sistem mengubah status target menjadi `completed` dan menyimpannya secara lokal.
8. Setelah aplikasi ditutup dan dibuka kembali, data tetap tersedia.

## 5. Kebutuhan Fungsional

### FR-01 — Inisialisasi Aplikasi

- Aplikasi harus dapat dijalankan melalui `main.dart`.
- `main.dart` mengatur `MaterialApp`, tema global, halaman awal, dan konfigurasi dasar.
- Service penyimpanan harus siap sebelum Dashboard membutuhkan data.
- Kegagalan membaca data lokal tidak boleh membuat aplikasi langsung crash; aplikasi menampilkan kondisi kosong atau pesan kesalahan yang sesuai.

**Kriteria penerimaan**
- Aplikasi dapat dibuka pada perangkat/emulator Android.
- Dashboard tampil setelah proses inisialisasi.
- Pengguna baru melihat empty state, bukan error akibat data belum tersedia.

### FR-02 — Model Data Bersama

Sistem menyediakan model target dan transaksi yang konsisten agar modul Dashboard, Tambah/Edit, dan Detail dapat menggunakan struktur data yang sama.

#### GoalModel

| Field | Tipe | Keterangan |
|---|---|---|
| `id` | `String` | ID unik target |
| `name` | `String` | Nama target |
| `targetAmount` | `int` | Nominal tujuan dalam Rupiah |
| `currentAmount` | `int` | Saldo terkini dalam Rupiah |
| `savingLocation` | `String` | Label wadah penyimpanan |
| `savingAmount` | `int?` | Nominal rencana per periode, jika tersedia |
| `frequency` | `String?` | `daily`, `weekly`, atau `monthly` |
| `calculationMode` | `String?` | `installment` atau `deadline` |
| `targetDate` | `String?` | Tanggal target dalam format ISO 8601 |
| `status` | `String` | `active` atau `completed` |
| `createdAt` | `String` | Waktu pembuatan dalam ISO 8601 |
| `updatedAt` | `String` | Waktu perubahan terakhir dalam ISO 8601 |

Catatan:
- Nilai uang menggunakan `int` Rupiah agar tidak terkena masalah presisi floating point.
- `currentAmount` adalah saldo hasil pencatatan transaksi, bukan nilai yang diketik bebas di Dashboard.
- `savingAmount`, `frequency`, `calculationMode`, dan `targetDate` dapat bernilai `null` jika belum diisi.
- `savingLocation` menggunakan nilai konsisten: `cash`, `e_wallet`, `bank_account`, atau `deposit`.
- `status` hanya menerima `active` atau `completed`.
- ID harus unik dan stabil; jangan menggunakan index list sebagai ID.

#### TransactionItem

| Field | Tipe | Keterangan |
|---|---|---|
| `id` | `String` | ID unik transaksi |
| `goalId` | `String` | ID target pemilik transaksi |
| `type` | `String` | `deposit` atau `withdrawal` |
| `amount` | `int` | Nominal transaksi positif |
| `note` | `String?` | Catatan opsional |
| `createdAt` | `String` | Waktu transaksi dalam ISO 8601 |

Catatan:
- `amount` selalu disimpan sebagai angka positif. Jenis transaksi menentukan apakah saldo bertambah atau berkurang.
- Transaksi harus memiliki `goalId` yang cocok dengan target.
- Riwayat transaksi disimpan kronologis berdasarkan `createdAt`.

### FR-03 — Serialisasi JSON

- `GoalModel` dan `TransactionItem` menyediakan `toJson()` dan `fromJson()`.
- Field tanggal disimpan sebagai string ISO 8601.
- Data yang tidak memiliki field opsional harus tetap dapat dibaca dengan aman.
- Parsing data yang tidak valid harus ditangani dengan fallback/error handling, bukan membuat aplikasi crash tanpa penjelasan.
- Perubahan nama field harus mempertimbangkan kompatibilitas data lama.

**Kriteria penerimaan**
- Model dapat diubah menjadi JSON dan dibaca kembali tanpa kehilangan nilai.
- Nilai nominal, status, ID, dan tanggal tetap konsisten setelah proses encode/decode.

### FR-04 — Penyimpanan Lokal

`StorageService` menjadi satu-satunya lapisan akses SharedPreferences. Screen tidak boleh memanggil SharedPreferences secara langsung.

Operasi minimal:
- `getGoals()` — mengambil seluruh target.
- `saveGoals()` — menyimpan daftar target.
- `getTransactions()` — mengambil seluruh transaksi.
- `saveTransactions()` — menyimpan daftar transaksi.
- `addGoal()` — menambahkan target.
- `updateGoal()` — memperbarui target.
- `deleteGoal()` — menghapus target bila dibutuhkan alur aplikasi.
- `getTransactionsByGoalId()` — mengambil transaksi berdasarkan target.
- `completeGoal()` atau mekanisme setara — mengubah status target menjadi selesai.

Ketentuan:
- Gunakan satu key penyimpanan yang konsisten untuk daftar target dan satu key untuk daftar transaksi, misalnya `goals_v1` dan `transactions_v1`.
- Lakukan encode/decode JSON pada service.
- Operasi tulis harus menunggu hasil penyimpanan (`await`).
- Jika operasi gagal, kembalikan hasil/error yang dapat ditangani oleh UI.
- Data harus tetap ada setelah aplikasi ditutup dan dibuka kembali.
- Tidak ada pengiriman data ke server.

**Kriteria penerimaan**
- Data target dan transaksi bertahan setelah force close dan membuka ulang aplikasi.
- Menambah atau mengubah target tidak menghapus target lain.
- Data transaksi tetap terhubung ke `goalId` yang benar.

### FR-05 — Helper Format dan Perhitungan Dasar

`currency_formatter.dart` menyediakan fungsi bersama untuk:
- Format nominal Rupiah, contoh `Rp 1.500.000`.
- Format tanggal untuk tampilan pengguna.
- Menghitung persentase progres target.
- Menghitung sisa nominal target.
- Menangani nilai nol dan batas progres.

Aturan progres:
- `remainingAmount = max(targetAmount - currentAmount, 0)`.
- `progress = currentAmount / targetAmount`, dengan penanganan `targetAmount <= 0`.
- Nilai progress untuk UI dibatasi pada rentang `0.0` sampai `1.0`.
- Status siap diselesaikan ketika `targetAmount > 0` dan `currentAmount >= targetAmount`.
- Saldo aktual tidak boleh dipotong hanya untuk membatasi tampilan progress.

Contoh:
- Target Rp1.000.000 dan saldo Rp250.000 → progres 25%.
- Target Rp1.000.000 dan saldo Rp1.000.000 → progres 100%.
- Target Rp1.000.000 dan saldo Rp1.100.000 → progres tampilan 100%, saldo tetap Rp1.100.000, sisa Rp0.

### FR-06 — Dashboard

Dashboard menampilkan:
- Ringkasan total saldo tabungan dari target berstatus `active`.
- Tab atau pemisah `Sedang Berjalan` dan `Selesai`.
- Daftar kartu target pada masing-masing status.
- Progress target.
- Empty state ketika belum ada target.
- Highlight khusus untuk target aktif yang telah mencapai minimal 100%.

Aturan agregasi:
- Total tabungan aktif = jumlah `currentAmount` seluruh target dengan status `active`.
- Target berstatus `completed` tidak masuk ke total tabungan aktif.
- Target siap diselesaikan tetap dihitung sebagai target aktif sampai pengguna mengonfirmasi penyelesaian.
- Persentase progres tidak boleh menghasilkan `NaN` atau `Infinity`.

Aturan pengurutan:
1. Target aktif yang telah mencapai minimal 100% ditampilkan paling atas.
2. Target aktif lainnya mengikuti urutan yang konsisten, misalnya tanggal pembaruan terbaru.
3. Target selesai ditampilkan pada tab Selesai dengan urutan tanggal penyelesaian/pembaruan terbaru jika informasi tersebut tersedia.

Dashboard harus memuat ulang data setelah kembali dari halaman Tambah/Edit atau Detail agar perubahan anggota tim lain langsung terlihat.

### FR-07 — Highlight Target Tercapai

- Target dengan `currentAmount >= targetAmount` dan `status == active` masuk kelompok siap diselesaikan.
- Kartu highlight memiliki penanda visual yang jelas bahwa target telah mencapai 100%.
- Highlight tidak otomatis mengubah status menjadi `completed`.
- Pengguna harus menekan aksi konfirmasi penyelesaian.
- Setelah dikonfirmasi, status menjadi `completed` dan perubahan disimpan ke lokal.
- Jika penyimpanan gagal, UI tidak boleh menampilkan seolah-olah perubahan berhasil tersimpan.

### FR-08 — Konfirmasi Penyelesaian Target

- Dashboard menyediakan aksi konfirmasi pada target siap diselesaikan.
- Sebelum perubahan status, tampilkan dialog konfirmasi.
- Setelah pengguna menyetujui, ubah `status` menjadi `completed` dan perbarui `updatedAt`.
- Perbarui Dashboard dan tab Selesai setelah operasi berhasil.
- Tampilkan SnackBar untuk hasil berhasil atau gagal.
- Target selesai tidak boleh ikut dihitung pada total tabungan aktif.

### FR-09 — Navigasi dan Integrasi Modul

Reynaldo menyiapkan jalur navigasi dan titik integrasi untuk:
- Dashboard.
- Halaman Tambah/Edit Target milik Argo.
- Halaman Detail Target milik Adit.

Ketentuan integrasi:
- Modul menerima/mengirim model atau ID target yang disepakati, bukan membuat format data alternatif.
- Semua modul menggunakan `StorageService` dan model bersama.
- Setelah halaman anak ditutup, Dashboard mengambil ulang data.
- Hindari duplikasi key SharedPreferences dan duplikasi aturan status.

## 6. Kontrak Integrasi Tim

| Modul | Penanggung jawab | Kontrak integrasi |
|---|---|---|
| Fondasi proyek, model, storage, helper, Dashboard, status selesai | Reynaldo | Menyediakan model, service, helper, dan entry point integrasi |
| Tambah/Edit Target dan kalkulator dua arah | Argo | Menghasilkan/menyimpan `GoalModel` melalui service bersama |
| Detail, Setor, Tarik, dan riwayat transaksi | Adit | Menggunakan `goalId`, `TransactionItem`, serta service bersama |

### Aturan kerja bersama

1. Jangan mengubah nama field model tanpa persetujuan tim.
2. Jangan membuat penyimpanan SharedPreferences sendiri di masing-masing screen.
3. Jangan menyimpan nominal uang sebagai `double` atau string berformat Rupiah.
4. Semua nominal disimpan sebagai integer Rupiah.
5. Setoran dan penarikan harus menghasilkan `TransactionItem`.
6. Perubahan saldo target harus konsisten dengan transaksi yang tercatat.
7. Setelah melakukan perubahan data, modul harus mengembalikan kontrol ke Dashboard agar data dapat dimuat ulang.
8. Setiap anggota mengembangkan file/folder sesuai pembagian kerja dan berkoordinasi sebelum mengubah file bersama.

## 7. Struktur Folder yang Disepakati

```text
lib/
├── main.dart
├── models/
│   └── goal_model.dart
├── services/
│   └── storage_service.dart
├── utils/
│   └── currency_formatter.dart
├── widgets/
│   ├── goal_card.dart
│   └── completed_highlight_card.dart
└── screens/
    ├── dashboard/
    │   └── dashboard_screen.dart
    ├── add_goal/
    │   └── add_edit_goal_screen.dart
    └── goal_detail/
        ├── goal_detail_screen.dart
        └── transaction_sheet.dart
```

File yang menjadi tanggung jawab utama Reynaldo:
- `main.dart`
- `models/goal_model.dart`
- `services/storage_service.dart`
- `utils/currency_formatter.dart`
- `screens/dashboard/dashboard_screen.dart`

`widgets/goal_card.dart` dan `widgets/completed_highlight_card.dart` merupakan komponen kolaboratif yang kontrak dan integrasinya dikoordinasikan Reynaldo; implementasi visual kartu dapat dikerjakan Argo sesuai pembagian kerja tim.

## 8. Kebutuhan Non-Fungsional

### NFR-01 — Offline-first
Aplikasi harus dapat digunakan tanpa koneksi internet. Seluruh data utama disimpan di perangkat.

### NFR-02 — Persistensi
Data tetap tersedia setelah aplikasi ditutup atau perangkat melakukan restart, selama data aplikasi tidak dihapus oleh pengguna/sistem.

### NFR-03 — Konsistensi Data
Saldo, progres, status, dan riwayat transaksi harus menggunakan sumber data yang sama.

### NFR-04 — Ketahanan
Data kosong, nilai opsional `null`, nominal nol, dan data JSON yang tidak sesuai harus ditangani dengan aman.

### NFR-05 — Responsivitas
Dashboard harus dapat digunakan pada ukuran layar ponsel yang berbeda tanpa overflow horizontal maupun vertikal yang tidak disengaja.

### NFR-06 — Maintainability
Logika data ditempatkan pada model/service/helper, bukan ditumpuk di dalam widget screen.

### NFR-07 — Usability
Aksi penting seperti menyelesaikan target harus memiliki konfirmasi dan umpan balik yang mudah dipahami.

## 9. Aturan Bisnis Penting

1. Aplikasi hanya mencatat tabungan; aplikasi tidak memindahkan uang secara nyata.
2. Wadah simpanan adalah label, bukan integrasi rekening.
3. Saldo target dihitung dari transaksi setoran dikurangi penarikan.
4. Penarikan tidak boleh membuat saldo menjadi negatif.
5. Target dianggap siap diselesaikan ketika saldo sama dengan atau melebihi target.
6. Target baru berpindah ke status selesai setelah konfirmasi pengguna.
7. Target selesai tidak masuk perhitungan total tabungan aktif.
8. Target yang sudah selesai tidak boleh berubah kembali ke aktif secara otomatis.
9. Jika fitur pembukaan kembali target diperlukan, alurnya harus disepakati sebagai perubahan kebutuhan.

## 10. Skenario Pengujian Reynaldo

| ID | Skenario | Hasil yang diharapkan |
|---|---|---|
| TC-01 | Membuka aplikasi tanpa data | Dashboard menampilkan empty state |
| TC-02 | Menyimpan target baru melalui service | Target muncul pada daftar setelah data dimuat ulang |
| TC-03 | Menutup dan membuka ulang aplikasi | Target tetap tersedia |
| TC-04 | Target aktif memiliki saldo di bawah tujuan | Muncul pada Sedang Berjalan |
| TC-05 | Saldo target sama dengan tujuan | Target tampil sebagai highlight 100% |
| TC-06 | Saldo target melebihi tujuan | Progress tampil 100%, saldo aktual tidak berubah |
| TC-07 | Mengonfirmasi target tercapai | Status berubah menjadi `completed` |
| TC-08 | Target selesai | Target muncul di tab Selesai dan tidak dihitung pada total aktif |
| TC-09 | Target memiliki nominal tujuan nol | Tidak terjadi pembagian dengan nol |
| TC-10 | Data opsional kosong | Model dan Dashboard tetap dapat memproses data |
| TC-11 | Penyimpanan gagal | UI memberikan umpan balik gagal dan tidak mengklaim data tersimpan |
| TC-12 | Kembali dari halaman fitur anggota lain | Dashboard memuat ulang data terbaru |

## 11. Definition of Done — Reynaldo

Pekerjaan Reynaldo dianggap selesai apabila:

- [ ] Proyek Flutter dapat dijalankan.
- [ ] Struktur folder dan konvensi penamaan disepakati.
- [ ] Model `GoalModel` dan `TransactionItem` tersedia.
- [ ] Serialisasi JSON berhasil diuji.
- [ ] `StorageService` menyediakan operasi data yang dibutuhkan seluruh modul.
- [ ] Data tetap tersimpan setelah aplikasi ditutup dan dibuka kembali.
- [ ] Helper format Rupiah, tanggal, progres, dan sisa target tersedia.
- [ ] Dashboard menampilkan ringkasan, tab status, dan daftar target.
- [ ] Target 100% mendapat highlight dan urutan prioritas.
- [ ] Konfirmasi penyelesaian mengubah status secara persisten.
- [ ] Integrasi modul Argo dan Adit menggunakan kontrak data yang sama.
- [ ] Tidak ada error fatal atau overflow pada alur utama Dashboard.
- [ ] Perubahan telah di-commit dan di-push ke repository GitHub.

## 12. Asumsi dan Keputusan Teknis

- Flutter menggunakan null safety dan Dart yang kompatibel dengan versi Flutter proyek.
- SharedPreferences digunakan untuk mini project dengan volume data sederhana.
- Data target dan transaksi disimpan sebagai JSON.
- Untuk kebutuhan produksi dengan data besar, relasi kompleks, atau migrasi data yang lebih ketat, penyimpanan dapat dievaluasi ulang menggunakan SQLite/Isar. Perubahan tersebut tidak termasuk scope saat ini.
- Penghapusan target perlu mempertimbangkan transaksi terkait; jangan menghapus target tanpa aturan relasi yang disepakati.
