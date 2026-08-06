# Engineering Rules

## 1. Prioritas

Urutan prioritas:

1. keamanan dan privasi;
2. correctness terhadap kontrak;
3. alur utama dapat digunakan;
4. kejelasan UI;
5. visual fidelity;
6. optimasi;
7. abstraksi tambahan.

Jangan mengorbankan tiga hal pertama demi animasi yang menggemaskan. Keluarga pengguna tidak sedang mengaudit easing curve.

## 2. Aturan arsitektur

- Feature tidak boleh mengimpor implementation internal feature lain.
- Shared model hanya untuk konsep lintas feature yang benar-benar sama.
- Widget memanggil controller/provider, bukan Dio.
- Controller memanggil repository, bukan endpoint string.
- Repository remote memanggil typed API.
- Repository mock memakai `MockStore`.
- Data source dipilih pada composition root.
- Business logic tidak berada dalam callback widget besar.
- Hindari global mutable singleton.
- Gunakan immutable state.
- Satu file sebaiknya mempunyai satu tanggung jawab utama.
- Jangan membuat interface untuk class yang tidak membutuhkan variasi, kecuali repository boundary.

## 3. Naming

- file: `snake_case.dart`;
- class: `UpperCamelCase`;
- variable/function: `lowerCamelCase`;
- route name: semantic, tidak mengikuti title visual;
- DTO dapat memakai suffix `Dto` bila dipisahkan dari app model;
- provider memakai suffix `Provider`;
- controller memakai suffix `Controller`;
- state memakai suffix `State`;
- mock fixture ID stabil dan mudah dicari.

## 4. Nullability

- Jangan menggunakan `!` kecuali ada invariant yang jelas.
- Mapping API harus menangani nullable sesuai contract.
- Unknown/null state harus menghasilkan UI yang aman.
- Jangan mengganti null menjadi angka nol bila maknanya berbeda.

## 5. Money dan date

- Money selalu `int`.
- Format rupiah melalui formatter terpusat.
- Jangan simpan string rupiah sebagai model.
- Date-time transport UTC.
- Tampilkan waktu lokal pengguna.
- Date-only tidak boleh terkena timezone shift.
- Deadline goal memakai date-only.
- Gunakan clock terinjeksi untuk test/mock.

## 6. API

- Path dan field harus sesuai public OpenAPI.
- Jangan memanggil internal API.
- Jangan menambah field request “agar gampang” tanpa contract update.
- Error status dipetakan secara eksplisit.
- 401 memicu refresh hanya satu kali.
- 403 bukan 401.
- 409 tampil sebagai conflict, bukan generic error.
- 422 tampil pada field terkait.
- 202 berarti asynchronous, bukan sukses final.
- 204 tidak memiliki body.
- Gunakan cursor pagination.
- Gunakan idempotency key ketika mutation berisiko diulang.
- Batalkan polling ketika page dispose.
- Jangan retry mutation secara buta.

## 7. Privacy

Dilarang mencatat ke console/log:

- password;
- token;
- raw e-statement;
- document password;
- transaction description lengkap pada production;
- check-in answers;
- chat content;
- reflections;
- consultation notes;
- safety details.

Gunakan redacted metadata:

```text
request_id
endpoint
status
duration
record_count
file_size
provider
```

## 8. Product safety

- Copy tidak menghakimi.
- Anomaly bukan bukti judi.
- Family assessment bukan diagnosis.
- Simulasi bukan prediksi.
- AI chatbot bukan psikolog.
- Safety signal selalu diprioritaskan.
- Jangan mendorong percakapan pasangan ketika readiness menyatakan tidak aman.
- Tampilkan jalur bantuan profesional.
- Jangan menyembunyikan disclaimer.
- Jangan membuat gamification pada safety event.

## 9. UI

- Gunakan design token, bukan warna literal tersebar.
- Reusable component untuk button, input, card, chip, status, transaction row, error state.
- Jangan membuat universal widget dengan 30 parameter.
- Setiap screen harus scroll aman.
- Periksa keyboard.
- Periksa text scale.
- Periksa rupiah besar.
- Tap target minimum 44.
- Semua icon-only action memiliki tooltip/semantic label.
- Destructive action memiliki confirm dialog.
- Loading tidak menghilangkan input.
- Tombol disabled menjelaskan requirement bila tidak jelas.

## 10. Navigation

- Tidak ada dead end.
- Back behavior konsisten.
- Root tab mempertahankan state penting.
- Deep route dapat dibuka dengan data loading.
- Route guard terpusat.
- Jangan melakukan navigation dari repository.
- Side effect navigation dari controller harus melalui event/state yang jelas.

## 11. Form

- Validasi lokal untuk requirement dasar.
- Error server dipetakan ke field.
- Jangan menghapus input setelah error.
- Submit button mencegah double submit.
- Password visibility toggle.
- Amount parser tahan paste dan separator.
- File validation sebelum upload.
- Consent checkbox wajib untuk aksi yang membutuhkannya.

## 12. Mock

- Response sama dengan contract.
- Mutation mengubah state.
- Seed deterministik.
- Latency realistis tetapi singkat.
- Error dapat dipilih lewat scenario, bukan random pada demo.
- Reset scenario tersedia.
- Mock tidak boleh menyembunyikan bug serialization.
- Jangan membuat model khusus mock yang tidak ada di app.

## 13. Testing

Setiap part minimal:

- unit test untuk mapper/controller yang punya logic;
- widget smoke test untuk page baru;
- update integration test bila part menyentuh demo path.

Critical assertions:

- route reachable;
- state transition benar;
- privacy visibility benar;
- error tidak menghapus input;
- amount integer;
- safety action muncul saat signal;
- mock mutation reflected pada query.

## 14. Lint dan format

Sebelum part selesai:

```bash
dart format .
flutter analyze
flutter test
```

Tidak boleh meninggalkan:

- analyzer error;
- ignored lint tanpa alasan;
- commented-out code besar;
- debug print sensitif;
- TODO tanpa owner/context;
- unused asset;
- route tidak terpakai.

## 15. Git discipline

Rekomendasi commit:

```text
feat(auth): implement login and token refresh
feat(statement): add upload review flow
test(checkin): cover submit and summary state
fix(ui): prevent goal amount overflow
```

Satu part boleh memiliki beberapa commit logis. Jangan membuat satu commit enam hari bernama `finalfix2`.

## 16. Handoff part

Ringkasan wajib:

```markdown
## Part Summary

### Implemented
- ...

### Changed Files
- ...

### Contract Used
- ...

### Verification
- `flutter analyze`: pass
- `flutter test ...`: pass
- manual route: pass

### Remaining
- ...

### Risks
- ...
```

## 17. Definition of Done per screen

- route terdaftar;
- loading/data/empty/error sesuai kebutuhan;
- semantics dasar;
- tidak overflow;
- mengikuti design brief;
- action utama bekerja;
- mock dan remote path tersedia bila masuk scope;
- test smoke;
- copy netral;
- privacy benar.

## 18. Definition of Done per feature

- repository contract;
- mock implementation;
- remote implementation atau explicit planned status;
- controller;
- pages;
- reusable widgets;
- route;
- error mapping;
- tests;
- demo fixture;
- documentation bila behavior tidak jelas.
