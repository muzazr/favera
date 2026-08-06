# Project Context — Favera

## 1. Ringkasan produk

**Favera** adalah platform mobile pendamping keluarga yang terdampak judi online. Fokus produk bukan menghukum, mengawasi pasangan, atau membuktikan aktivitas perjudian. Favera membantu keluarga:

- mengenali perubahan finansial sejak dini;
- mengonfirmasi transaksi yang tidak biasa;
- memantau kondisi emosional dan komunikasi;
- menyusun tujuan finansial dan komitmen pemulihan;
- menjalani percakapan yang lebih netral;
- memperoleh dukungan awal berbasis AI;
- terhubung dengan tenaga profesional ketika diperlukan.

Produk menempatkan keluarga sebagai pusat dan menggabungkan konteks finansial, relasional, emosional, dan perkembangan pemulihan.

## 2. Masalah yang diselesaikan

Keluarga sering baru menyadari masalah setelah:

- pola pengeluaran berubah;
- penarikan atau transfer berulang muncul;
- kebutuhan rumah tangga berkurang;
- utang atau pinjaman meningkat;
- transaksi tidak dapat dijelaskan;
- keterbukaan dan kepercayaan menurun;
- komunikasi berubah menjadi konflik.

Layanan yang ada cenderung menangani keuangan, psikologi, keluarga, atau pelaporan secara terpisah. Favera menghubungkan pengenalan perubahan, pemantauan kondisi, dukungan komunikasi, pemulihan, dan rujukan profesional dalam satu perjalanan.

## 3. Target pengguna

Pengguna utama:

- pasangan atau keluarga terdampak judi online;
- keluarga pada tahap kesadaran awal;
- keluarga dengan risiko ringan sampai menengah;
- individu atau pasangan pada fase pemulihan awal.

Bukan target utama:

- kondisi kekerasan berat;
- risiko melukai diri atau orang lain;
- ancaman keselamatan aktif;
- perceraian aktif yang membutuhkan proses hukum;
- pengguna yang ingin mengawasi pasangan tanpa persetujuan.

Kasus di luar batas aplikasi harus diarahkan ke layanan profesional atau darurat.

## 4. Nilai inti produk

### Aman

Privasi default, consent eksplisit, pemisahan ruang pribadi dan ruang bersama, serta safety override.

### Netral

Tidak menuduh, tidak menyalahkan, tidak mendiagnosis, dan tidak mengklaim transaksi tertentu sebagai judi.

### Bertahap

Informasi dan tindakan diberikan sesuai kondisi, bukan menampilkan seluruh data dan ancaman sekaligus.

### Dapat dijelaskan

Hasil analisis menampilkan faktor dan reason code, bukan angka misterius yang diperlakukan seperti wahyu.

### Berorientasi tindakan

Setiap insight harus mengarah pada tindakan yang dapat dipilih pengguna: konfirmasi, diskusi, membuat goal, melakukan check-in, memulai pemulihan, atau mencari bantuan.

## 5. Perjalanan utama pengguna

```text
Onboarding
→ Registrasi / Login
→ Set Up Profile
→ Account Pairing dengan consent
→ Dashboard keluarga
→ Catat transaksi atau upload e-statement
→ Review dan konfirmasi hasil parsing
→ Dashboard keuangan diperbarui
→ Weekly Check-In
→ Ringkasan bersama dan Family Assessment
→ Pemantauan mandiri atau Ruang Pemulihan Bersama
→ Commitment dan follow-up
→ AI chatbot / profesional / simulasi sebagai dukungan
```

## 6. Modul produk

### A. Onboarding dan autentikasi

- tiga halaman onboarding;
- registrasi email dan password;
- login;
- lupa dan reset password;
- penyelesaian profil.

### B. Ruang keluarga

- membuat kode undangan;
- menerima atau menolak undangan;
- consent berbagi data;
- melihat status pairing;
- memutus koneksi dengan aman.

### C. Dashboard

- status kondisi keluarga;
- total saldo;
- ringkasan pemasukan dan pengeluaran;
- progress financial goal;
- pengingat weekly check-in;
- transaksi terbaru;
- akses cepat ke bantuan.

### D. Finansial

- transaksi manual pemasukan/pengeluaran;
- riwayat dan detail transaksi;
- konfirmasi transaksi tidak biasa;
- financial goals dan kontribusi;
- upload e-statement PDF/CSV;
- review hasil parsing;
- anomaly feedback.

### E. Weekly Check-In dan Family Assessment

- jawaban mentah privat;
- penyimpanan draft;
- submit individu;
- menunggu pasangan;
- ringkasan netral setelah keduanya submit;
- kondisi keluarga, tren, faktor utama, dan rekomendasi.

### F. Ruang Pemulihan Bersama

- readiness dan safety check;
- refleksi pribadi;
- draft pernyataan netral;
- tindakan berbagi eksplisit;
- respons pasangan;
- alignment;
- commitment;
- jeda, selesai, atau rekomendasi mediasi.

### G. AI Chatbot Empatik

- banyak sesi privat;
- konteks terbatas dan dipilih;
- respons terstruktur;
- safety level;
- suggested actions;
- rujukan profesional bila diperlukan.

### H. Profesional dan konsultasi

- direktori seed;
- filter berdasarkan kategori;
- tautan eksternal;
- pencatatan jadwal konsultasi;
- checklist dan catatan privat;
- konversi hasil konsultasi menjadi draft commitment.

### I. Simulasi dampak

- kalkulasi deterministik dan versioned;
- dampak finansial;
- dampak terhadap anak;
- disclaimer yang jelas;
- berbagi hanya melalui tindakan eksplisit;
- bukan prediksi atau nasihat hukum.

### J. Profil, privasi, notifikasi

- pengaturan profil;
- biometrik bila tersedia;
- hide balance;
- pengingat check-in;
- notifikasi e-statement;
- consent dan koneksi pasangan;
- kebijakan privasi;
- logout.

## 7. Target sprint enam hari

Target bukan prototipe klik kosong. Target adalah **70–80% aplikasi siap digunakan** dengan prioritas:

| Area | Target |
|---|---:|
| Screen utama dan route | 95–100% |
| Interaksi form dan state | 85–90% |
| Visual fidelity terhadap mockup | 80–90% |
| Mock API sesuai kontrak | 100% untuk feature yang dibuat |
| Integrasi public backend | 60–75% endpoint prioritas |
| Integrasi alur AI | Alur prioritas end-to-end |
| Automated test | Critical path dan repository |
| Production hardening | Fondasi, bukan final |
| Push notification nyata | Opsional |
| OAuth dan biometrik penuh | Opsional bila waktu cukup |

## 8. Scope prioritas integrasi

P0, wajib nyata bila backend siap:

1. health;
2. login/register/refresh;
3. profile dan family;
4. dashboard;
5. transaction manual;
6. statement import, polling, review, confirm;
7. current check-in, save answer, submit, summary;
8. current family assessment;
9. chat session dan message.

P1, diintegrasikan setelah P0:

- goals;
- professionals;
- simulations;
- recovery session;
- commitments;
- notifications.

P2, dapat tetap mock pada akhir sprint:

- consultation notes dan conversion;
- device push token;
- seluruh edge case penghapusan;
- OAuth;
- biometrik production.

## 9. Batasan AI

AI dipakai untuk:

- parsing dan normalisasi e-statement;
- feature engineering;
- anomaly assessment;
- ringkasan check-in;
- family risk assessment;
- rewrite pernyataan netral;
- alignment;
- chatbot empatik.

AI tidak boleh:

- menetapkan transaksi sebagai judi;
- memberi diagnosis;
- menentukan pihak bersalah;
- mengubah consent;
- mengubah commitment;
- menentukan keputusan hubungan;
- menjadi satu-satunya jalur keselamatan.

## 10. Privasi default

| Data | Default |
|---|---|
| File e-statement asli | Privat bagi pengunggah |
| Draft parsing | Privat bagi pengunggah |
| Transaksi terkonfirmasi | Dibagikan setelah consent |
| Jawaban check-in mentah | Privat |
| Ringkasan check-in | Bersama setelah dua pihak submit |
| Chat dan memory | Privat |
| Refleksi pemulihan | Privat |
| Pernyataan pemulihan | Bersama setelah publish eksplisit |
| Goal dan commitment | Bersama |
| Jadwal konsultasi | Privat, dapat dibagikan |
| Catatan konsultasi | Privat, dapat dibagikan per catatan |
| Simulasi dampak | Privat, dapat dibagikan |

## 11. Terminologi produk

| Gunakan | Hindari |
|---|---|
| transaksi tidak biasa | transaksi judi |
| memerlukan konfirmasi | terbukti mencurigakan |
| tingkat perhatian | probabilitas bersalah |
| kondisi keluarga | diagnosis hubungan |
| bahan refleksi | prediksi perceraian |
| dukungan awal | terapi AI |
| tenaga profesional | pengganti aplikasi |
| ruang keluarga | monitoring pasangan |
| berbagi dengan persetujuan | akses otomatis pasangan |

## 12. Definisi keberhasilan demo

Demo dianggap berhasil bila pengguna dapat:

1. masuk sebagai akun seed;
2. melihat dashboard;
3. menambah transaksi;
4. upload contoh e-statement;
5. melihat status parsing;
6. memvalidasi transaksi;
7. melihat dashboard berubah;
8. melakukan weekly check-in;
9. melihat family assessment;
10. membuka chatbot dan menerima respons;
11. melihat profesional dan simulasi;
12. membuka pengaturan tanpa route rusak.

Semua langkah harus dapat dilakukan tanpa restart aplikasi dan tanpa mengubah fixture secara manual.
