# Demo Scenario — GEMASTIK

## 1. Tujuan

Skenario demo harus:

- deterministik;
- dapat dijalankan tanpa restart;
- menunjukkan diferensiasi Favera;
- memperlihatkan integrasi AI tanpa klaim berlebihan;
- tetap dapat berjalan melalui mock bila staging gagal;
- selesai dalam durasi video yang masuk akal.

## 2. Persona seed

### Pengguna aktif

```text
Nama: Joselin
Email: joselin.demo@favera.local
Status onboarding: selesai
Status family: active
```

### Pasangan

```text
Nama: Budi
Status: terhubung
Partner weekly check-in: submitted
```

Gunakan identitas dummy. Jangan memakai informasi pribadi anggota tim pada build publik.

## 3. Kondisi awal

```text
Family status: stable
Total balance: Rp12.500.000
Income bulan berjalan: Rp5.500.000
Expense bulan berjalan: Rp2.450.000
Active goal: Dana Darurat
Goal progress: Rp5.500.000 / Rp10.000.000
Weekly check-in: belum dikirim oleh Joselin
```

Recent transactions:

- Belanja Bulanan, expense Rp150.000;
- Tagihan Listrik, expense Rp450.000;
- Gaji Bulanan, income Rp5.500.000.

## 4. E-statement scenario

Gunakan fixture yang merepresentasikan Mandiri/BRI/GoPay.

Import result:

```text
Provider: Mandiri atau BCA-style visual sesuai mockup, tetapi contract provider tetap salah satu enum resmi
Period: satu bulan
Total detected: 145
Needs review: 2
Normal: 143
```

Dua item review:

### Item 1

```text
Description: APPLE.COM/BILL
Amount: Rp1.499.000
Reason: nominal berbeda dari kebiasaan
Status: pending
Action demo: pilih kategori lalu validasi
```

### Item 2

```text
Description: STARBUCKS COFFEE
Amount: Rp110.000
Reason: kemungkinan duplikat
Status: pending
Action demo: hapus salah satu draft atau validasi sesuai narasi
```

Jangan menyatakan item tersebut terkait judi. Tujuannya menunjukkan explainable anomaly dan human confirmation.

## 5. Weekly check-in scenario

Jawaban Joselin:

```text
Emotion: damai / cukup baik
Main concern: keuangan
Communication quality: cukup lancar
Private note: optional
Safety signals: none
```

Partner sudah submitted melalui seed.

Setelah submit:

```text
Check-in status: processing → completed
Urgency: low
Family assessment: stable
Trend: stable atau improving
```

Tampilkan:

- arus kas positif;
- sisa budget 70%;
- tidak ada pengeluaran anomali yang belum dikonfirmasi;
- komunikasi cukup baik;
- stress rendah;
- satu supportive insight.

## 6. AI chat scenario

User message:

```text
Pengeluaran bulan ini overbudget sementara pemasukan belum jelas.
Aku bingung mulai dari mana.
```

Expected structured response:

- acknowledgment netral;
- saran cek kebutuhan prioritas;
- saran menyusun percakapan dengan pasangan;
- action membuka finance atau recovery;
- safety level `none`;
- tidak memberi diagnosis;
- tidak menyalahkan pasangan.

Suggested action chips:

- Tinjau transaksi;
- Susun percakapan;
- Bicara dengan ahli.

## 7. Professional directory

Seed minimal:

1. psikolog pernikahan;
2. konselor finansial;
3. mediator keluarga;
4. layanan bantuan resmi.

Setiap record memiliki:

- nama dummy atau lembaga resmi yang telah diverifikasi tim;
- kategori;
- specializations;
- city;
- mode layanan;
- cost type;
- external links;
- verification status.

Jangan memasukkan nomor kontak acak yang dapat mengarah ke orang sungguhan.

## 8. Simulation

Input seed:

- current monthly living cost;
- shared balance;
- child count;
- child monthly needs;
- debt;
- emergency fund.

Result:

- impact finansial;
- impact anak;
- assumption list;
- disclaimer;
- CTA professional.

Narasi wajib:

```text
Hasil ini adalah bahan refleksi berdasarkan input dan formula versi tertentu.
Hasil bukan prediksi hukum, diagnosis, atau rekomendasi untuk berpisah.
```

## 9. Video flow

### Segmen 1 — Pembukaan

1. onboarding cepat;
2. login;
3. pairing success atau tunjukkan akun sudah terhubung.

### Segmen 2 — Dashboard dan finansial

1. home dashboard;
2. buka finance;
3. tambah transaksi;
4. buka goal;
5. upload e-statement.

### Segmen 3 — AI inference

1. upload file;
2. processing status;
3. review two unusual transactions;
4. validasi/hapus;
5. confirm;
6. dashboard berubah.

### Segmen 4 — Kondisi keluarga

1. weekly check-in;
2. submit;
3. processing;
4. family condition;
5. explanation dan recommended action.

### Segmen 5 — Pendampingan

1. mediation hub;
2. AI chat;
3. professional directory;
4. simulation result;
5. settings/privacy.

## 10. Demo controls

Pada debug/demo build sediakan:

- reset scenario;
- pilih scenario;
- force statement status;
- force check-in partner submitted;
- simulate network error;
- switch mock/hybrid;
- copy diagnostics tanpa sensitive data.

Kontrol ini tidak boleh muncul pada production build.

## 11. Fallback plan

### Backend sehat

Gunakan hybrid/remote untuk P0.

### Backend parsial

Gunakan remote untuk auth/dashboard dan mock untuk feature yang belum stabil.

### Backend gagal saat rekaman

Gunakan mock full dengan data dan timing yang sama.

Jangan melakukan fallback otomatis diam-diam pada production. Untuk demo build, fallback harus eksplisit dan terlihat hanya di debug indicator.

## 12. Demo readiness checklist

- fresh install path diuji;
- seeded login bekerja;
- statement file tersedia di device;
- document password tersedia bagi presenter tetapi tidak disimpan aplikasi;
- mock reset bekerja;
- backend health diperiksa;
- mode build dicatat;
- seluruh CTA dalam video bekerja;
- keyboard tidak menutupi screen;
- tidak ada notification pop-up pribadi;
- internet fallback tersedia;
- screen recording resolution diuji;
- tidak ada debug banner pada final recording kecuali sengaja.
