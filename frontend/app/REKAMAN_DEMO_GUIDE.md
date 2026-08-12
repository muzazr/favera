# 📹 Panduan Alur Rekam Screen Demo Favera

Dokumen ini disusun sebagai panduan langkah demi langkah (rundown) untuk merekam seluruh alur fitur aplikasi **Favera**. Alur disusun secara terstruktur per modul agar rekaman rapi, sistematis, dan tanpa hambatan.

---

## 🎬 Urutan Rekam Layar (Rundown)

### 🔑 1. Modul Autentikasi & Masuk
1. **Layar Masuk / Daftar** (`/auth`)
   - Tunjukkan tab **Daftar**, isi nama, email baru, password, lalu centang persetujuan privasi.
   - Tekan **Daftar** (akan beralih ke tab **Masuk** & menampilkan pesan sukses).
   - Isi kata sandi, lalu tekan **Masuk**.

---

### 💰 2. Modul Keuangan (Selesaikan Seluruh Fitur Keuangan)
*(Buka dari Bottom Navigation: **Keuangan**)*

1. **Ringkasan Keuangan & Anomali** (`/app/finance`)
   - Tunjukkan kartu Total Pendapatan, Pengeluaran, dan Saldo Bersih.
   - Tunjukkan kartu **Transaksi Perlu Konfirmasi** (transaksi tidak biasa/anomali).
2. **Unggah E-Statement / Mutasi PDF**
   - Ketuk tombol **Unggah E-Statement** (pilih file PDF bank).
   - Tunjukkan proses analisis AI & hasil ringkasan transaksi otomatis.
3. **Target Tabungan Bersama (Emergency / Savings Goals)** (`/app/finance/goals/:id`)
   - Ketuk salah satu Target Tabungan (misal: *Dana Darurat Keluarga*).
   - Ketuk **+ Tambah Tabungan Target** / **Isi Kontribusi**.
   - Masukkan nominal (misal: `Rp 500.000`), lalu tekan **Simpan Kontribusi**.
   - Tunjukkan indikator progress tabungan & riwayat kontribusi yang otomatis bertambah.

---

### 👨‍👩‍👧 3. Modul Kesehatan Keluarga & AI Narrative
*(Kembali ke **Beranda** `/app/home`)*

1. **Status Kesehatan Keluarga** (`/app/family`)
   - Tunjukkan Kartu Status Keluarga (misal: *Aman Terkendali* atau *Perlu Perhatian*).
   - Ketuk kartu untuk melihat **Grafik Asesmen Radar 5 Pilar** (Keterbukaan, Komitmen, Kesiapan, dll.).
2. **AI Narrative & Analisis Finansial-Komunikasi**
   - Scroll untuk memperlihatkan **Ringkasan Narasi AI** yang memberikan refleksi empati dan rekomendasi netral untuk pasangan.

---

### 🕊️ 4. Modul Mediasi & Ruang Pemulihan Bersama
*(Buka dari Beranda / Pusat Bantuan -> **Mediasi** `/app/mediation`)*

1. **Konseling Digital / Tanya AI Favera** (`/app/mediation/chat`)
   - Ketuk **Tanya AI Favera**.
   - Kirim pertanyaan contoh: *"Bagaimana cara mendiskusikan pengeluaran hiburan dengan pasangan tanpa memicu konflik?"*.
   - Tunjukkan jawaban AI yang netral, solutif, dan tidak menghakimi.
2. **Ruang Pemulihan Bersama & Komitmen** (`/app/mediation/recovery`)
   - Ketuk **Ruang Pemulihan Bersama**.
   - Ketuk **+ Mulai Sesi Pemulihan Baru** (pilih topik *Pengelolaan Anggaran Bulanan* & tekan *Mulai Sesi*).
   - **Langkah 1 (Cek Kesiapan):** Ketuk *"Saya Siap & Merasa Aman"*.
   - **Langkah 2 (Refleksi Privat):** Isi draf pernyataan ke pasangan, lalu tekan *Publikasikan ke Pasangan*.
   - **Langkah 3 (Menunggu):** Tekan *Simulasikan Respon Pasangan (Demo)*.
   - **Langkah 4 (Penyelarasan & Komitmen):** Isi judul komitmen (misal: *Batas Pengeluaran Hiburan*) lalu tekan *Sepakati & Aktifkan Komitmen*.
3. **Simulasi Finansial & Dampak Pasangan** (`/app/mediation/simulation`)
   - Ketuk **Simulasi Finansial**.
   - Geser slider biaya hidup / jumlah anak / pengeluaran.
   - Tunjukkan proyeksi indikator finansial netral (tanpa prediksi perceraian).
4. **Direktori Konselor & Psikolog** (`/app/mediation/professionals`)
   - Ketuk **Konseling Profesional**.
   - Tunjukkan daftar psikolog/konselor keluarga tersertifikasi dan tombol *Hubungi/Jadwalkan*.

---

### ⚙️ 5. Penutup / Profil
*(Buka dari Bottom Navigation: **Profil** `/app/profile`)*

1. Tunjukkan profil pengguna, status koneksi pasangan (*Terhubung*).
2. Tunjukkan privasi data (chat & refleksi tetap privat).
3. Selesai! 🎉

---

### 💡 Tips Rekam Layar:
- **Hot Restart (`R`)** sebelum mulai rekam agar data dalam keadaan segar.
- Durasi ideal rekaman: **2 – 3 menit**.
