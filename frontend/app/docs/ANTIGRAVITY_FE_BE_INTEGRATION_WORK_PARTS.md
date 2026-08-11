# ANTIGRAVITY — Favera FE↔BE Integration Work Parts

> **Status: EXECUTION BRIEF**
>
> Kerjakan integrasi berdasarkan `ANTIGRAVITY_ENDPOINT_SOURCE_OF_TRUTH.md`.
> Jangan memakai brief lama sebagai contract aktif. Brief lama hanya boleh membantu memahami maksud UI/flow.

## Objective

Mengganti mock/hard-coded frontend secara bertahap dengan data dan mutation dari Express backend Favera tanpa merusak UI yang sudah ada, tanpa mengubah privacy/safety semantics, dan tanpa membuat endpoint yang tidak ada.

## Definition of Done global

Suatu work part dianggap selesai hanya jika:

- call memakai base URL/config terpusat;
- request/response sesuai current contract;
- protected endpoint memakai bearer token;
- loading/success/error/empty state ditangani;
- mock untuk flow tersebut tidak lagi menjadi source data production;
- tidak ada double-submit mutation;
- DTO parsing aman terhadap nullable/unknown enum yang realistis;
- UI existing tetap usable;
- ada smoke test atau minimal integration test/manual verification;
- tidak ada call ke endpoint yang sudah removed;
- error backend tidak disamarkan menjadi fake success.

---

# Part 0 — Contract Reset & Existing FE Audit

## Objective

Mencegah Antigravity meneruskan asumsi dari brief/contract lama.

## Tasks

1. Baca `ANTIGRAVITY_ENDPOINT_SOURCE_OF_TRUTH.md` sampai selesai.
2. Inventaris seluruh API client/repository/provider/controller yang sudah ada.
3. Cari semua hard-coded base URL.
4. Cari semua mock repository/provider/data source.
5. Cari seluruh path string yang mengandung:
   - `/check-ins/`
   - `/family-assessments`
   - `/recovery-sessions`
   - `/simulations`
   - `/notifications`
   - `/devices`
6. Tandai call yang menuju endpoint removed.
7. Cari enum transaction direction yang masih hanya `income/expense/transfer`.
8. Buat daftar screen → controller/provider → repository → endpoint.
9. Jangan refactor besar sebelum audit selesai.

## Acceptance

- satu base URL strategy teridentifikasi;
- seluruh call endpoint lama/removed terdaftar;
- lokasi mock source diketahui;
- integration map FE existing tersedia;
- tidak ada route baru dibuat pada part ini.

---

# Part 1 — HTTP Foundation, Environment, Error & Token Handling

## Objective

Membuat satu jalur HTTP yang stabil untuk seluruh feature.

## Endpoints

```text
GET  /health
POST /auth/refresh
```

## Tasks

1. Set environment base:
   `https://favera-backend.vercel.app/api/v1`
2. Pastikan Dio/API client hanya dibuat lewat dependency injection/config existing.
3. Tambahkan bearer token interceptor.
4. Implement refresh-token flow satu kali per failed request.
5. Cegah refresh recursion/infinite retry.
6. Standarkan decoding error backend.
7. Handle `204` tanpa JSON decode.
8. Tambahkan timeout yang masuk akal dan log debug yang tidak membocorkan token/password.
9. Smoke test `/health`.

## Acceptance

- `/health` sukses;
- access token otomatis terpasang;
- expired access token bisa direfresh;
- refresh gagal mengakhiri session dengan bersih;
- tidak ada token/password di log.

---

# Part 2 — Auth, User Profile & Onboarding

## Endpoints

```text
POST  /auth/register
POST  /auth/login
POST  /auth/logout
POST  /auth/forgot-password
POST  /auth/reset-password
GET   /me
PATCH /me
POST  /me/onboarding
```

## Tasks

1. Hubungkan existing login/register UI.
2. Persist access + refresh token dengan storage strategy existing yang aman.
3. Setelah login/register, hydrate user dari response dan/atau `/me`.
4. Routing awal harus mempertimbangkan:
   - authenticated?
   - `onboarding_completed`?
   - `family_id` ada/tidak?
5. Integrasikan edit profile.
6. Integrasikan logout, lalu clear seluruh user-scoped cache/provider.
7. Jangan menganggap forgot/reset password flow selesai jika backend error.

## Acceptance

- register/login menghasilkan session real;
- reload app mempertahankan session sesuai strategy;
- onboarding status menentukan routing;
- logout membersihkan state;
- tidak ada fake auth success.

---

# Part 3 — Family Space, Pairing, Consent & Disconnect

## Endpoints

```text
GET    /family
GET    /family/invitations
POST   /family/invitations
POST   /family/invitations/{invite_code}/accept
POST   /family/invitations/{invite_code}/reject
DELETE /family/invitations/{invitation_id}
PATCH  /family/settings
POST   /family/consents
POST   /family/disconnect
```

## Tasks

1. Integrasikan "Hubungkan Akun" ke invitation API.
2. Render state `unpaired`, `pending_pairing`, `active`, `disconnected`.
3. Jangan membuka shared family UI seolah aktif sebelum backend mengembalikan family state yang sesuai.
4. Accept invitation harus mengirim consent request contract yang diperlukan.
5. Revoke/reject harus update state tanpa membuat local family palsu.
6. Disconnect harus dianggap destructive session/family transition.
7. Refresh `/me` + `/family` setelah pairing/disconnect mutation.

## Acceptance

- dua arah pairing flow bisa direpresentasikan;
- invite status benar;
- consent tidak dilewati;
- family screen berasal dari backend;
- disconnect menghapus akses shared state di FE.

---

# Part 4 — Dashboard & Canonical Transactions

## Endpoints

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

## Critical change

Current transaction `direction`:

```text
income
expense
transfer
debt_increase
debt_payment
```

Jangan memakai DTO enum lama.

`GET /transactions?direction=` masih hanya mendeklarasikan tiga filter lama. Jangan kirim `debt_increase` / `debt_payment` sebagai query filter sampai backend menegaskan dukungan.

## Tasks

1. Ganti home/finance dashboard mock dengan `/dashboard`.
2. Map total balance, totals, goals, recent transactions, family status.
3. Integrasikan transaction list dengan cursor pagination.
4. Integrasikan manual create income/expense/debt flow sesuai enum contract.
5. Integrasikan detail/edit/archive.
6. Integrasikan confirmation/clarification.
7. Integrasikan anomaly feedback.
8. Nominal harus integer IDR.
9. Setelah mutation, invalidate/refetch resource yang benar, bukan seluruh app tanpa alasan.

## Acceptance

- dashboard dan transaction history memakai data real;
- add/edit/archive berfungsi;
- 5 direction value dapat diparse;
- anomaly/confirmation state tampil sesuai backend;
- pagination tidak memakai page-number palsu.

---

# Part 5 — E-Statement Async Import Pipeline

## Endpoints

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

## Objective

Mengintegrasikan upload → parsing → review → confirm tanpa berpura-pura request `202` sudah selesai.

## State machine

```text
uploaded
→ password_required OR parsing
→ review_required
→ confirmed

failure branches:
failed
cancelled
```

## Tasks

1. Upload PDF/CSV via multipart.
2. Support `provider_hint`.
3. `document_password` hanya dikirim bila diperlukan dan tidak dipersist.
4. Setelah `202`, poll status import.
5. Stop polling saat terminal state atau screen dispose.
6. Untuk `password_required`, tampilkan unlock flow.
7. Render draft transactions.
8. Support koreksi + review status.
9. Confirm selected/validated draft IDs.
10. Setelah confirm `202`, jangan langsung label semua analysis selesai.
11. Refresh transactions/dashboard setelah backend benar-benar siap.
12. Handle parser warnings/error code.

## Acceptance

- password tidak disimpan/log;
- polling tidak bocor setelah dispose;
- review draft berasal dari backend;
- confirm tidak menghasilkan duplicate import;
- failed parsing punya recoverable UI.

---

# Part 6 — Financial Goals

## Endpoints

```text
GET   /goals
POST  /goals
GET   /goals/{goal_id}
PATCH /goals/{goal_id}
POST  /goals/{goal_id}/approval
POST  /goals/{goal_id}/contributions
```

## Tasks

1. Ganti Goals mock list/detail.
2. Create goal harus masuk approval workflow, jangan auto-active di local state.
3. Update goal adalah proposal perubahan sesuai backend status.
4. Implement partner approval/rejection.
5. Implement manual/transaction-linked contribution.
6. Refresh dashboard jika goal progress berubah.

## Acceptance

- status goal mengikuti backend;
- partner approval tidak dipalsukan;
- contribution memperbarui progress real;
- UI tidak memetakan `pending` sebagai sukses final.

---

# Part 7 — Weekly Check-In

## Endpoints

```text
GET  /check-ins
GET  /check-ins/current
GET  /check-ins/{checkin_id}
PUT  /check-ins/{checkin_id}/answers
POST /check-ins/{checkin_id}/submit
```

## Removed endpoint warning

Jangan memanggil:

```text
GET /check-ins/{checkin_id}/summary
```

Endpoint itu ada pada contract lama tetapi tidak ada pada current OpenAPI.

## Tasks

1. Load current check-in dari backend.
2. Questions harus berasal dari payload backend, jangan hard-code sebagai contract.
3. Save answers sebagai private draft.
4. Submit harus one-shot/guarded dari double tap.
5. Render partner submission state.
6. Handle `open`, `waiting_for_partner`, `processing`, `completed`, `expired`.
7. Gunakan `summary_available` hanya sebagai flag.
8. Bila screen membutuhkan summary payload tetapi tidak ada route current yang mengembalikannya, catat **BLOCKED: contract gap**, jangan revive route lama.

## Acceptance

- raw answers tidak dibagikan ke partner via FE;
- questionnaire dinamis;
- waiting/processing state terlihat;
- removed summary route tidak dipanggil.

---

# Part 8 — Family Assessment + Model 2 → LLM Narrative

## Endpoints

```text
GET /family-assessments/current
GET /family-assessments
GET /family-assessments/id_assassment   # backend addendum, dynamic assessment id
```

## Objective

Pisahkan structured risk state dari narrative LLM.

## Flow

```text
GET /family-assessments/current
→ parse FamilyAssessment
→ ambil assessment.id
→ GET narrative endpoint dengan assessment id
→ compose UI
```

## Structured source of truth

Gunakan `FamilyAssessment` untuk:

```text
level
trend
domain_levels
main_factors
recommended_actions
safety_override
```

Gunakan narrative endpoint untuk:

```text
headline
overview
action_plan
encouragement
domain_highlights
meta
```

## Tasks

1. Buat DTO terpisah:
   - `FamilyAssessmentDto`
   - `FamilyAssessmentNarrativeDto`
2. Jangan merge keduanya menjadi satu DTO yang menghilangkan boundary.
3. Implement current + history.
4. Implement narrative fetch dengan route builder terpusat.
5. Handle `is_partial`.
6. Handle `is_fallback`.
7. Jangan pernah menimpa safety state dari copy LLM.
8. Jika narrative endpoint gagal tetapi structured assessment sukses, screen kondisi keluarga tetap dapat menampilkan structured state + explicit narrative unavailable state.
9. Smoke test bentuk path `id_assassment` karena addendum belum diformalisasi di OpenAPI.

## Acceptance

- assessment status tidak bergantung pada LLM wording;
- LLM failure tidak menghilangkan structured safety information;
- history memakai cursor;
- addendum route tidak hard-coded tersebar di banyak file.

---

# Part 9 — Recovery Sessions

## Endpoints

```text
GET  /recovery-sessions
POST /recovery-sessions
GET  /recovery-sessions/{recovery_session_id}
POST /recovery-sessions/{recovery_session_id}/readiness
PUT  /recovery-sessions/{recovery_session_id}/reflection
POST /recovery-sessions/{recovery_session_id}/statement-draft
POST /recovery-sessions/{recovery_session_id}/publish-statement
POST /recovery-sessions/{recovery_session_id}/partner-response
POST /recovery-sessions/{recovery_session_id}/pause
POST /recovery-sessions/{recovery_session_id}/complete
```

## Removed endpoint warning

Jangan memanggil:

```text
GET /recovery-sessions/{recovery_session_id}/alignment
```

`RecoverySession` current masih mempunyai `alignment_summary`, tetapi tidak ada standalone GET alignment di current OpenAPI.

## Safety invariants

- reflection privat;
- statement draft belum shared;
- publish butuh explicit share consent;
- unsafe readiness tidak boleh dipaksa maju;
- pause/mediation state harus dihormati;
- AI tidak boleh menentukan workflow sendiri.

## Tasks

1. Model seluruh recovery status enum.
2. Integrasikan list/detail/create.
3. Readiness harus memengaruhi navigation berdasarkan response backend.
4. Reflection disimpan privat.
5. Statement draft diperlakukan sebagai draft.
6. Publish hanya setelah explicit action pengguna.
7. Partner response berasal dari backend.
8. Refresh RecoverySession setelah mutation.
9. Bila UI membutuhkan alignment payload terpisah dan current session tidak menyediakannya, tandai contract gap.

## Acceptance

- tidak ada auto-publish;
- private reflection tidak masuk shared state;
- paused/unsafe state tidak dilompati;
- removed alignment route tidak dipanggil.

---

# Part 10 — Commitments

## Endpoints

```text
GET   /commitments
POST  /commitments
GET   /commitments/{commitment_id}
PATCH /commitments/{commitment_id}
POST  /commitments/{commitment_id}/approval
POST  /commitments/{commitment_id}/progress
POST  /commitments/{commitment_id}/complete
```

## Tasks

1. Integrasikan commitment list/detail.
2. Create tetap draft/pending sesuai backend, jangan auto-approve.
3. Implement partner approval/reject.
4. Implement progress + evidence.
5. Complete hanya lewat endpoint complete.
6. Model overdue/revised/cancelled states.

## Acceptance

- state machine commitment berasal dari backend;
- progress tersimpan real;
- approval tidak dipalsukan;
- complete bukan perubahan local-only.

---

# Part 11 — Empathic Chat

## Endpoints

```text
GET    /chat/sessions
POST   /chat/sessions
GET    /chat/sessions/{chat_session_id}
DELETE /chat/sessions/{chat_session_id}
GET    /chat/sessions/{chat_session_id}/messages
POST   /chat/sessions/{chat_session_id}/messages
```

## Tasks

1. Session list + create + delete.
2. Cursor pagination untuk messages.
3. Kirim hanya melalui public backend.
4. Render `safety_level`, `suggested_actions`, `requires_professional_support` dari backend response.
5. Jangan menulis local AI response untuk menutupi API failure.
6. Chat memory/session privat.
7. Disable send saat request pending atau berikan queue behavior yang eksplisit.

## Acceptance

- tidak ada direct Gemini/FastAPI call;
- history berasal backend;
- safety flags tidak dibuang saat mapping DTO;
- delete menghapus local cache session terkait.

---

# Part 12 — Professionals & Consultations

## Endpoints

```text
GET   /professionals
GET   /professionals/{professional_id}

GET   /consultations
POST  /consultations
GET   /consultations/{consultation_id}
PATCH /consultations/{consultation_id}
PUT   /consultations/{consultation_id}/checklist
POST  /consultations/{consultation_id}/notes
POST  /consultations/{consultation_id}/convert-to-commitment
```

## Tasks

1. Integrasikan directory search/filter dari query yang tersedia di OpenAPI.
2. Detail professional berasal backend.
3. External contact links tetap dibuka sebagai external action sesuai payload.
4. Konsultasi adalah pencatatan jadwal eksternal, bukan booking engine.
5. Checklist + notes harus mengikuti visibility.
6. Convert-to-commitment menghasilkan commitment draft real.

## Acceptance

- directory bukan hard-coded seed di FE;
- consultation status real;
- notes visibility tidak diabaikan;
- convert flow menghasilkan commitment backend.

---

# Part 13 — Removed/Deferred Feature Cleanup

## Objective

Memastikan frontend tidak terus memanggil contract lama.

## Explicitly removed from active integration

```text
GET  /check-ins/{checkin_id}/summary
GET  /recovery-sessions/{recovery_session_id}/alignment

GET  /simulations
POST /simulations
GET  /simulations/{simulation_id}
POST /simulations/{simulation_id}/share

GET  /notifications
POST /notifications/{notification_id}/read
POST /devices
```

## Tasks

1. Cari semua call site route di atas.
2. Hapus/disable API integration lama.
3. Jika screen simulation masih ada di UI:
   - jangan membuat fake backend call;
   - pertahankan hanya jika memang intentionally local/mock/demo dan diberi boundary yang jelas;
   - untuk production integration status, tandai `NOT BACKEND-INTEGRATED`.
4. Notification UI yang membutuhkan removed endpoints harus ditandai pending contract.
5. Jangan menghapus screen desain hanya karena endpoint hilang, kecuali memang diminta. Yang dihapus adalah asumsi integration-nya.

## Acceptance

- zero runtime call ke route removed;
- build tidak bergantung pada DTO endpoint lama;
- TODO/blocker jelas untuk fitur yang contract-nya belum ada.

---

# Part 14 — Integration Hardening & Mock Purge

## Objective

Menyelesaikan integrasi sebagai satu sistem, bukan kumpulan screen yang masing-masing punya real API separuh.

## Tasks

1. Cari lagi semua fake/hard-coded data source.
2. Bedakan:
   - production source;
   - preview/demo fixture;
   - test fixture.
3. Production path tidak boleh silently fallback ke fixture.
4. Audit cache invalidation setelah mutation.
5. Audit `mounted/dispose` atau equivalent lifecycle safety.
6. Audit double-submit.
7. Audit error copy supaya backend failure tidak terlihat sebagai user success.
8. Audit nullable fields.
9. Audit unknown enum handling.
10. Audit token/password/PII logging.
11. Test cold start authenticated.
12. Test cold start unauthenticated.
13. Test token expiry.
14. Test family unpaired vs paired.
15. Test e-statement 202 + polling.
16. Test LLM narrative failure dengan structured assessment tetap tersedia.
17. Test recovery unsafe/paused path.
18. Test removed routes menghasilkan zero call.

## Acceptance

- seluruh feature active memakai source real yang sesuai contract;
- mock production dependencies habis atau sengaja didokumentasikan;
- app tidak crash pada nullable/unknown enum;
- auth refresh stabil;
- no stale user data setelah logout/disconnect;
- safety/privacy invariants lolos audit.

---

# Recommended execution order

```text
Part 0
↓
Part 1
↓
Part 2
↓
Part 3
↓
Part 4
↓
Part 5
↓
Part 6
↓
Part 7
↓
Part 8
↓
Part 9
↓
Part 10
↓
Part 11
↓
Part 12
↓
Part 13
↓
Part 14
```

Part 4–6 dapat diparalelkan setelah HTTP/auth foundation stabil. Part 7–10 sebaiknya berurutan karena assessment/recovery/commitment saling berkaitan secara domain.

# Required completion report from Antigravity

Setelah setiap part, update catatan integrasi dengan format:

```markdown
## Part X — [name]

Status: DONE | PARTIAL | BLOCKED

### Integrated
- screen:
- endpoint:
- repository/provider:
- DTO:

### Removed mock
- ...

### Contract gaps / blockers
- ...

### Verification
- [ ] happy path
- [ ] error path
- [ ] loading state
- [ ] auth handling
- [ ] no duplicate mutation
```

Jangan menulis `DONE` hanya karena code compile. `DONE` berarti flow real backend sudah diverifikasi.
