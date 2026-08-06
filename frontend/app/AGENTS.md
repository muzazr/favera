# Favera Frontend Agent Guide

## 1. Misi

Bangun frontend Flutter Favera hingga tingkat kesiapan **70–80%** dalam sprint enam hari.

Hasil akhir harus:

1. menjalankan seluruh perjalanan utama tanpa dead end;
2. memakai mock API stateful dengan bentuk data yang sama dengan public API;
3. dapat beralih ke backend nyata tanpa mengubah UI atau controller;
4. mengintegrasikan alur frontend–backend–AI yang diprioritaskan;
5. layak direkam untuk demonstrasi GEMASTIK;
6. tetap aman, netral, dan tidak menghakimi pengguna.

Jangan mengejar arsitektur sempurna sambil membiarkan tombol tidak bekerja. Manusia sudah cukup sering melakukan itu.

## 2. Urutan bacaan wajib

Baca sebelum mengubah kode:

1. `docs/PROJECT_CONTEXT.md`
2. `docs/FRONTEND_ARCHITECTURE.md`
3. `docs/DESIGN_BRIEF.md`
4. `docs/API_CONTRACT_AND_MOCKING.md`
5. `docs/ENGINEERING_RULES.md`
6. part aktif pada `docs/WORK_PARTS.md`
7. `docs/DEMO_SCENARIO.md` ketika menyentuh fixture atau alur demo

Untuk perencanaan sprint, baca `docs/SPRINT_6_DAY_EXECUTION.md`.

## 3. Source of truth

Urutan otoritas ketika materi berbeda:

1. `favera-public-api-v0.1.openapi.json` untuk Flutter ↔ Express.
2. `favera-ai-service-v0.1.openapi.json` untuk Express ↔ FastAPI.
3. `README-contract-decisions.md` untuk keputusan lintas sistem dan privasi.
4. `docs/*.md` dalam context pack ini untuk keputusan frontend.
5. Proposal Favera untuk tujuan produk, batasan etika, dan perjalanan pengguna.
6. Mockup `UI SO FAR.pdf` untuk visual dan komposisi layar.

Flutter **hanya** memanggil public API Express. Flutter tidak boleh memanggil FastAPI internal, Gemini, PostgreSQL, Supabase Database, atau Supabase Storage secara langsung.

## 4. Keputusan teknis terkunci

- Framework: Flutter.
- State management dan dependency injection: Riverpod.
- Navigation: `go_router`.
- HTTP: Dio.
- Serialization: `json_annotation` dan `json_serializable`.
- File selection: `file_picker`.
- Token storage: `flutter_secure_storage`.
- Non-sensitive preference: `shared_preferences`.
- Format uang/tanggal: `intl`.
- SVG: `flutter_svg`.
- External contact links: `url_launcher`.
- Struktur: feature-first dengan lapisan `presentation`, `application`, dan `data`.
- Money: integer rupiah, currency `IDR`.
- API fields: `snake_case`.
- Date-time: ISO 8601 UTC pada transport.
- Pagination: cursor.
- ID: UUID.
- Mock dan remote wajib mengimplementasikan repository contract yang sama.

Jangan menambah package tanpa alasan yang dicatat pada ringkasan part.

## 5. Mode data

Aplikasi harus mendukung:

```text
mock   = seluruh repository memakai mock stateful
remote = seluruh repository memakai public API nyata
hybrid = repository tertentu remote, sisanya mock
```

Gunakan `--dart-define` atau konfigurasi environment terpusat. Jangan menyebar pengecekan mode ke widget.

Contoh:

```bash
flutter run --dart-define=APP_MODE=mock
flutter run --dart-define=APP_MODE=hybrid
flutter run --dart-define=APP_MODE=remote
```

## 6. Aturan produk yang tidak boleh dilanggar

- Jangan menyatakan transaksi sebagai bukti judi online.
- Gunakan istilah “transaksi tidak biasa”, “memerlukan perhatian”, atau “perlu konfirmasi”.
- Jangan memberikan diagnosis psikologis.
- Jangan menentukan pihak yang bersalah.
- Jangan memprediksi atau merekomendasikan perceraian.
- Data privat tidak boleh terlihat oleh pasangan tanpa tindakan berbagi yang eksplisit.
- Jawaban mentah weekly check-in tetap privat.
- Chatbot, chat memory, refleksi pribadi, dan file e-statement asli bersifat privat.
- Safety signal harus mengutamakan arahan ke bantuan profesional dan menghentikan alur mediasi yang tidak aman.
- AI tidak boleh mengubah score, commitment, consent, atau workflow secara sepihak.

## 7. Protokol pengerjaan part

Untuk setiap part:

1. Baca objective, dependency, scope, dan acceptance criteria.
2. Inspeksi kode yang sudah ada sebelum membuat struktur baru.
3. Tulis rencana singkat.
4. Implementasikan hanya scope part.
5. Jalankan formatter, analyzer, dan test terkait.
6. Periksa navigasi manual pada route yang diubah.
7. Laporkan:
   - file yang berubah;
   - keputusan penting;
   - hasil verifikasi;
   - sisa risiko atau TODO;
   - apakah acceptance criteria terpenuhi.
8. Berhenti. Jangan masuk part berikutnya tanpa instruksi.

## 8. Definition of Done global

Sebuah feature selesai ketika:

- route dapat dibuka dan kembali dengan benar;
- loading, success, empty, dan error state yang relevan tersedia;
- mock menghasilkan response sesuai kontrak;
- remote repository memakai endpoint public API yang benar;
- widget tidak mengetahui sumber data mock atau remote;
- tidak ada overflow pada ukuran ponsel umum;
- copy aman dan netral;
- `flutter analyze` tidak menghasilkan error;
- test kritis lulus;
- alur dapat digunakan dalam skenario demo.

## 9. Perintah minimum

Sesuaikan bila repository memiliki wrapper sendiri.

```bash
dart format .
flutter pub get
flutter analyze
flutter test
```

Sebelum milestone demo:

```bash
flutter test integration_test
flutter build apk --debug
```

## 10. Larangan

- Jangan mengubah route atau schema API diam-diam.
- Jangan membuat endpoint frontend baru yang tidak ada di public contract.
- Jangan mengakses internal AI service dari Flutter.
- Jangan menaruh token di `shared_preferences`.
- Jangan menaruh business logic di widget.
- Jangan menyimpan `document_password`.
- Jangan menambahkan microservice, local database besar, atau abstraction layer baru tanpa kebutuhan nyata.
- Jangan mengganti desain utama dengan template generik.
- Jangan menulis data sensitif ke log.
- Jangan membuat tombol dekoratif yang tampak aktif tetapi tidak melakukan apa-apa.
