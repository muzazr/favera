# Flutter Engineering Rules

- Gunakan feature-first: presentation, application, data.
- Gunakan Riverpod, go_router, Dio, dan json_serializable.
- Widget tidak memanggil Dio.
- Controller tidak menyimpan endpoint string.
- Repository memilih mock atau remote melalui provider root.
- Money selalu integer rupiah.
- Date-time transport ISO 8601 UTC.
- Token hanya di secure storage.
- Gunakan immutable state dan explicit state machine untuk flow panjang.
- Jalankan format, analyze, dan tests sebelum handoff.
- Jangan menambah package atau abstraction tanpa alasan.
