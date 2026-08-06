# API, Privacy, and Safety Rules

- Gunakan hanya public API `/api/v1`.
- Dilarang memanggil `/internal/v1/*`.
- Ikuti field, enum, status code, dan schema OpenAPI.
- `document_password` ephemeral, tidak disimpan atau dilog.
- Raw e-statement, check-in answer, chat, reflection, dan notes tidak boleh dilog.
- Jawaban check-in mentah privat.
- Chat dan memory privat.
- Sharing memerlukan tindakan eksplisit.
- AI tidak mengubah risk score, consent, commitment, atau workflow.
- Safety signal mengalahkan flow normal dan mengarahkan ke bantuan profesional.
- Simulasi selalu menampilkan disclaimer.
