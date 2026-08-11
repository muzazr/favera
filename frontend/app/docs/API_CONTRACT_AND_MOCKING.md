# API Contract, Mocking, and Integration

## 1. Status kontrak

Berkas berikut diperlakukan sebagai **kontrak final baseline untuk sprint frontend**:

- `favera-public-api-v0.1.openapi.json`
- `favera-ai-service-v0.1.openapi.json`
- `README-contract-decisions.md`

Nama versi tetap `v0.1`, tetapi frontend tidak boleh menganggap route atau schema sebagai placeholder. Perubahan membutuhkan keputusan eksplisit tim dan pembaruan kontrak.

## 2. Service boundary

```text
Flutter
  |
  | public HTTPS REST
  v
Express.js
  |
  | private HTTP
  v
FastAPI AI Service
```

Flutter hanya mengonsumsi public API.

Dilarang:

- memanggil `/internal/v1/*`;
- memanggil Gemini langsung;
- membaca atau menulis Supabase langsung;
- mengunggah file langsung ke storage tanpa flow backend;
- meniru internal score di frontend.

## 3. Konvensi transport

- base path: `/` (pada live backend `https://favera-backend.vercel.app`);
- ID: UUID;
- field: `snake_case`;
- date-time: ISO 8601 UTC;
- date: `YYYY-MM-DD`;
- money: integer rupiah;
- currency: `IDR`;
- pagination: cursor;
- auth: bearer token;
- upload awal: maksimum 10 MB;
- invitation expiry: 24 jam;
- raw statement retention awal: 30 hari, configurable;
- write request yang rawan retry: `Idempotency-Key`.

## 4. Endpoint groups

### System

```text
GET /health
```

### Auth and user

```text
POST /auth/register
POST /auth/login
POST /auth/refresh
POST /auth/logout
POST /auth/forgot-password
POST /auth/reset-password
GET  /me
PATCH /me
POST /me/onboarding
```

### Family

```text
GET    /family
POST   /family/invitations
GET    /family/invitations
POST   /family/invitations/{invite_code}/accept
POST   /family/invitations/{invite_code}/reject
DELETE /family/invitations/{invitation_id}
PATCH  /family/settings
POST   /family/consents
POST   /family/disconnect
```

### Dashboard and transaction

```text
GET    /dashboard
GET    /transactions
POST   /transactions
GET    /transactions/{transaction_id}
PATCH  /transactions/{transaction_id}
DELETE /transactions/{transaction_id}
POST   /transactions/{transaction_id}/confirmation
POST   /transactions/{transaction_id}/feedback
```

### E-statement

```text
GET    /statement-imports
POST   /statement-imports
GET    /statement-imports/{statement_import_id}
DELETE /statement-imports/{statement_import_id}
POST   /statement-imports/{statement_import_id}/unlock
GET    /statement-imports/{statement_import_id}/draft-transactions
PATCH  /statement-imports/{statement_import_id}/draft-transactions/{draft_transaction_id}
POST   /statement-imports/{statement_import_id}/confirm
```

### Goals

```text
GET   /goals
POST  /goals
GET   /goals/{goal_id}
PATCH /goals/{goal_id}
POST  /goals/{goal_id}/approval
POST  /goals/{goal_id}/contributions
```

### Check-in and assessment

```text
GET  /check-ins/current
GET  /check-ins
GET  /check-ins/{checkin_id}
PUT  /check-ins/{checkin_id}/answers
POST /check-ins/{checkin_id}/submit
GET  /check-ins/{checkin_id}/summary
GET  /family-assessments/current
GET  /family-assessments
```

### Recovery and commitments

```text
GET  /recovery-sessions
POST /recovery-sessions
GET  /recovery-sessions/{recovery_session_id}
POST /recovery-sessions/{recovery_session_id}/readiness
PUT  /recovery-sessions/{recovery_session_id}/reflection
POST /recovery-sessions/{recovery_session_id}/statement-draft
POST /recovery-sessions/{recovery_session_id}/publish-statement
POST /recovery-sessions/{recovery_session_id}/partner-response
GET  /recovery-sessions/{recovery_session_id}/alignment
POST /recovery-sessions/{recovery_session_id}/pause
POST /recovery-sessions/{recovery_session_id}/complete

GET   /commitments
POST  /commitments
GET   /commitments/{commitment_id}
PATCH /commitments/{commitment_id}
POST  /commitments/{commitment_id}/approval
POST  /commitments/{commitment_id}/progress
POST  /commitments/{commitment_id}/complete
```

### Chat

```text
GET    /chat/sessions
POST   /chat/sessions
GET    /chat/sessions/{chat_session_id}
DELETE /chat/sessions/{chat_session_id}
GET    /chat/sessions/{chat_session_id}/messages
POST   /chat/sessions/{chat_session_id}/messages
```

### Professional, consultation, simulation

```text
GET /professionals
GET /professionals/{professional_id}

GET   /consultations
POST  /consultations
GET   /consultations/{consultation_id}
PATCH /consultations/{consultation_id}
PUT   /consultations/{consultation_id}/checklist
POST  /consultations/{consultation_id}/notes
POST  /consultations/{consultation_id}/convert-to-commitment

GET  /simulations
POST /simulations
GET  /simulations/{simulation_id}
POST /simulations/{simulation_id}/share
```

### Notification

```text
GET  /notifications
POST /notifications/{notification_id}/read
POST /devices
```

## 5. Prinsip mock API

Mock bukan kumpulan JSON yang selalu mengembalikan hal sama. Mock harus menjadi **backend stateful kecil** yang:

- memakai model yang sama dengan public API;
- mengubah state setelah mutation;
- mendukung deterministic seed;
- mensimulasikan latency;
- dapat mensimulasikan error;
- mempunyai reset scenario;
- menjaga privacy behavior;
- mendukung status async seperti parsing;
- tidak memerlukan perubahan widget saat diganti remote.

## 6. Struktur mock

```text
lib/mock/
├── mock_backend.dart
├── mock_store.dart
├── mock_clock.dart
├── mock_latency.dart
├── mock_error_policy.dart
├── mock_scenario.dart
└── fixtures/
    ├── users.json
    ├── families.json
    ├── dashboard.json
    ├── transactions.json
    ├── statement_imports.json
    ├── statement_drafts.json
    ├── goals.json
    ├── checkins.json
    ├── assessments.json
    ├── recovery.json
    ├── commitments.json
    ├── chat.json
    ├── professionals.json
    ├── consultations.json
    ├── simulations.json
    └── notifications.json
```

`MockStore` adalah sumber state. Repository mock tidak menyimpan copy sendiri.

```dart
class MockStore {
  User? currentUser;
  FamilySpace? family;
  final Map<String, Transaction> transactions = {};
  final Map<String, StatementImport> statementImports = {};
  final Map<String, ParsedTransactionDraft> statementDrafts = {};
  final Map<String, FinancialGoal> goals = {};
  final Map<String, WeeklyCheckIn> checkIns = {};
  final Map<String, FamilyAssessment> assessments = {};
  final Map<String, RecoverySession> recoverySessions = {};
  final Map<String, Commitment> commitments = {};
  final Map<String, ChatSession> chatSessions = {};
  final Map<String, List<ChatMessage>> chatMessages = {};
}
```

## 7. Mock clock

Jangan memakai `DateTime.now()` di fixture dan logic mock secara langsung. Gunakan clock terinjeksi agar demo tetap deterministik.

```dart
abstract interface class AppClock {
  DateTime now();
}
```

Mock scenario menggunakan tanggal tetap atau offset yang konsisten.

## 8. Skenario mock wajib

### A. Happy path

- user login;
- family aktif;
- dashboard stabil;
- statement berhasil;
- dua transaksi perlu review;
- check-in partner sudah submit;
- AI chat memberi respons normal.

### B. PDF password required

- upload Mandiri;
- status `password_required`;
- wrong password sekali;
- unlock berhasil;
- status berlanjut ke `parsing` lalu `review_required`.

### C. Parsing failed

- unsupported format atau parsing error;
- error dapat di-retry;
- file dapat dibatalkan.

### D. Family needs attention

- beberapa anomaly;
- budget gap;
- stress meningkat;
- assessment `needs_attention`;
- action menuju recovery atau professional.

### E. Safety

- safety signal;
- assessment `safety_support_required`;
- mediasi normal dibatasi;
- arahkan ke bantuan profesional/darurat;
- tidak ada respons AI generik yang meremehkan kondisi.

## 9. Status machine penting

### Statement import

```text
uploaded
→ password_required
→ parsing
→ review_required
→ confirmed

terminal:
failed
cancelled
```

Status legal lain:

```text
uploaded → parsing
password_required → parsing
review_required → cancelled
```

Jangan membuat status frontend di luar kontrak sebagai transport value. UI internal boleh memiliki state presentasi tambahan.

### Parsed transaction

```text
pending → validated
pending → deleted
validated → pending
deleted → pending
```

### Goal

```text
draft
→ pending_partner_approval
→ active
→ completed

terminal/alternate:
cancelled
```

### Weekly check-in

```text
open
→ waiting_for_partner
→ processing
→ completed

alternate:
expired
```

Submission individu:

```text
not_started → draft → submitted
```

### Recovery session

```text
DRAFT
→ READINESS_CHECK
→ PRIVATE_REFLECTION
→ WAITING_FOR_PARTNER
→ PARTNER_RESPONSE
→ ALIGNMENT
→ COMMITMENT_DRAFT
→ COMMITMENT_ACTIVE
→ FOLLOW_UP
→ COMPLETED
```

Alternate:

```text
MEDIATION_RECOMMENDED
PAUSED
```

### Commitment

```text
draft
→ pending_partner_approval
→ active
→ completed

alternate:
overdue
revised
cancelled
```

## 10. Statement mock behavior

Contoh sumber dokumen:

- Mandiri;
- BRI;
- GoPay.

Mock upload tidak harus membaca PDF secara lokal. File picker memastikan user memilih file yang valid, lalu mock repository memilih fixture berdasarkan:

1. provider hint;
2. file name;
3. active mock scenario.

Simulasi:

```text
POST upload
→ return StatementImport(status=uploaded)
→ after latency status=parsing
→ after latency status=review_required
→ drafts available
```

Saat confirm:

1. draft `validated` menjadi canonical transaction;
2. draft `deleted` diabaikan;
3. dashboard balance dan recent transaction berubah;
4. transaction anomaly summary tersedia;
5. import menjadi `confirmed`.

## 11. Mock chat behavior

Mock chat harus stateful:

- buat session;
- simpan user message;
- tambahkan assistant response;
- respons berdasarkan intent sederhana;
- memiliki safety trigger phrase untuk test;
- tidak mengklaim diagnosis;
- mengembalikan `suggested_actions`;
- memperbarui memory summary secara terbatas.

Jangan hard-code satu jawaban untuk semua pesan.

## 12. Mock check-in behavior

- save answers memperbarui `my_answers`;
- status berubah menjadi `draft`;
- submit mengubah status individu menjadi `submitted`;
- bila partner seed sudah submitted:
  - check-in menjadi `processing`;
  - setelah latency menjadi `completed`;
  - summary tersedia;
  - family assessment dibuat;
  - dashboard status dapat berubah.

Raw partner answers tidak boleh ditampilkan.

## 13. Mock mutation fidelity

Setiap mutation harus mengubah query berikutnya.

Contoh:

```text
POST /transactions
→ GET /transactions memuat item baru
→ GET /dashboard memperbarui recent transaction dan total
```

```text
POST /goals
→ GET /goals memuat pending goal
→ POST /approval
→ GET /dashboard memuat active goal
```

Tanpa fidelity ini, demo cuma teater tombol. Sedikit terlalu dekat dengan sebagian besar software enterprise.

## 14. Remote repository

Remote repository:

- memakai DTO sesuai OpenAPI;
- mapping error terpusat;
- tidak memperbaiki response backend diam-diam;
- mempertahankan `request_id`;
- melakukan cancellation untuk polling;
- refresh token satu kali ketika 401;
- tidak membuat infinite refresh loop;
- tidak log body sensitif;
- mengirim multipart dengan field persis sesuai contract.

## 15. Integrasi bertahap

### Tahap 1

Mock semua feature dan selesaikan UI.

### Tahap 2

Ganti per domain ke remote melalui config:

```text
health
auth
me
family
dashboard
transactions
```

### Tahap 3

Integrasikan statement:

```text
upload
poll
unlock
review
confirm
```

### Tahap 4

Integrasikan AI-backed public flows:

```text
check-in summary
family assessment
chat
recovery rewrite/alignment
```

Flutter tetap hanya melihat public response.

## 16. Contract test

Minimal contract test frontend:

- fixture dapat di-deserialize ke DTO;
- enum sesuai;
- required field tidak hilang;
- money tetap integer;
- response list membaca cursor;
- error response dipetakan;
- multipart field name tepat;
- endpoint path tidak typo.

Simpan contoh response dari backend staging sebagai fixture contract ketika tersedia.

## 17. Endpoint priority matrix

| Group | Priority | Akhir sprint |
|---|---|---|
| health | P0 | Remote |
| auth/me | P0 | Remote |
| family | P0 | Remote atau hybrid stabil |
| dashboard | P0 | Remote |
| transactions | P0 | Remote |
| statement imports | P0 | Remote end-to-end |
| check-ins | P0 | Remote untuk happy path |
| assessments | P0 | Remote |
| chat | P0 | Remote |
| goals | P1 | Remote bila stabil |
| professionals | P1 | Mock atau remote seed |
| simulations | P1 | Remote bila formula siap |
| recovery | P1 | Hybrid |
| commitments | P1 | Hybrid |
| consultations | P2 | Mock |
| notifications/devices | P2 | Mock |

## 18. Integration readiness checklist

- base URL environment tersedia;
- CORS/mobile networking benar;
- staging account tersedia;
- token refresh diuji;
- file upload ukuran nyata diuji;
- contoh PDF Mandiri terkunci diuji;
- status polling backend konsisten;
- empty list tidak dianggap error;
- enum backend cocok;
- request/response timestamp cocok;
- error includes request_id;
- AI timeout mempunyai state yang ramah;
- safety response diuji;
- fallback mock hanya aktif di build yang diizinkan;
- demo build dapat dipaksa ke mock bila staging bermasalah.

## 19. Keamanan

- `document_password` write-only dan ephemeral;
- jangan simpan password di state persisten;
- hapus password dari memory setelah request selesai sejauh memungkinkan;
- token hanya secure storage;
- redact log;
- private data tidak di-cache ke disk tanpa keputusan eksplisit;
- logout membersihkan token dan private in-memory state;
- disconnect mencabut akses baru, tidak menghapus histori secara otomatis;
- UI harus menjelaskan tindakan berbagi.
