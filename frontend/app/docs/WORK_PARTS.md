# Work Parts — Antigravity Execution

## 1. Cara memakai

Kerjakan part secara urut kecuali dependency sudah terpenuhi. Satu agent memegang satu part aktif. Hindari dua agent mengedit file inti berikut pada saat bersamaan:

- `app_router.dart`;
- theme tokens;
- `api_client.dart`;
- `mock_store.dart`;
- root providers;
- shared model.

Setiap part berakhir dengan verifikasi dan ringkasan. Agent wajib berhenti setelah part.

## 2. Dependency map

```text
00
├── 01
├── 02
└── 03

01 + 02 + 03
├── 04
├── 05
└── 06

06
├── 07
├── 08
└── 09

05 + 06 + 07
└── 10

02 + 03
├── 11
├── 12
├── 13
└── 14

04–14
└── 15
    └── 16
        └── 17
```

---

# Part 00 — Repository Audit and Bootstrap

## Objective

Menyiapkan repository agar seluruh part berikut dapat bekerja pada fondasi yang sama.

## Scope

- root Flutter config;
- `pubspec.yaml`;
- `main.dart`;
- `bootstrap.dart`;
- lint;
- environment config;
- folder skeleton.

## Tasks

1. Audit kode yang sudah ada.
2. Pertahankan implementasi yang sehat.
3. Tambahkan package yang disetujui.
4. Buat `AppConfig`.
5. Buat `DataSourceMode`.
6. Buat error boundary global.
7. Buat root provider scope.
8. Pastikan build Android berjalan.
9. Jangan membangun feature UI.

## Acceptance

- app boot;
- config dapat membaca dart define;
- analyzer pass;
- test baseline pass;
- tidak ada secret hard-coded.

## Verification

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

---

# Part 01 — Design System and Shared Components

## Objective

Menerjemahkan design brief menjadi token dan komponen reusable.

## Scope

- `app/theme/**`;
- `core/widgets/**`;
- asset registration.

## Tasks

1. Buat color, typography, spacing, radius, shadow tokens.
2. Buat gradient background.
3. Buat:
   - primary/secondary/destructive button;
   - text field;
   - amount field;
   - app card;
   - status badge;
   - progress card;
   - transaction row;
   - pill choice;
   - async/empty/error view;
   - app scaffold;
   - floating bottom nav styling.
4. Buat component gallery debug page.
5. Pastikan text scale dan nominal besar aman.

## Forbidden

- feature-specific API;
- direct route logic;
- magic colors di luar token.

## Acceptance

- gallery menunjukkan seluruh state;
- disabled/loading button stabil;
- form field error state;
- contrast cukup;
- no overflow.

---

# Part 02 — Router and Application Shell

## Objective

Membuat navigasi lengkap dan route guard skeleton.

## Scope

- `app/router/**`;
- app shell;
- route catalog;
- navigation model.

## Tasks

1. Implement `go_router`.
2. Implement auth/onboarding/family redirects.
3. Implement four-tab shell.
4. Daftarkan seluruh route target.
5. Gunakan placeholder page yang jelas untuk route belum dikerjakan.
6. Implement back behavior.
7. Tambahkan debug route catalog.

## Acceptance

- setiap route dapat dibuka;
- no cyclic redirect;
- tab state dipertahankan;
- bottom nav tidak muncul pada auth;
- placeholder tidak dianggap feature selesai.

## Tests

- redirect matrix;
- deep route;
- back behavior smoke.

---

# Part 03 — Stateful Mock Backend Core

## Objective

Membuat sumber data mock yang menyerupai backend, bukan fixture pasif.

## Scope

- `lib/mock/**`;
- mock repository infrastructure;
- fixtures dasar.

## Tasks

1. Implement `MockStore`.
2. Implement `MockClock`.
3. Implement deterministic latency.
4. Implement scenario selection.
5. Implement reset.
6. Seed user, family, dashboard, transactions.
7. Buat error policy manual.
8. Buat provider mock.
9. Pastikan model sama dengan remote model.

## Acceptance

- mutation persist selama sesi;
- reset mengembalikan seed;
- scenario tidak random;
- latency dapat dipercepat pada test;
- private data tidak bocor.

## Tests

- reset;
- mutation;
- clock;
- scenario switch.

---

# Part 04 — Onboarding, Auth, and Profile

## Objective

Membawa user dari fresh install menuju profile-ready state.

## Scope

- onboarding;
- auth;
- profile setup;
- secure token storage.

## API

```text
POST /auth/register
POST /auth/login
POST /auth/refresh
POST /auth/logout
POST /auth/forgot-password
POST /auth/reset-password
GET /me
PATCH /me
POST /me/onboarding
```

## Tasks

1. Build onboarding 3 screens.
2. Build register/login segmented UI.
3. Build forgot password.
4. Implement form validation.
5. Implement auth repository mock/remote.
6. Implement Dio auth interceptor.
7. Store token securely.
8. Build profile setup.
9. Wire route guard.
10. Handle 401/422.

## Acceptance

- fresh path complete;
- token not in preferences;
- failed login preserves email;
- refresh loop impossible;
- logout clears private state;
- mock/remote switch works.

---

# Part 05 — Family Pairing and Consent

## Objective

Membentuk ruang keluarga hanya setelah consent.

## Scope

- family connect;
- invitation;
- pending;
- success;
- consent/settings boundary.

## API

```text
GET /family
POST /family/invitations
GET /family/invitations
POST /family/invitations/{invite_code}/accept
POST /family/invitations/{invite_code}/reject
DELETE /family/invitations/{invitation_id}
PATCH /family/settings
POST /family/consents
POST /family/disconnect
```

## Tasks

1. Build connect account screen.
2. Create/copy invite code.
3. Accept/reject request.
4. Build pairing success.
5. Show encrypted/secure status copy.
6. Implement consent update.
7. Implement disconnect confirmation.
8. Update route redirect.
9. Mock pending and active scenarios.

## Acceptance

- no shared dashboard before active family;
- reject does not expose data;
- disconnect revokes access UI immediately;
- history deletion not implied;
- invite expiry handled.

---

# Part 06 — Dashboard and App Home

## Objective

Membangun pusat navigasi dan ringkasan keluarga.

## Scope

- home dashboard;
- finance root summary;
- dashboard repository;
- shared dashboard widgets.

## API

```text
GET /dashboard
GET /family-assessments/current
```

## Tasks

1. Build greeting/header.
2. Build family status.
3. Build balance hero.
4. Build goal progress.
5. Build check-in reminder.
6. Build help cards.
7. Build recent activity.
8. Build hide balance behavior.
9. Implement loading/error/empty.
10. Refresh after mutation via invalidation.

## Acceptance

- close to design brief;
- hide balance persists;
- dashboard state updates after transaction/statement/goal;
- family level copy safe;
- no internal score shown as probability.

---

# Part 07 — Transactions

## Objective

Menyediakan pencatatan dan pengelolaan transaksi manual.

## Scope

- transaction list/detail/form;
- confirmation/feedback.

## API

```text
GET    /transactions
POST   /transactions
GET    /transactions/{id}
PATCH  /transactions/{id}
DELETE /transactions/{id}
POST   /transactions/{id}/confirmation
POST   /transactions/{id}/feedback
```

## Tasks

1. Build list with cursor pagination.
2. Build income/expense form.
3. Build detail/edit.
4. Build archive confirmation.
5. Build anomaly explanation.
6. Build confirmation/clarification.
7. Build feedback.
8. Update mock store and dashboard.
9. Map all categories and channels.
10. Handle large amount.

## Acceptance

- amount integer;
- new transaction appears;
- archive reflected;
- no “transaction gambling” language;
- pagination works;
- error preserves form.

---

# Part 08 — Financial Goals

## Objective

Membuat goal bersama dan approval flow.

## Scope

- goals list/create/detail/edit;
- approval;
- contribution.

## API

```text
GET  /goals
POST /goals
GET  /goals/{id}
PATCH /goals/{id}
POST /goals/{id}/approval
POST /goals/{id}/contributions
```

## Tasks

1. Build list.
2. Build create/edit.
3. Implement quick amount chips.
4. Implement deadline.
5. Implement contribution scheme.
6. Implement priority.
7. Implement pending partner approval.
8. Implement approve/reject.
9. Add manual/transaction-linked contribution.
10. Update dashboard progress.

## Acceptance

- status flow valid;
- partner approval visible;
- goal changes reflected;
- no float money;
- deadline date safe;
- contribution history readable.

---

# Part 09 — E-Statement Import and Anomaly Review

## Objective

Membangun hero flow finansial dan AI inference.

## Scope

- upload;
- password;
- polling;
- drafts;
- review;
- confirm;
- dashboard refresh.

## API

```text
GET    /statement-imports
POST   /statement-imports
GET    /statement-imports/{id}
DELETE /statement-imports/{id}
POST   /statement-imports/{id}/unlock
GET    /statement-imports/{id}/draft-transactions
PATCH  /statement-imports/{id}/draft-transactions/{draftId}
POST   /statement-imports/{id}/confirm
```

## Tasks

1. Implement file selection.
2. Validate PDF/CSV and size.
3. Implement multipart upload.
4. Implement progress.
5. Implement status polling.
6. Implement password-required flow.
7. Clear password after request.
8. Build review page.
9. Implement category correction.
10. Implement validate/delete.
11. Implement normal transaction collapse.
12. Confirm import.
13. Refresh dashboard and transaction list.
14. Implement failed/cancelled states.
15. Build deterministic mock state machine.

## Acceptance

- flow works mock and remote/hybrid;
- polling stops on dispose;
- password not logged/stored;
- 202 not treated final;
- errors specific;
- copy says unusual/confirmation;
- confirm changes financial data.

## Tests

- status transitions;
- wrong password;
- parsing failed;
- review mutation;
- confirm mutation;
- cancellation.

---

# Part 10 — Weekly Check-In and Family Assessment

## Objective

Menghubungkan data privat individu dengan ringkasan bersama yang aman.

## Scope

- check-in;
- answers;
- submit;
- partner wait;
- summary;
- assessment.

## API

```text
GET  /check-ins/current
GET  /check-ins
GET  /check-ins/{id}
PUT  /check-ins/{id}/answers
POST /check-ins/{id}/submit
GET  /check-ins/{id}/summary
GET  /family-assessments/current
GET  /family-assessments
```

## Tasks

1. Render questions from contract, not hard-coded layout only.
2. Support option/scale/text answer.
3. Save draft.
4. Show privacy note.
5. Submit.
6. Show partner wait.
7. Poll/refresh processing state.
8. Show shared summary only when available.
9. Build family condition page.
10. Show level, trend, factor, actions.
11. Implement safety override UI.
12. Update dashboard.

## Acceptance

- raw partner answer inaccessible;
- raw own answer not shown as shared;
- safety state routes correctly;
- internal score hidden;
- summary copy neutral;
- mock and remote happy path.

---

# Part 11 — Recovery Sessions and Commitments

## Objective

Membuat Ruang Pemulihan Bersama sebagai flow bertahap dan aman.

## Scope

- recovery list/detail;
- readiness;
- reflection;
- statement draft;
- publish;
- partner response;
- alignment;
- commitment.

## API

Gunakan seluruh `/recovery-sessions*` dan `/commitments*` pada public contract.

## Tasks

1. Build recovery entry/list.
2. Build topic selection.
3. Build readiness/safety check.
4. Stop flow if not safe.
5. Build private reflection.
6. Generate statement draft.
7. Require explicit publish.
8. Build partner response state.
9. Build alignment.
10. Create commitment draft.
11. Approval/progress/complete.
12. Support pause and professional recommendation.
13. Implement coherent mock flow.

## Acceptance

- reflection private;
- no automatic publish;
- unsafe readiness blocks normal mediation;
- commitment requires appropriate approval;
- status machine valid;
- no AI authority over workflow.

## Scope control

Bila waktu terbatas, selesaikan satu happy path dan safety path. Jangan membuat seluruh cabang visual tetapi tanpa state.

---

# Part 12 — AI Chat

## Objective

Menyediakan pendamping AI privat dengan respons terstruktur dan safety behavior.

## Scope

- session list/create/delete;
- message list/send;
- suggested actions;
- referral.

## API

```text
GET    /chat/sessions
POST   /chat/sessions
GET    /chat/sessions/{id}
DELETE /chat/sessions/{id}
GET    /chat/sessions/{id}/messages
POST   /chat/sessions/{id}/messages
```

## Tasks

1. Build mediation card.
2. Build session list/new session.
3. Build chat page.
4. Implement optimistic user bubble carefully.
5. Implement assistant loading.
6. Parse structured response.
7. Render suggested actions.
8. Render professional support.
9. Handle safety levels.
10. Delete session and memory confirmation.
11. Mock intent responses.
12. Preserve privacy.

## Acceptance

- many sessions supported;
- message persisted;
- timeout recoverable;
- no diagnosis/blame;
- urgent safety visible;
- suggested action navigates;
- chat content not logged.

---

# Part 13 — Professionals, Consultations, and Simulations

## Objective

Menyediakan jalur bantuan dan refleksi lanjutan.

## Scope

- professional list/detail;
- external contact;
- consultation record;
- simulation input/result/share.

## API

Gunakan `/professionals*`, `/consultations*`, dan `/simulations*`.

## Tasks

1. Build filters/search.
2. Build professional cards/detail.
3. Validate external URL scheme.
4. Show leaving-app confirmation when useful.
5. Build consultation form/list.
6. Build checklist/notes basic.
7. Build simulation input.
8. Build deterministic result.
9. Display formula version and disclaimer.
10. Implement share/private toggle.
11. CTA to professional.

## Acceptance

- no fake booking claim;
- link safe;
- notes private;
- disclaimer always visible;
- result not framed as prediction;
- mock seed sufficient.

---

# Part 14 — Settings, Privacy, and Notifications

## Objective

Memberi pengguna kendali atas akun, tampilan, koneksi, dan data.

## Scope

- profile/settings;
- preferences;
- notifications;
- logout/disconnect.

## API

```text
GET/PATCH /me
PATCH /family/settings
POST /family/consents
POST /family/disconnect
GET /notifications
POST /notifications/{id}/read
POST /devices
POST /auth/logout
```

## Tasks

1. Build profile card.
2. Build preference groups.
3. Persist hide balance/theme locally.
4. Wire reminder preference.
5. Build notification list/read state.
6. Build privacy explanation.
7. Build disconnect.
8. Build logout.
9. Clean private state.
10. Hide unimplemented biometric behind capability/feature flag.

## Acceptance

- settings match design brief;
- secure actions confirmed;
- no fake biometrics;
- logout clears token;
- disconnect behavior accurate;
- notification empty state.

---

# Part 15 — Full Integration

## Objective

Mengganti mock dengan remote per domain tanpa mengubah presentation.

## Scope

- remote repository completion;
- environment;
- contract fixes;
- integration tests.

## Tasks

1. Build integration matrix.
2. Enable remote P0.
3. Capture staging fixtures.
4. Fix mapper only, not contract silently.
5. Test token refresh.
6. Test multipart.
7. Test polling.
8. Test AI timeout.
9. Test safety response.
10. Confirm hybrid fallback config.
11. Record contract mismatch separately.

## Acceptance

- P0 remote;
- no widget mock branch;
- request ID visible for diagnostics;
- no sensitive logs;
- integration test critical path.

---

# Part 16 — QA and Demo Hardening

## Objective

Membuat aplikasi stabil untuk video dan review.

## Scope

- all screens;
- tests;
- visual polish;
- performance;
- demo controls.

## Tasks

1. Walk all routes.
2. Test small/large phone.
3. Test keyboard.
4. Test text scale.
5. Test offline/error.
6. Test large rupiah.
7. Run visual comparison.
8. Reset demo scenario.
9. Rehearse video twice.
10. Build APK.
11. Remove debug artifacts from demo build.
12. Prioritize P0/P1 bugs.

## Acceptance

- no dead end;
- no analyzer error;
- no sensitive log;
- demo passes twice;
- APK installs;
- mock fallback works;
- known issues documented.

---

# Part 17 — Documentation and Handoff

## Objective

Menyediakan konteks agar tim dapat melanjutkan dari 70–80% ke production.

## Scope

- README;
- architecture notes;
- environment setup;
- known issues;
- endpoint status;
- test instructions.

## Tasks

1. Update project README.
2. Document run modes.
3. Document secrets/env.
4. Document mock scenario.
5. Document integration matrix.
6. List known issues.
7. List deferred P2 scope.
8. Document release/build.
9. Add screenshots only bila berguna.
10. Ensure context docs match code.

## Acceptance

Developer baru dapat:

- menjalankan app;
- memilih mode;
- reset demo;
- memahami architecture;
- mengetahui endpoint remote/mock;
- melanjutkan unfinished scope.
