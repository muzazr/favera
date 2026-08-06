# Design Brief — Favera Mobile

Dokumen ini adalah referensi visual tekstual utama. Agent tidak perlu terus membuka screenshot kecuali melakukan visual QA akhir.

Mockup sumber terdapat pada `UI SO FAR.pdf`, halaman 1–4.

## 1. Karakter visual

Favera harus terasa:

- aman;
- lembut;
- optimistis;
- personal;
- tidak klinis;
- tidak menghakimi;
- modern tetapi sederhana.

Aplikasi membahas uang, konflik, dan risiko keluarga. UI tidak boleh terasa seperti dashboard investigasi kriminal atau aplikasi pinjaman. Fokusnya adalah rasa aman, kendali pengguna, dan langkah kecil yang dapat dilakukan.

## 2. Bahasa bentuk

Ciri utama:

- latar belakang gradasi sangat lembut dari lavender/blue menuju mint;
- card putih atau putih transparan dengan radius besar;
- tombol utama hijau berbentuk pill;
- tombol atau state sekunder oranye;
- chip kategori berbentuk pill;
- bayangan lembut;
- banyak ruang kosong;
- ikon berwarna dalam lingkaran atau tile pastel;
- angka finansial besar dan tegas;
- bottom navigation berupa rounded floating bar;
- status keluarga tampil sebagai badge/capsule;
- informasi risiko memakai card penjelas, bukan hanya angka.

## 3. Token awal

Warna berikut adalah **aproksimasi awal dari mockup**, bukan hasil ekstraksi design system resmi. Simpan seluruhnya sebagai token agar mudah disesuaikan saat visual QA.

```dart
abstract final class AppColors {
  static const primary = Color(0xFF19C66A);
  static const primaryDark = Color(0xFF087A54);
  static const primarySoft = Color(0xFFD9F7E8);

  static const accentOrange = Color(0xFFFF7418);
  static const accentOrangeSoft = Color(0xFFFFE5D5);

  static const lavender = Color(0xFFF0EDFF);
  static const sky = Color(0xFFEAF7FF);
  static const mint = Color(0xFFDDF9EC);

  static const textPrimary = Color(0xFF1D2635);
  static const textSecondary = Color(0xFF667085);
  static const border = Color(0xFFE5E9F0);
  static const surface = Color(0xFFFFFFFF);

  static const success = Color(0xFF1DBE68);
  static const warning = Color(0xFFF5A623);
  static const danger = Color(0xFFE85B5B);
  static const info = Color(0xFF4B8DF8);
}
```

Gunakan contrast checker sebelum final. Jangan mempertahankan warna aproksimasi bila teks menjadi sulit dibaca.

## 4. Spacing dan radius

Gunakan skala 4/8:

```text
4, 8, 12, 16, 20, 24, 32, 40
```

Rekomendasi:

- page horizontal padding: 20;
- card padding: 16–20;
- gap antarsection: 20–24;
- radius card utama: 20–24;
- radius input: 14–16;
- radius pill/button: 24–32;
- min button height: 48;
- min tap target: 44×44.

## 5. Typography

Prioritas: keterbacaan dan hierarki.

- display balance: bold, besar, tabular figure bila tersedia;
- page title: semibold;
- section title: semibold;
- body: regular;
- helper: regular dengan warna sekunder;
- warning: medium, tidak seluruhnya merah;
- label tombol: semibold.

Jangan menggunakan ukuran terlalu kecil demi meniru screenshot. Gunakan minimum sekitar 12–13sp untuk helper dan 14–16sp untuk body.

## 6. Layout umum

Setiap screen:

```text
SafeArea
→ optional top app bar
→ scrollable body
→ bottom action atau bottom nav
```

- Jangan letakkan primary action tertutup keyboard.
- Screen form memakai sticky bottom action bila sesuai.
- Screen list memakai pull-to-refresh hanya bila remote.
- Hindari nested scroll yang tidak perlu.
- Gunakan responsive constraint agar tetap rapi pada layar tinggi/pendek.

## 7. Bottom navigation

Empat area:

1. Home
2. Keuangan
3. Mediasi
4. Profil

Bentuk:

- floating rounded bar;
- background putih;
- icon aktif hijau;
- item aktif dapat memiliki label;
- indikator halus, bukan blok besar;
- tetap terlihat pada root tab;
- hilang pada detail screen ketika mengganggu fokus.

## 8. Komponen utama

### Family Status Badge

- capsule tipis;
- icon status kecil;
- teks contoh: “Status Keluarga · Aman Terkendali”;
- warna mengikuti level;
- selalu memiliki label, tidak bergantung pada warna.

### Balance Hero Card

- gradasi hijau;
- label uppercase kecil;
- nominal besar putih;
- radius besar;
- tidak menampilkan saldo bila hide balance aktif.

### Goal Card

- nama goal;
- current/target amount;
- progress bar;
- optional menu;
- state approval bila belum disetujui.

### Transaction Row

- icon kategori pastel;
- title;
- tanggal/waktu;
- amount di kanan;
- avatar/status kecil bila shared;
- anomaly badge bila perlu;
- tap menuju detail.

### Insight/Warning Card

- latar pastel;
- icon;
- title singkat;
- explanation;
- action bila relevan;
- jangan hanya menampilkan “bahaya” tanpa langkah berikutnya.

### Pill Choice

- satu atau multi-select;
- selected state jelas;
- icon optional;
- tidak mengandalkan warna saja.

### Primary Button

- hijau;
- full width pada flow utama;
- icon optional;
- loading state mempertahankan ukuran;
- disabled state jelas.

### Secondary/Destructive Button

- orange untuk tindakan alternatif penting;
- red/pink hanya untuk disconnect, cancel, atau risiko;
- destructive action membutuhkan konfirmasi.

## 9. Brief per screen

### 9.1 Onboarding

Tiga screen dengan komposisi:

- ilustrasi besar di tengah atas;
- panel putih rounded dari bawah;
- progress indicator pendek;
- title singkat;
- body dua sampai tiga baris;
- tombol “Lanjut” atau “Mulai”;
- “Lewati” di kanan atas.

Pesan:

1. satu ruang untuk uang dan perasaan;
2. transparansi tanpa menghakimi;
3. komunikasi dan akses bantuan.

### 9.2 Register/Login

- background gradient;
- logo di atas;
- white card rounded;
- segmented control “Masuk / Daftar”;
- field sederhana;
- consent text pada register;
- primary CTA;
- social login tampil hanya bila benar-benar berfungsi atau diberi status roadmap non-interaktif.

### 9.3 Account Pairing

Screen invite:

- title “Hubungkan Akun”;
- explanation singkat;
- room ID card biru;
- copy button;
- input kode pasangan;
- CTA kirim permintaan.

Screen pending:

- profile pasangan;
- nama dan ID;
- CTA terima hijau;
- CTA tolak oranye;
- teks bahwa koneksi dapat diputus lewat settings.

Screen success:

- dua avatar;
- nama keluarga;
- status terenkripsi;
- card “Ruang Aman Kalian Sudah Siap”;
- CTA masuk beranda.

### 9.4 Home Dashboard

Urutan:

1. greeting dan avatar;
2. family status badge;
3. balance hero;
4. active financial goal;
5. weekly check-in banner;
6. bantuan/mediation horizontal cards;
7. recent activity;
8. add transaction button;
9. bottom nav.

Dashboard harus cukup ringkas untuk satu layar awal, tetapi dapat scroll.

### 9.5 Finance Dashboard

- greeting ringkas;
- total balance;
- horizontal goal cards;
- CTA tambah target;
- CTA tambah transaksi;
- CTA upload e-statement dengan warna orange soft;
- recent transactions;
- bottom nav aktif “Keuangan”.

### 9.6 Add Transaction

- app bar dengan close/back;
- segmented income/expense;
- amount input sebagai fokus utama;
- category chips;
- description multiline;
- sticky save button;
- income memakai hijau, expense memakai oranye;
- format rupiah saat input tanpa merusak cursor.

### 9.7 Statement Upload

Gunakan bottom sheet atau full page:

- title;
- dashed upload zone;
- icon upload orange;
- support PDF/CSV;
- privacy reassurance;
- primary save/upload action;
- file selected state;
- progress state;
- password form bila PDF terkunci;
- error state yang spesifik.

### 9.8 Statement Review

- header success/period/total;
- section “Perlu Konfirmasi” dengan badge count;
- card per transaksi;
- reason text, date, description, amount;
- category selector;
- actions validasi, hapus, atau simpan;
- collapsed section transaksi normal;
- final CTA “Simpan ke Data Keuangan”.

Hindari kata “terdeteksi judi”. Gunakan reason yang faktual, misalnya nominal berbeda dari kebiasaan atau transaksi diduga duplikat.

### 9.9 Transaction History

- simple app bar;
- optional filter;
- vertical transaction rows;
- pagination/infinite scroll;
- empty state;
- bottom nav aktif finance.

### 9.10 Goals List dan Detail

List:

- card putih;
- title;
- current/target;
- progress;
- status approval.

Create/edit:

- target amount besar;
- quick-add chips;
- name;
- deadline;
- visual theme icon;
- contribution scheme;
- priority chips;
- CTA dengan lock icon bila membutuhkan approval pasangan.

Detail:

- circular progress;
- current amount;
- remaining;
- deadline;
- contribution history;
- add contribution.

### 9.11 Weekly Check-In

- app bar dengan week range;
- emotion choices memakai emoji/icon;
- concern topic chips;
- communication scale;
- optional private note;
- safety-critical questions harus jelas dan tidak disembunyikan;
- CTA “Simpan Jurnal”.

Tampilkan penjelasan bahwa jawaban mentah privat.

### 9.12 Family Condition

- large status card;
- status label seperti “Aman Terkendali”;
- short explanation;
- financial section: cashflow, budget, anomalies;
- emotional/relationship section;
- stress level;
- supportive insight card;
- recommended action;
- share icon hanya untuk summary yang memang shared.

Jangan menampilkan internal score sebagai probabilitas.

### 9.13 Mediation Hub

- introductory sentence;
- tiga main cards:
  1. Konselor AI Empatik;
  2. Bicara dengan Ahli;
  3. Simulasi Dampak;
- icon pastel;
- short explanation;
- text action;
- bottom nav aktif Mediasi.

Tambahkan Ruang Pemulihan Bersama sebagai card utama ketika feature tersedia.

### 9.14 AI Chat

- green app bar;
- avatar/status online;
- neutral background;
- user bubble hijau;
- assistant bubble cream/soft;
- suggested topic chips di atas composer;
- composer dengan attachment/camera hanya bila berfungsi;
- send/mic button;
- safety card atau professional referral sebagai inline structured message;
- typing/loading state.

### 9.15 Professional Directory

- category filter chips;
- search;
- professional card:
  - avatar/placeholder;
  - name;
  - category/specialization;
  - rating dan experience bila tersedia;
  - availability text;
  - CTA contact/schedule;
- external link warning bila keluar aplikasi.

### 9.16 Simulations

Input screen mengikuti design grammar form.

Result:

- disclaimer card di atas;
- tabs “Dampak Keuangan” dan “Dampak Anak”;
- grouped cards;
- monetary projection;
- assumptions;
- warning cards;
- CTA menuju professional;
- bukan prediksi hukum atau rekomendasi berpisah.

### 9.17 Settings/Profile

- profile card;
- account/family ID;
- connected status;
- grouped setting sections;
- switches untuk reminder, biometrics, hide balance;
- navigation rows;
- disconnect pasangan dengan red soft;
- logout neutral outline;
- app version di bawah.

## 10. Copywriting

Gunakan bahasa Indonesia:

- singkat;
- jelas;
- suportif;
- tidak menyalahkan;
- tidak hiperbolis.

Contoh:

```text
“Transaksi ini berbeda dari pola sebelumnya dan perlu dikonfirmasi.”
```

Bukan:

```text
“AI menemukan transaksi judi yang berbahaya.”
```

```text
“Hasil ini adalah bahan refleksi, bukan prediksi atau nasihat hukum.”
```

## 11. Empty, loading, error

Setiap feature wajib memiliki state yang didesain.

### Loading

- skeleton pada list/dashboard;
- progress bermakna pada upload;
- teks status pada parsing dan inference.

### Empty

- explanation;
- manfaat tindakan;
- satu CTA.

### Error

- pesan manusia;
- retry bila aman;
- request ID tersembunyi dalam detail/copy;
- jangan menampilkan stack trace;
- jangan hilangkan input pengguna.

## 12. Accessibility

- tap target minimum 44×44;
- semantic label untuk icon;
- text scaling sampai sekurangnya 1.3 tanpa overflow;
- label tidak hanya berupa placeholder;
- warna bukan satu-satunya indikator;
- nominal memakai grouping yang jelas;
- focus order logis;
- destructive action memiliki konfirmasi;
- animation dapat dikurangi;
- copy keselamatan mudah ditemukan.

## 13. Visual QA checklist

- bandingkan screen dengan mockup pada ukuran referensi;
- periksa hierarchy, bukan pixel obsession;
- pastikan gradient halus;
- radius konsisten;
- padding antarcard konsisten;
- CTA utama mudah ditemukan;
- bottom nav tidak menutupi content;
- keyboard tidak menutupi field/action;
- tidak ada teks kepotong;
- angka rupiah tidak overflow;
- warning tidak terasa menghakimi.
