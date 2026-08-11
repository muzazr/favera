# ANTIGRAVITY — Favera FE↔BE Endpoint Source of Truth

> **Status: CURRENT SOURCE OF TRUTH FOR FRONTEND INTEGRATION**
>
> Gunakan dokumen ini untuk pekerjaan integrasi Flutter ↔ Express backend. Dokumen/brief lama boleh dibaca hanya untuk konteks historis atau UX, **bukan** untuk menentukan route yang dipanggil.
>
> Low-level contract yang mendasari brief ini adalah **`favera-public-api-v0.1.openapi(1).json`** (upload terbaru), ditambah **backend addendum** untuk hasil Model 2 → LLM yang diberikan setelah file OpenAPI tersebut.

## 1. Source precedence

Jika ada konflik, gunakan urutan prioritas berikut:

1. **Instruksi backend/addendum terbaru di dokumen ini.**
2. **`favera-public-api-v0.1.openapi(1).json`**.
3. Implementasi backend yang benar-benar terdeploy, setelah diverifikasi melalui smoke test.
4. Brief/README/contract lama hanya sebagai referensi konteks.
5. Mock UI tidak boleh mengalahkan contract backend.

Jangan menggabungkan route lama dan baru hanya agar layar "kelihatan jalan". Kalau contract tidak menyediakan data yang dibutuhkan UI, catat sebagai **contract gap**, jangan mengarang endpoint.

## 2. Runtime base URL

Public backend domain yang diberikan backend:

```text
https://favera-backend.vercel.app/
```

Public API base path berdasarkan contract:

```text
/api/v1
```

Gunakan satu environment/config value:

```text
https://favera-backend.vercel.app/api/v1
```

Contoh smoke test:

```http
GET /health
```

Semua komunikasi frontend harus:

```text
Flutter → Express Public Backend
```

Frontend **tidak boleh** memanggil Supabase, Storage, FastAPI AI service, Gemini/LLM, atau service internal secara langsung.

## 3. Authentication contract

Protected route menggunakan:

```http
Authorization: Bearer <access_token>
```

Token lifecycle:

```text
POST /auth/login or /auth/register
→ simpan access_token + refresh_token
→ attach bearer token
→ bila access token expired/401 yang memang karena expiry, coba POST /auth/refresh satu kali
→ retry original request satu kali
→ bila refresh gagal, clear session dan kembali ke auth flow
```

Jangan membuat infinite refresh loop.

## 4. Current contract inventory

Latest OpenAPI memiliki:

- **63 path patterns**
- **80 HTTP operations**
- ditambah **1 backend addendum operation** untuk narrative hasil family assessment
- sehingga brief integrasi saat ini mengenali **81 operation**

## System
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/health` | No | `200` | `—` | `inline object` | Health check |

## Auth
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `POST` | `/auth/forgot-password` | No | `200` | `inline application/json` | `inline object` | Kirim email pemulihan kata sandi |
| `POST` | `/auth/login` | No | `200` | `LoginRequest` | `AuthTokens` | Masuk dengan email dan kata sandi |
| `POST` | `/auth/logout` | Yes | `204` | `—` | `empty body` | Keluar dan mencabut refresh token |
| `POST` | `/auth/refresh` | No | `200` | `RefreshRequest` | `AuthTokens` | Perbarui access token |
| `POST` | `/auth/register` | No | `201` | `RegisterRequest` | `AuthTokens` | Registrasi akun dengan email dan kata sandi |
| `POST` | `/auth/reset-password` | No | `200` | `inline application/json` | `inline object` | Atur ulang kata sandi |

## Users
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/me` | Yes | `200` | `—` | `User` | Ambil profil pengguna saat ini |
| `PATCH` | `/me` | Yes | `200` | `UpdateProfileRequest` | `User` | Perbarui profil pengguna |
| `POST` | `/me/onboarding` | Yes | `200` | `OnboardingRequest` | `User` | Selesaikan onboarding profil |

## Families
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/family` | Yes | `200` | `—` | `FamilySpace` | Ambil ruang keluarga aktif |
| `POST` | `/family/consents` | Yes | `200` | `FamilyConsentRequest` | `FamilySpace` | Perbarui persetujuan berbagi data keluarga |
| `POST` | `/family/disconnect` | Yes | `200` | `DisconnectFamilyRequest` | `inline object` | Putuskan koneksi pasangan |
| `GET` | `/family/invitations` | Yes | `200` | `—` | `array<FamilyInvitation>` | Daftar undangan aktif |
| `POST` | `/family/invitations` | Yes | `201` | `CreateInvitationRequest` | `FamilyInvitation` | Buat kode undangan pasangan |
| `DELETE` | `/family/invitations/{invitation_id}` | Yes | `204` | `—` | `empty body` | Cabut undangan yang masih pending |
| `POST` | `/family/invitations/{invite_code}/accept` | Yes | `200` | `AcceptInvitationRequest` | `FamilySpace` | Terima undangan pasangan |
| `POST` | `/family/invitations/{invite_code}/reject` | Yes | `200` | `—` | `FamilyInvitation` | Tolak undangan pasangan |
| `PATCH` | `/family/settings` | Yes | `200` | `FamilySettingsRequest` | `FamilySpace` | Perbarui pengaturan ruang keluarga |

## Financial
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/dashboard` | Yes | `200` | `—` | `FinancialDashboard` | Ambil ringkasan dashboard finansial dan kondisi keluarga |

## Transactions
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/transactions` | Yes | `200` | `—` | `TransactionList` | Daftar transaksi |
| `POST` | `/transactions` | Yes | `201` | `CreateTransactionRequest` | `Transaction` | Catat transaksi manual |
| `DELETE` | `/transactions/{transaction_id}` | Yes | `204` | `—` | `empty body` | Arsipkan transaksi |
| `GET` | `/transactions/{transaction_id}` | Yes | `200` | `—` | `Transaction` | Ambil detail transaksi |
| `PATCH` | `/transactions/{transaction_id}` | Yes | `200` | `UpdateTransactionRequest` | `Transaction` | Perbarui transaksi |
| `POST` | `/transactions/{transaction_id}/confirmation` | Yes | `200` | `TransactionConfirmationRequest` | `Transaction` | Konfirmasi atau klarifikasi transaksi |
| `POST` | `/transactions/{transaction_id}/feedback` | Yes | `200` | `TransactionFeedbackRequest` | `Transaction` | Kirim label umpan balik untuk anomaly detector |

## Statements
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/statement-imports` | Yes | `200` | `—` | `StatementImportList` | Daftar impor e-statement |
| `POST` | `/statement-imports` | Yes | `202` | `multipart: file (+ provider_hint, document_password?)` | `StatementImport` | Unggah e-statement PDF atau CSV |
| `DELETE` | `/statement-imports/{statement_import_id}` | Yes | `204` | `—` | `empty body` | Batalkan impor dan hapus file sumber |
| `GET` | `/statement-imports/{statement_import_id}` | Yes | `200` | `—` | `StatementImport` | Ambil status dan metadata impor |
| `POST` | `/statement-imports/{statement_import_id}/confirm` | Yes | `202` | `ConfirmStatementImportRequest` | `StatementImport` | Simpan transaksi tervalidasi ke data keuangan dan mulai analisis anomali |
| `GET` | `/statement-imports/{statement_import_id}/draft-transactions` | Yes | `200` | `—` | `ParsedTransactionList` | Daftar transaksi hasil parsing untuk ditinjau |
| `PATCH` | `/statement-imports/{statement_import_id}/draft-transactions/{draft_transaction_id}` | Yes | `200` | `UpdateParsedTransactionRequest` | `ParsedTransactionDraft` | Koreksi atau validasi transaksi hasil parsing |
| `POST` | `/statement-imports/{statement_import_id}/unlock` | Yes | `200` | `UnlockStatementRequest` | `StatementImport` | Kirim ulang kata sandi PDF secara ephemeral |

## Goals
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/goals` | Yes | `200` | `—` | `GoalList` | Daftar financial goal bersama |
| `POST` | `/goals` | Yes | `201` | `CreateGoalRequest` | `FinancialGoal` | Buat financial goal dan minta persetujuan pasangan |
| `GET` | `/goals/{goal_id}` | Yes | `200` | `—` | `FinancialGoal` | Ambil detail financial goal |
| `PATCH` | `/goals/{goal_id}` | Yes | `200` | `UpdateGoalRequest` | `FinancialGoal` | Ajukan perubahan financial goal |
| `POST` | `/goals/{goal_id}/approval` | Yes | `200` | `GoalApprovalRequest` | `FinancialGoal` | Setujui atau tolak goal/perubahan goal |
| `POST` | `/goals/{goal_id}/contributions` | Yes | `201` | `CreateContributionRequest` | `GoalContribution` | Tambahkan kontribusi manual atau kaitkan transaksi |

## CheckIns
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/check-ins` | Yes | `200` | `—` | `CheckInList` | Riwayat weekly check-in |
| `GET` | `/check-ins/current` | Yes | `200` | `—` | `WeeklyCheckIn` | Ambil weekly check-in aktif |
| `GET` | `/check-ins/{checkin_id}` | Yes | `200` | `—` | `WeeklyCheckIn` | Ambil detail weekly check-in |
| `PUT` | `/check-ins/{checkin_id}/answers` | Yes | `200` | `SaveCheckInAnswersRequest` | `WeeklyCheckIn` | Simpan draft jawaban privat |
| `POST` | `/check-ins/{checkin_id}/submit` | Yes | `200` | `—` | `WeeklyCheckIn` | Kirim jawaban check-in |

## Assessments
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/family-assessments` | Yes | `200` | `—` | `AssessmentList` | Riwayat asesmen keluarga |
| `GET` | `/family-assessments/current` | Yes | `200` | `—` | `FamilyAssessment` | Ambil asesmen keluarga terbaru |

## Recovery
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/recovery-sessions` | Yes | `200` | `—` | `RecoverySessionList` | Daftar sesi Ruang Pemulihan Bersama |
| `POST` | `/recovery-sessions` | Yes | `201` | `CreateRecoverySessionRequest` | `RecoverySession` | Mulai sesi Ruang Pemulihan Bersama |
| `GET` | `/recovery-sessions/{recovery_session_id}` | Yes | `200` | `—` | `RecoverySession` | Ambil detail sesi pemulihan |
| `POST` | `/recovery-sessions/{recovery_session_id}/complete` | Yes | `200` | `—` | `RecoverySession` | Selesaikan sesi pemulihan |
| `POST` | `/recovery-sessions/{recovery_session_id}/partner-response` | Yes | `200` | `PartnerResponseRequest` | `RecoverySession` | Kirim respons pasangan secara terstruktur |
| `POST` | `/recovery-sessions/{recovery_session_id}/pause` | Yes | `200` | `—` | `RecoverySession` | Jeda sesi pemulihan |
| `POST` | `/recovery-sessions/{recovery_session_id}/publish-statement` | Yes | `200` | `PublishStatementRequest` | `RecoverySession` | Bagikan pernyataan yang telah disetujui pengguna |
| `POST` | `/recovery-sessions/{recovery_session_id}/readiness` | Yes | `200` | `ReadinessRequest` | `RecoverySession` | Kirim pemeriksaan kesiapan dan keamanan |
| `PUT` | `/recovery-sessions/{recovery_session_id}/reflection` | Yes | `200` | `PrivateReflectionRequest` | `RecoverySession` | Simpan refleksi pribadi |
| `POST` | `/recovery-sessions/{recovery_session_id}/statement-draft` | Yes | `200` | `—` | `StatementDraft` | Hasilkan draft pernyataan netral dari refleksi pribadi |

## Commitments
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/commitments` | Yes | `200` | `—` | `CommitmentList` | Daftar commitment bersama |
| `POST` | `/commitments` | Yes | `201` | `CreateCommitmentRequest` | `Commitment` | Buat draft commitment |
| `GET` | `/commitments/{commitment_id}` | Yes | `200` | `—` | `Commitment` | Ambil detail commitment |
| `PATCH` | `/commitments/{commitment_id}` | Yes | `200` | `CreateCommitmentRequest` | `Commitment` | Revisi commitment |
| `POST` | `/commitments/{commitment_id}/approval` | Yes | `200` | `CommitmentApprovalRequest` | `Commitment` | Setujui atau tolak commitment |
| `POST` | `/commitments/{commitment_id}/complete` | Yes | `200` | `—` | `Commitment` | Tandai commitment selesai |
| `POST` | `/commitments/{commitment_id}/progress` | Yes | `200` | `CommitmentProgressRequest` | `Commitment` | Perbarui progres dan bukti commitment |

## Chat
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/chat/sessions` | Yes | `200` | `—` | `ChatSessionList` | Daftar sesi chatbot privat |
| `POST` | `/chat/sessions` | Yes | `201` | `CreateChatSessionRequest` | `ChatSession` | Buat sesi chatbot baru |
| `DELETE` | `/chat/sessions/{chat_session_id}` | Yes | `204` | `—` | `empty body` | Hapus sesi chatbot dan memorinya |
| `GET` | `/chat/sessions/{chat_session_id}` | Yes | `200` | `—` | `ChatSession` | Ambil detail sesi chatbot |
| `GET` | `/chat/sessions/{chat_session_id}/messages` | Yes | `200` | `—` | `ChatMessageList` | Ambil pesan dalam sesi chatbot |
| `POST` | `/chat/sessions/{chat_session_id}/messages` | Yes | `200` | `CreateChatMessageRequest` | `ChatMessage` | Kirim pesan dan terima respons AI terstruktur |

## Professionals
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/professionals` | Yes | `200` | `—` | `ProfessionalList` | Cari direktori tenaga atau lembaga profesional |
| `GET` | `/professionals/{professional_id}` | Yes | `200` | `—` | `Professional` | Ambil detail profesional |

## Consultations
| Method | Path | Auth | Success | Request | Response | Purpose |
|---|---|---:|---:|---|---|---|
| `GET` | `/consultations` | Yes | `200` | `—` | `ConsultationList` | Daftar jadwal konsultasi yang dicatat pengguna |
| `POST` | `/consultations` | Yes | `201` | `CreateConsultationRequest` | `Consultation` | Catat jadwal konsultasi eksternal |
| `GET` | `/consultations/{consultation_id}` | Yes | `200` | `—` | `Consultation` | Ambil detail konsultasi |
| `PATCH` | `/consultations/{consultation_id}` | Yes | `200` | `CreateConsultationRequest` | `Consultation` | Perbarui jadwal atau status konsultasi |
| `PUT` | `/consultations/{consultation_id}/checklist` | Yes | `200` | `ConsultationChecklistRequest` | `Consultation` | Perbarui checklist sebelum konsultasi |
| `POST` | `/consultations/{consultation_id}/convert-to-commitment` | Yes | `201` | `CreateCommitmentRequest` | `Commitment` | Buat draft commitment dari hasil konsultasi |
| `POST` | `/consultations/{consultation_id}/notes` | Yes | `200` | `ConsultationNoteRequest` | `Consultation` | Tambahkan catatan setelah konsultasi |



## 4.1 Query parameter quick reference

Query parameter yang benar-benar dideklarasikan current OpenAPI:

| Endpoint | Query |
|---|---|
| `GET /dashboard` | `period_start`, `period_end` |
| `GET /transactions` | `cursor`, `limit` (default 20, 1–100), `direction` (`income|expense|transfer`), `category`, `attention_level` (`normal|unusual|needs_confirmation`) |
| `GET /statement-imports` | `cursor`, `limit` (default 20, 1–100) |
| `GET /statement-imports/{statement_import_id}/draft-transactions` | `cursor`, `limit` (default 20, 1–100) |
| `GET /goals` | `cursor`, `limit` (default 20, 1–100) |
| `GET /check-ins` | `cursor`, `limit` (default 20, 1–100) |
| `GET /family-assessments` | `cursor`, `limit` (default 20, 1–100) |
| `GET /recovery-sessions` | `cursor`, `limit` (default 20, 1–100) |
| `GET /commitments` | `cursor`, `limit` (default 20, 1–100) |
| `GET /chat/sessions` | `cursor`, `limit` (default 20, 1–100) |
| `GET /chat/sessions/{chat_session_id}/messages` | `cursor`, `limit` (default 20, 1–100) |
| `GET /professionals` | `cursor`, `limit` (default 20, 1–100), `category`, `city`, `service_mode` (`online|offline`), `cost_type` (`free|paid|mixed|unknown`) |
| `GET /consultations` | `cursor`, `limit` (default 20, 1–100) |

Jangan menambahkan filter query hanya karena UI punya dropdown/filter. Kalau tidak ada di contract, filter tersebut harus local-only atau ditandai backend gap secara eksplisit.

## 5. Backend addendum — Model 2 → LLM family assessment result

Backend memberikan endpoint tambahan setelah OpenAPI terbaru:

```text
GET /family-assessments/id_assassment
```

Response body:

```json
{
  "meta": {
    "is_partial": "boolean",
    "is_fallback": "boolean",
    "generated_at": "string (ISO Date)"
  },
  "headline": "string",
  "overview": "string",
  "action_plan": {
    "title": "string",
    "description": "string"
  },
  "encouragement": "string",
  "domain_highlights": [
    {
      "note": "string",
      "domain": "string",
      "status": "string"
    }
  ]
}
```

### Operational interpretation for FE

`id_assassment` dikomunikasikan backend sebagai segment identitas assessment. Implementasikan repository/service method yang menerima `assessmentId`, misalnya:

```text
getAssessmentNarrative(assessmentId)
```

**Jangan hard-code ID.** Simpan konstruksi route di satu tempat agar mudah dikoreksi jika backend ternyata memakai nama segment/path yang berbeda. Karena addendum ini belum masuk OpenAPI, lakukan smoke test terhadap route aktual sebelum mengganti semua call site.

### Role of this response

Anggap endpoint addendum ini sebagai **protected family endpoint** dan kirim bearer token seperti endpoint assessment lain, kecuali backend kemudian menyatakan berbeda.

Response ini adalah **presentation/narrative layer**, bukan source of truth untuk state machine risiko.

Gunakan:

```text
GET /family-assessments/current
```

untuk structured state:

- `id`
- `level`
- `trend`
- `domain_levels`
- `main_factors`
- `recommended_actions`
- `safety_override`
- `generated_at`

Kemudian gunakan assessment `id` untuk mengambil narrative LLM.

Jangan menurunkan `level`, `safety_override`, workflow, atau keputusan bisnis dari `headline`, `overview`, `encouragement`, `domain_highlights`, atau `action_plan`.

### `meta` handling

- `is_partial = true`: render hasil dengan state bahwa konteks/data tidak lengkap; jangan presentasikan sebagai ringkasan penuh.
- `is_fallback = true`: hasil fallback masih dapat dirender, tetapi jangan dianggap keluaran normal LLM pipeline.
- `generated_at`: simpan/parse sebagai ISO datetime untuk freshness indicator/debugging.

## 6. What changed from the previous public contract

Dibanding file sebelumnya **`favera-public-api-v0.1.openapi.json`**:

### 6.1 Routes removed from current OpenAPI

Route berikut **ADA di contract lama tetapi TIDAK ADA di OpenAPI terbaru**. Antigravity harus mencari call site lama dan **tidak lagi mengintegrasikannya sebagai backend API aktif**:

| Method | Removed route |
|---|---|
| `GET` | `/check-ins/{checkin_id}/summary` |
| `GET` | `/notifications` |
| `GET` | `/recovery-sessions/{recovery_session_id}/alignment` |
| `GET` | `/simulations` |
| `GET` | `/simulations/{simulation_id}` |
| `POST` | `/devices` |
| `POST` | `/notifications/{notification_id}/read` |
| `POST` | `/simulations` |
| `POST` | `/simulations/{simulation_id}/share` |

Konsekuensi:

- **Check-in summary:** jangan memanggil `GET /check-ins/{checkin_id}/summary`. Current `WeeklyCheckIn` hanya memiliki `summary_available`; bila UI membutuhkan payload summary yang tidak tersedia dari route current, tandai contract gap.
- **Recovery alignment:** jangan memanggil GET alignment lama. `RecoverySession` masih memiliki `alignment_summary`; gunakan data yang benar-benar dikembalikan route current. Bila flow membutuhkan fetch terpisah, tandai contract gap.
- **Simulations:** seluruh public simulation endpoints yang ada di brief lama sudah hilang. Jangan membuat integration client untuk simulation sampai backend menambahkan contract baru.
- **Notifications/devices:** route notification list/read dan device registration juga hilang dari current contract. Jangan mengarang replacement.

### 6.2 Schema changes that must be reflected in FE

Lima schema berubah pada field `direction`:

- `Transaction`
- `CreateTransactionRequest`
- `UpdateTransactionRequest`
- `ParsedTransactionDraft`
- `UpdateParsedTransactionRequest`

Current enum:

```text
income
expense
transfer
debt_increase
debt_payment
```

Brief/DTO lama yang hanya mengenal tiga value harus diperbarui.

**Known contract inconsistency:** query parameter `GET /transactions?direction=` di OpenAPI terbaru masih mendeklarasikan hanya:

```text
income | expense | transfer
```

Jadi FE boleh menerima/menampilkan/create/update `debt_increase` dan `debt_payment` sesuai DTO, tetapi **jangan mengirim kedua value itu sebagai query filter** sampai backend memperbarui/menegaskan filter contract.

### 6.3 No other operation-body diff

Untuk 80 operation yang tetap ada di kedua file, operation definitions-nya tidak berubah. Perubahan terpenting adalah:

1. sembilan operation dihapus,
2. lima transaction-related schema menambah dua enum direction,
3. satu endpoint narrative family-assessment ditambahkan melalui backend addendum di luar OpenAPI.

## 7. Async endpoint semantics

### E-statement

`POST /statement-imports` mengembalikan **202 Accepted**. Itu berarti proses diterima, **bukan selesai**.

State yang harus didukung:

```text
uploaded
password_required
parsing
review_required
confirmed
failed
cancelled
```

Flow:

```text
POST /statement-imports
→ poll GET /statement-imports/{id}
→ jika password_required: POST /statement-imports/{id}/unlock
→ saat review_required: GET draft-transactions
→ PATCH draft yang dikoreksi/divalidasi
→ POST /statement-imports/{id}/confirm
→ poll/refresh data terkait setelah processing backend
```

Jangan menyimpan `document_password`. Password PDF bersifat ephemeral/write-only.

### Confirm import

`POST /statement-imports/{id}/confirm` juga mengembalikan **202**. Jangan langsung menganggap anomaly assessment sudah selesai.

## 8. Privacy and safety invariants

Integrasi FE wajib menjaga aturan berikut:

- file e-statement asli: privat untuk pengunggah;
- draft parsing: privat untuk pengunggah;
- jawaban weekly check-in mentah: privat;
- private recovery reflection: privat;
- shared recovery statement hanya setelah explicit publish;
- chatbot/session/memory: privat;
- goal dan commitment: shared sesuai workflow/approval;
- safety state tidak boleh dioverride oleh copy LLM;
- jangan auto-publish reflection atau auto-approve goal/commitment;
- jangan membuka data pasangan dari mock/local state yang tidak diberikan backend.

## 9. High-risk status/enums FE must model explicitly

### Family assessment level

```text
stable
needs_attention
intensive_support_recommended
safety_support_required
```

### Family assessment trend

```text
improving
stable
worsening
insufficient_data
```

### Recovery session status

```text
DRAFT
READINESS_CHECK
PRIVATE_REFLECTION
WAITING_FOR_PARTNER
PARTNER_RESPONSE
ALIGNMENT
COMMITMENT_DRAFT
COMMITMENT_ACTIVE
FOLLOW_UP
COMPLETED
MEDIATION_RECOMMENDED
PAUSED
```

### Commitment status

```text
draft
pending_partner_approval
active
completed
overdue
revised
cancelled
```

### Transaction direction

```text
income
expense
transfer
debt_increase
debt_payment
```

Enums harus punya safe `unknown` parsing strategy di client agar app tidak crash bila backend menambah value baru.

## 10. Pagination and money/date rules

- Pagination list memakai cursor bila schema menyediakan `pagination`.
- Jangan mengasumsikan page number.
- Uang adalah integer rupiah (`IDR`), jangan memakai floating point untuk nominal.
- Date/time mengikuti ISO 8601.
- Field contract memakai `snake_case`.
- UUID adalah string di FE.
- `204` berarti sukses tanpa response body; jangan mencoba decode JSON.

## 11. Endpoint implementation rule

Untuk setiap endpoint yang diintegrasikan:

```text
remote DTO
→ mapper
→ domain/entity/state yang dipakai UI
```

Hindari membiarkan widget membaca raw `Map<String, dynamic>` langsung.

Setiap call minimal harus punya:

- loading state;
- success state;
- empty state bila relevan;
- API error state;
- unauthorized handling;
- retry hanya bila aman;
- cancellation/dispose safety;
- no duplicate submit untuk mutation.

Untuk mutation yang dapat ditekan dua kali, disable CTA selama request berlangsung.

## 12. Things Antigravity must NOT do

- Jangan memanggil AI service langsung dari Flutter.
- Jangan memakai removed endpoints hanya karena brief lama menyebutnya.
- Jangan membuat endpoint baru berdasarkan nama tombol UI.
- Jangan menjadikan mock sebagai fallback diam-diam setelah real API gagal.
- Jangan mengubah response contract di client agar sesuai mock lama.
- Jangan auto-share private data.
- Jangan menganggap `202` sebagai completed.
- Jangan menyimpan PDF password.
- Jangan mengulang request mutation tanpa mempertimbangkan duplicate side effect.
- Jangan menghapus UI existing secara massal hanya untuk mempermudah integration.

## 13. Required pre-integration audit

Sebelum menulis call baru, Antigravity wajib mencari di repo:

```text
baseUrl / API client
token storage
auth interceptor
repository/service layer
DTO/model yang sudah ada
mock repository/mock provider
hard-coded fake data
existing route constants
calls ke removed endpoints
transaction direction enum lama
simulation/notification integration lama
```

Setelah audit, ubah sesedikit mungkin struktur yang sudah sehat. Tujuan pekerjaan ini adalah **integrasi**, bukan rewrite arsitektur frontend.

---

**Final rule:** bila brief lama, mockup, atau implementasi existing bertentangan dengan dokumen ini, **dokumen ini menang**, kecuali backend memberikan addendum yang lebih baru.
