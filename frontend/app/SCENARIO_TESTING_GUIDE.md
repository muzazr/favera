# Panduan Pengujian Skenario Aplikasi Favera (Part 1 - 12)

Dokumen ini berisi panduan langkah demi langkah untuk menguji perjalanan pengguna (*user journey*) lengkap aplikasi **Favera** dari proses Registrasi/Auth (Part 1) hingga Komitmen Bersama (Part 10).

---

## 🛠️ Persiapan Awal

Sebelum memulai, pastikan emulator Anda (`emulator-5554`) menyala dan jalankan aplikasi menggunakan salah satu mode berikut:

### Skenario A: Menggunakan Mode Hybrid (Integrasi Remote Server)
Skenario ini menggunakan backend Vercel asli untuk Auth, Keluarga, Transaksi, Impor E-Statement, dan Tabungan Bersama.
```bash
flutter run -d emulator-5554 --dart-define=APP_MODE=hybrid
```

### Skenario B: Menggunakan Mode Mock (Simulasi Lokal Stateful)
*Sangat disarankan untuk demo cepat atau jika backend remote sedang dalam pembatasan quota / maintenance.*
```bash
flutter run -d emulator-5554 --dart-define=APP_MODE=mock
```

---

## 📋 Tahapan Skenario Pengujian

### 🔑 Fase 1: Onboarding & Autentikasi (Part 1 - 3)
Fase ini menguji pendaftaran, masuk akun, pembuatan ruang keluarga, dan penyambungan dengan pasangan.

1. **Registrasi Akun Baru**:
   - Di halaman Onboarding, klik **Mulai Sekarang**.
   - Di layar Autentikasi, klik tab **Daftar**.
   - Masukkan Email, Nama Panggilan, dan Password yang valid (minimal 8 karakter dengan angka & simbol).
   - Klik **Daftar**. Anda akan otomatis masuk ke halaman pengisian ruang keluarga.
2. **Membuat Ruang Keluarga (Pihak 1)**:
   - Pilih opsi **Buat Kode Undangan Baru**.
   - Sistem akan men-generate kode unik (contoh: `FAV-XXXXX`). Salin kode tersebut.
3. **Menerima Undangan (Pihak 2)**:
   - *Opsional (jika menggunakan device kedua)*: Masuk dengan akun pasangan, pilih **Masukkan Kode Undangan Pasangan**, masukkan kode yang disalin tadi, lalu klik **Sambungkan**.
   - *Alternatif Quick Test*: Pada mode `mock`, Anda bisa menekan tombol **Simulasikan Pasangan Masuk** untuk langsung memperbarui status keluarga menjadi **Tersambung (Active)**.

---

### 📊 Fase 2: Manajemen Keuangan & E-Statement (Part 4 - 5)
Fase ini menguji pencatatan transaksi secara manual, deteksi anomali, dan impor otomatis rekening koran.

4. **Dashboard Keuangan (Part 4)**:
   - Dari tab **Keuangan**, lihat ringkasan Arus Kas, Pendapatan, dan Pengeluaran.
   - Klik **Tambah Transaksi secara Manual** (+), isi data transaksi, pilih kategori, lalu simpan. Perhatikan grafik dan riwayat transaksi langsung ter-refresh.
5. **Impor E-Statement (Part 5)**:
   - Di tab Keuangan, klik tombol **Impor E-Statement**.
   - Pilih berkas PDF/CSV (simulasi).
   - Jika dokumen terproteksi (PDF Bank), Anda akan diminta memasukkan kata sandi (contoh mock password: `Password123!`).
   - Periksa daftar **Draft Transaksi** hasil ekstraksi. Anda dapat mengubah kategori atau mengonfirmasi transaksi yang terdeteksi tidak biasa (anomali).
   - Klik **Konfirmasi & Impor Semua**. Transaksi tersebut akan otomatis masuk ke buku kas utama.

---

### 🎯 Fase 3: Tabungan Bersama (Part 6)
Fase ini menguji pembuatan rencana tabungan bersama dan penyetoran kontribusi.

6. **Membuat Target Tabungan**:
   - Di tab **Tabungan**, klik **Buat Target Baru**.
   - Isi nama target (misal: *DP Rumah*), nominal target (misal: *Rp 50.000.000*), dan target tanggal pencapaian.
   - Klik **Simpan**. Target baru akan muncul dengan progress bar 0%.
7. **Simulasi Kontribusi Tabungan**:
   - Klik pada target tabungan yang baru dibuat.
   - Klik **Isi Kontribusi**, masukkan nominal (misal: *Rp 2.000.000*), lalu konfirmasi.
   - Progress bar tabungan akan naik secara dinamis dan riwayat kontribusi Anda tercatat.

---

### 📝 Fase 4: Weekly Check-In & AI Narrative (Part 7 - 8)
Fase ini menguji refleksi emosi mingguan individu dan analisis kecerdasan buatan (AI) terhadap keharmonisan keluarga.

8. **Mengisi Check-In Mingguan (Part 7)**:
   - Di Beranda, klik menu **Check-In Mingguan**.
   - Pilih emoji kondisi emosi Anda minggu ini (misal: *Lelah* 😮‍💨 atau *Damai* 😌).
   - Pilih isu utama yang menyita pikiran Anda (misal: *Keuangan 💸*).
   - Geser slider kualitas komunikasi dengan pasangan Anda.
   - Tekan **Simpan Jurnal**. Sistem akan mengirimkannya ke server backend.
9. **Melihat Hasil Analisis AI (Part 8)**:
   - Setelah sukses menyimpan jurnal, Anda akan dialihkan ke layar **Kondisi Keluarga**.
   - Anda akan melihat animasi loading `Menganalisis narasi keluarga...`.
   - AI Narrative akan menampilkan headline (misal: *Perlu Perhatian Finansial*), overview naratif lengkap, serta sorotan detail (*Highlights*) untuk aspek komunikasi dan keuangan keluarga Anda.

---

### 🤝 Fase 5: Pemulihan Hubungan & Komitmen Bersama (Part 9 - 10)
Fase ini menguji proses mediasi terpandu jika terdeteksi isu keuangan, refleksi mandiri, dan kesepakatan komitmen bersama.

10. **Membuat Sesi Pemulihan (Part 9)**:
    - Di Beranda, masuk ke **Ruang Pemulihan Bersama**.
    - Klik **Mulai Sesi Pemulihan Baru**, pilih topik (misal: *Pengelolaan Anggaran Bulanan*), lalu buat sesi.
    - Sesi akan dimulai pada langkah **Cek Kesiapan**. Konfirmasi kesiapan emosional Anda.
    - Tulis **Refleksi Privat** mengenai isu anggaran yang dihadapi, lalu klik **Publikasikan Pernyataan** agar pasangan dapat melihatnya.
    - Tekan **Simulasikan Respon Pasangan** untuk mengisi respon dari pihak kedua.
11. **Menyepakati Komitmen (Part 10)**:
    - Masuk ke langkah **Penyusunan Komitmen**.
    - Klik **Buat Komitmen Baru**, isi judul komitmen (misal: *Membatasi Makan Luar Rp 500rb/bulan*) dan deskripsinya.
    - Pasangan akan melihat draf komitmen tersebut. Klik **Setujui Komitmen** (approve).
    - Status komitmen akan berubah menjadi **Aktif** dan akan muncul di beranda utama untuk dilacak progress pencapaiannya (0% - 100%).

---

### 💬 Fase 6: Chat Empati AI & Konseling Profesional (Part 11 - 12)
Fase ini menguji chatbot empati AI pendeteksi tensi finansial dan direktori konseling profesional.

12. **Chat Empati AI (Part 11)**:
    - Buka menu **Tanya AI** di Beranda.
    - Tekan **Mulai Sesi Chat Baru**.
    - Kirim pesan (misal: *Bagaimana cara membagi pengeluaran makan kami?*). Chatbot akan menjawab secara empatik.
    - Coba kirim pesan dengan tensi tinggi (misal: *Saya stres dan bertengkar hebat dengan pasangan saya karena utang*). AI akan mendeteksi tingkat ketegangan tinggi, mengaktifkan `safety_level` khusus, dan menampilkan banner merah rekomendasi bantuan profesional secara netral.
13. **Mencari Konselor Finansial & Mediator (Part 12)**:
    - Buka menu **Konseling Digital** di Beranda.
    - Gunakan Filter Chips di bagian atas (misal: *Psikolog Pernikahan*, *Konselor Finansial*) untuk menyaring daftar ahli yang sesuai.
    - Klik salah satu profil ahli (misal: *Siti Rahma, M.Psi.*).
    - Anda dapat melihat detail keahlian, tarif, jadwal tersedia, serta tautan langsung untuk menghubungi ahli secara eksternal.

---

## 🏁 Panduan Pengujian Tuntas Kesiapan Sprint V1
Untuk panduan pengujian menyeluruh (Part 0 s.d Part 14) beserta audit etika, privasi, sanitasi token, dan kriteria kelulusan rilis V1, silakan buka dokumen khusus:
👉 **[SPRINT_V1_READY_TESTING_GUIDE.md](file:///c:/Users/zakia/Documents/0_CODING/Lomba/favera/frontend/app/docs/SPRINT_V1_READY_TESTING_GUIDE.md)**


