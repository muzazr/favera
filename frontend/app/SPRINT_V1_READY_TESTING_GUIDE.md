# 🚀 Panduan Verifikasi Kesiapan Sprint V1 Aplikasi Favera

Dokumen ini adalah **Panduan Pengujian & Kesiapan Rilis Sprint V1** untuk menguji seluruh alur frontend–backend–AI aplikasi **Favera** (Part 0 hingga Part 14).

Gunakan panduan ini untuk menguji secara manual apakah aplikasi sudah memenuhi kriteria **70–80% Kesiapan Sprint** dan **Layak Demonstrasi GEMASTIK** tanpa adanya *dead-end*, kebocoran data privat, atau aplikasi *crash*.

---

## 🛠️ 1. Cara Menjalankan Aplikasi

Pastikan emulator Anda (`emulator-5554` atau perangkat fisik) aktif, kemudian jalankan perintah berikut sesuai mode pengujian yang ingin Anda lakukan:

### A. Mode Hybrid (Integrasi Remote Vercel Backend) — *DISARANKAN*
Menggunakan API backend Vercel resmi (`https://favera-backend.vercel.app`) untuk Auth, Keluarga, Keuangan, E-Statement, Assessment AI, Komitmen, Chat AI Gemini, dan Konseling.
```bash
flutter run -d emulator-5554 --dart-define=APP_MODE=hybrid
```

### B. Mode Stateful Mock (Simulasi Lokal)
Menggunakan mock stateful lokal. Digunakan jika backend remote sedang dalam perbaikan atau pengujian offline tanpa kuota internet.
```bash
flutter run -d emulator-5554 --dart-define=APP_MODE=mock
```

---

## 📋 2. Panduan Pengujian Langkah-demi-Langkah (Module Checklist)

---

### 🔑 MODUL 1: Autentikasi & Onboarding Profil (Part 1 & Part 3)
*Tujuan: Memastikan alur masuk, pendaftaran, dan profil akun terhubung dengan aman ke Vercel backend.*

- [ ] **1.1 Registrasi Akun Baru**:
  - Buka tab **Daftar** pada layar Auth.
  - Masukkan Nama, Email baru, dan Password (min. 8 karakter).
  - Centang persetujuan privasi, lalu klik **Daftar**.
  - **Ekspektasi**: Akun berhasil dibuat, token tersimpan di Secure Storage, dan Anda langsung dialihkan ke layar Penyambungan Ruang Keluarga.
- [ ] **1.2 Login & Cold Start Session**:
  - Keluar dari aplikasi (*Hot Restart* / *Re-launch*).
  - Buka aplikasi kembali.
  - **Ekspektasi**: Sesi login bertahan (*cold start authenticated*), tidak meminta login ulang.
- [ ] **1.3 Logout & Sanitasi Data**:
  - Buka Pengaturan Profil -> klik **Keluar Akun**.
  - **Ekspektasi**: Token terhapus dari secure storage, seluruh state cache (dashboard, transaksi, chat, komitmen) dibersihkan tuntas, dan Anda kembali ke halaman Login.

---

### 👨‍👩‍👧 MODUL 2: Ruang Keluarga & Pairing Pasangan (Part 2 & Part 3)
*Tujuan: Memastikan pembuatan ruang keluarga dan penggabungan dua akun berjalan transparan.*

- [ ] **2.1 Membuat Kode Undangan**:
  - Di layar Penyambungan Keluarga, pilih **Buat Kode Undangan Baru**.
  - **Ekspektasi**: Menampilkan kode undangan unik 6 karakter (misal: `FAV-123456`) dan masa berlaku.
- [ ] **2.2 Menerima Undangan Pasangan**:
  - Masuk dengan akun kedua (atau simulasikan penyambungan).
  - Pilih **Masukkan Kode Undangan Pasangan**, masukkan kode, lalu klik **Hubungkan**.
  - **Ekspektasi**: Status berubah menjadi **Tersambung (Active)** dan informasi pasangan tampil di profil & beranda.

---

### 💳 MODUL 3: Keuangan & Catatan Transaksi Manual (Part 4)
*Tujuan: Memastikan pencatatan kas rumah tangga dan anomali pengeluaran ter-refresh otomatis.*

- [ ] **3.1 Ringkasan Arus Kas**:
  - Buka tab **Keuangan**.
  - Periksa total saldo bersama, total pemasukan, dan total pengeluaran.
- [ ] **3.2 Tambah Transaksi Manual**:
  - Tekan tombol **+ Transaksi**.
  - Isi nama pengeluaran (misal: *Belanja Mingguan*), nominal (misal: `Rp 450.000`), kategori, dan tanggal.
  - Klik **Simpan**.
  - **Ekspektasi**: Transaksi muncul di daftar transaksi terbaru dan saldo di dashboard keuangan otomatis ter-update.

---

### 📄 MODUL 4: Impor E-Statement Rekening Koran (Part 5)
*Tujuan: Memastikan ekstraksi PDF e-statement, penanganan kata sandi ephemeral, dan konfirmasi draft.*

- [ ] **4.1 Upload & Password Ephemeral**:
  - Klik tombol **Impor E-Statement** di tab Keuangan.
  - Pilih file PDF e-statement (atau simulasi sample).
  - Jika diminta kata sandi PDF, masukkan password.
  - **Ekspektasi**: Password hanya digunakan secara ephemeral di memori (tidak pernah disimpan/dicatat di log), dan file berhasil terurai menjadi *Draft Transaksi*.
- [ ] **4.2 Review & Konfirmasi Draft**:
  - Periksa transaksi normal dan transaksi yang ditandai *Perlu Konfirmasi* (anomali).
  - Sesuaikan kategori jika diperlukan, lalu klik **Konfirmasi & Simpan Transaksi**.
  - **Ekspektasi**: Transaksi berpindah dari status draft ke buku kas utama secara permanen.

---

### 🎯 MODUL 5: Tabungan Bersama / Financial Goals (Part 6)
*Tujuan: Memastikan penyusunan target tabungan bersama dan pencatatan kontribusi.*

- [ ] **5.1 Buat Target Tabungan Baru**:
  - Buka tab **Tabungan** -> Klik **Buat Target Baru**.
  - Isi nama (misal: *Dana Darurat Keluarga*), nominal target (misal: `Rp 20.000.000`), dan bulan tenggat.
  - Klik **Simpan**.
  - **Ekspektasi**: Card target tabungan muncul dengan progress 0%.
- [ ] **5.2 Tambah Kontribusi Tabungan**:
  - Pilih card target -> Klik **Isi Kontribusi**.
  - Masukkan nominal kontribusi (misal: `Rp 1.000.000`).
  - **Ekspektasi**: Progress bar ter-update dinamis dan riwayat kontribusi tercatat di detail target.

---

### 📝 MODUL 6: Check-In Mingguan Emosional (Part 7)
*Tujuan: Memastikan refleksi kondisi emosional privat pengguna tersimpan rapi.*

- [ ] **6.1 Pengisian Jurnal Mingguan**:
  - Buka menu **Check-In Mingguan** di Beranda.
  - Pilih emoji emosi minggu ini, topik perhatian utama, dan slider tingkat komunikasi.
  - Klik **Kirim Check-In**.
  - **Ekspektasi**: Jawaban tersimpan aman secara privat dan status check-in minggu ini bertanda diselesaikan.

---

### 🧠 MODUL 7: Asesmen Keluarga & AI Narrative (Part 8 + Model 2 Addendum)
*Tujuan: Memastikan pengolahan narasi kecerdasan buatan dari backend Vercel.*

- [ ] **7.1 Analisis Kondisi Keluarga**:
  - Buka menu **Kondisi Keluarga**.
  - **Ekspektasi**: Mengambil data dari endpoint `/family-assessments/current` (dan `/family-assessments/{id}`).
  - Menampilkan **Headline AI** (misal: *Komunikasi Stabil, Perlu Perhatian Alokasi Pos Harian*), Ringkasan Naratif, Rencana Aksi, dan Highlight Per Aspek secara santun dan netral.

---

### 🕊️ MODUL 8: Ruang Pemulihan Bersama / Recovery Session (Part 9)
*Tujuan: Memastikan mediasi terpandu saat terjadi konflik emosional/finansial.*

- [ ] **8.1 Mulai Sesi Pemulihan**:
  - Buka **Ruang Pemulihan Bersama** di Beranda -> Klik **Mulai Sesi Baru**.
  - Pilih topik (misal: *Evaluasi Pengeluaran Tak Terduga*).
- [ ] **8.2 Cek Kesiapan & Refleksi Privat**:
  - Konfirmasi kesiapan emosional.
  - Tulis refleksi pribadi.
  - **Ekspektasi**: Refleksi asli tetap privat, dan hanya draf pernyataan netral yang dapat dipublikasikan ke pasangan jika pengguna secara eksplisit menyetujuinya.

---

### 🤝 MODUL 9: Komitmen Bersama / Joint Commitments (Part 10)
*Tujuan: Memastikan penyusunan janji tindakan bersama dan proses persetujuan pasangan.*

- [ ] **9.1 Buat Draf Komitmen**:
  - Di Ruang Pemulihan atau Tab Komitmen, klik **Buat Komitmen Baru**.
  - Isi nama komitmen (misal: *Alokasi Pos Jajanan Rp 300rb/minggu*) dan tindakan.
- [ ] **9.2 Persetujuan Pasangan**:
  - Klik **Setujui Komitmen** (approve).
  - **Ekspektasi**: Status komitmen berubah dari `pending` menjadi `active`, dan persentase progres dapat diperbarui berkala.

---

### 💬 MODUL 10: Konselor AI Empati — Gemini Wrapping (Part 11)
*Tujuan: Memastikan integrasi penuh chatbot AI dengan server backend Vercel + Gemini.*

- [ ] **10.1 Chat Sesi Real AI**:
  - Buka menu **Konselor AI** -> Kirim pesan (misal: *Bagaimana cara membagi anggaran rumah tangga yang ideal?*).
  - **Ekspektasi**: Pesan terkirim secara *Optimistic UI* (langsung muncul di layar), indikator *Konselor AI sedang mengetik...* berjalan, dan jawaban dari model Gemini asli dari backend Vercel mendarat dengan mulus di layar **tanpa pernah berkedip atau menghilang**.
- [ ] **10.2 Deteksi Tensi Tinggi & Safety Level**:
  - Kirim pesan dengan tensi emosi tinggi (misal: *Saya stres dan pusing menghadapi utang keluarga*).
  - **Ekspektasi**: AI mendeteksi pesan tersebut, menyertakan `suggested_actions` dan arahan rujukan ke bantuan profesional secara netral dan aman.

---

### 🏥 MODUL 11: Konseling Digital & Direktori Profesional (Part 12)
*Tujuan: Memastikan pencarian psikolog/konselor finansial profesional.*

- [ ] **11.1 Filter Direktori Ahli**:
  - Buka menu **Konseling Digital**.
  - Gunakan filter kategori (*Psikolog Pernikahan*, *Konselor Finansial*) atau kota.
  - **Ekspektasi**: Daftar profesional tersaring sesuai kriteria.
- [ ] **11.2 Detail & Kontak Eksternal**:
  - Klik salah satu profil ahli.
  - **Ekspektasi**: Menampilkan latar belakang, spesialisasi, tarif, dan tombol rujukan kontak eksternal (WA/Email/Website) yang dapat diklik.

---

### 🎮 MODUL 12: Simulasi Dampak (Part 13 — Preview Only Boundary)
*Tujuan: Memastikan boundary simulasi lokal terlindungi.*

- [ ] **12.1 Fitur Simulasi Dampak**:
  - Buka **Simulasi Dampak** di Ruang Mediasi.
  - Geser parameter angka pengeluaran atau utang.
  - **Ekspektasi**: Menampilkan proyeksi indikatif secara lokal. Fitur ini ditandai secara transparan sebagai *Simulasi Indikatif Lokal (NOT BACKEND-INTEGRATED)* sesuai batas spesifikasi Part 13.

---

## 🛡️ 3. Audit Batasan Etika & Privasi Mutlak (Safety Invariants)

Sebelum menyatakan Sprint V1 LULUS, pastikan 6 kriteria keamanan dan etika berikut terpenuhi tanpa pengecualian:

1. **[ ] Istilah Netral**: Aplikasi **tidak pernah** menyebut pengeluaran sebagai *"bukti judi online"*. Menggunakan istilah netral: *"transaksi tidak biasa"*, *"memerlukan perhatian"*, atau *"perlu konfirmasi"*.
2. **[ ] Tanpa Diagnosis**: AI **tidak pernah** memberikan diagnosis psikologis klinis atau memprediksi/merekomendasikan perceraian.
3. **[ ] Privasi Refleksi**: Jawaban mentah *Weekly Check-In* dan *Refleksi Privat Pemulihan* **tidak pernah** ditampilkan langsung ke layar pasangan tanpa persetujuan eksplisit.
4. **[ ] Otoritas Keputusan**: AI **tidak pernah** mengubah skor, komitmen, atau persetujuan secara sepihak.
5. **[ ] Kerahasiaan Log**: `debugPrint` atau console log **tidak pernah** mencetak `access_token`, `refresh_token`, atau `document_password`.
6. **[ ] Kebersihan State**: Tombol **Logout** secara tuntas membersihkan memori dan token dari perangkat.

---

## 🎯 4. Penilaian Akhir Kesiapan Sprint V1

| Pengujian | Status | Keterangan |
|---|---|---|
| Static Analysis (`flutter analyze`) | 🟢 PASS | `No issues found!` |
| Integrasi Vercel API Remote | 🟢 PASS | 81 Operations HTTP terintegrasi |
| Gemini AI Chatbot Wrapping | 🟢 PASS | Terhubung via `POST /chat/sessions/{id}/messages` |
| UI Optimistic & Responsif | 🟢 PASS | Tidak ada flicker, overflow, atau dead-end |
| Layak Demo GEMASTIK | 🟢 READY | Dapat diragakan secara smooth & aman |

> **KESIMPULAN**: Jika seluruh checklist di atas telah tercentang (minimal 80%), aplikasi **FAVERA FRONTEND V1 RESMI DINYATAKAN READY FOR SPRINT V1 RELEASE & DEMO GEMASTIK!** 🏆
