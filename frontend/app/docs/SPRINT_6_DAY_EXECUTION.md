# Sprint Execution Guide — 6 Days

## 1. Sprint goal

Dalam enam hari, hasilkan increment Favera yang:

- mencakup 70–80% produk;
- mempunyai seluruh screen dan flow utama;
- memakai mock API stateful sesuai kontrak;
- mengintegrasikan public backend untuk P0;
- menunjukkan inference AI melalui backend;
- stabil untuk demo;
- dapat diteruskan tanpa restrukturisasi besar.

## 2. Prinsip pengerjaan

- Prioritaskan vertical slice.
- Selesaikan satu flow dari UI sampai repository sebelum mempercantik semua screen.
- Mock dahulu, remote kemudian melalui contract yang sama.
- Integrasi dilakukan setiap hari mulai backend tersedia, bukan ditumpuk di hari terakhir.
- Jangan memulai feature baru sebelum critical path hari itu lulus.
- Simpan buffer untuk QA.
- Gunakan work parts pada `WORK_PARTS.md`.

## 3. Alokasi hasil

### Wajib selesai

- app shell dan theme;
- onboarding, auth, profile;
- family pairing;
- dashboard;
- transactions;
- goals;
- statement import;
- check-in;
- family assessment;
- mediation hub;
- AI chat;
- professionals;
- simulation;
- settings;
- mock stateful;
- P0 remote integration;
- demo scenario;
- test critical path.

### Selesai bila waktu cukup

- full recovery session;
- commitments lengkap;
- consultations;
- notifications;
- biometric login;
- advanced animation;
- full offline cache;
- production push notification.

## 4. Daily cadence

Setiap hari:

```text
15 menit — sync, blocker, contract change
60–90 menit — integration checkpoint
sisa waktu — implementation per part
30–45 menit — QA dan update docs
```

Setiap akhir hari harus ada build yang dapat dijalankan. Jangan membiarkan branch utama rusak karena “besok disambung”. Besok adalah tempat bug berkembang biak.

---

# Day 1 — Foundation, Design System, Mock Core

## Goal

Repository mempunyai fondasi yang stabil dan screen dapat dibangun tanpa menyalin style atau data logic.

## Parts

- Part 00: repository audit and bootstrap
- Part 01: design system
- Part 02: routing and app shell
- Part 03: mock backend core

## Deliverables

- dependency terpasang;
- environment config;
- theme dan tokens;
- reusable components;
- router dan route guards skeleton;
- four-tab shell;
- mock store, scenario, clock, latency;
- debug route catalog;
- lint/test baseline.

## Acceptance

- aplikasi boot;
- switch mock/remote/hybrid dapat dibaca;
- root routes tersedia;
- theme konsisten;
- mock state dapat di-reset;
- `flutter analyze` pass;
- smoke test app pass.

## Integration checkpoint

- konfirmasi base URL;
- tes `GET /health`;
- catat response/error behavior;
- jangan menunggu auth lengkap.

---

# Day 2 — Onboarding, Auth, Profile, Family, Dashboard

## Goal

Pengguna dapat mencapai dashboard melalui alur yang benar.

## Parts

- Part 04: onboarding/auth/profile
- Part 05: family pairing
- Part 06A: dashboard base

## Deliverables

- onboarding;
- login/register;
- forgot password UI;
- token storage;
- profile setup;
- invitation create/accept/reject;
- pairing success;
- dashboard mock;
- route redirects;
- auth error state.

## Acceptance

```text
fresh install
→ onboarding
→ login/register
→ profile
→ family
→ dashboard
```

Tidak ada dead end.

## Integration checkpoint

Remote:

- health;
- register/login/refresh;
- `/me`;
- `/family`.

Bila endpoint belum stabil, simpan mapping issue dan pertahankan mock.

---

# Day 3 — Finance, Transactions, Goals

## Goal

Pengguna dapat mengelola data finansial dasar dan melihat perubahan state.

## Parts

- Part 06B: dashboard full
- Part 07: transactions
- Part 08: goals

## Deliverables

- finance dashboard;
- transaction list/detail;
- add income/expense;
- edit/archive bila sesuai;
- transaction confirmation UI;
- goals list/create/detail;
- contributions;
- approval state;
- dashboard refresh setelah mutation.

## Acceptance

- transaction baru muncul di list dan dashboard;
- nominal tersimpan integer;
- goal progress berubah;
- loading/empty/error tersedia;
- no overflow untuk nominal besar.

## Integration checkpoint

Remote:

- `/dashboard`;
- `/transactions`;
- `/goals`.

Lakukan contract fixture capture dari staging.

---

# Day 4 — Statement Import, AI Inference, Check-In

## Goal

Diferensiasi utama Favera berjalan end-to-end.

## Parts

- Part 09: statement import
- Part 10: weekly check-in and assessment

## Deliverables

- file picker;
- upload progress;
- password required;
- polling;
- review draft;
- category correction;
- validate/delete;
- confirm;
- dashboard refresh;
- weekly check-in;
- partner waiting state;
- summary;
- family condition;
- safety state.

## Acceptance

Hero flow:

```text
upload
→ parse
→ review
→ confirm
→ dashboard
```

dan:

```text
check-in
→ submit
→ summary
→ assessment
```

berjalan pada mock dan remote/hybrid.

## Integration checkpoint

Remote:

- statement endpoints;
- check-in endpoints;
- assessment endpoints.

Tes file Mandiri/BRI/GoPay dan error path minimum satu.

---

# Day 5 — Recovery, AI Chat, Professionals, Simulation, Settings

## Goal

Lapisan pendampingan dan jalur bantuan tersedia.

## Parts

- Part 11: mediation and recovery
- Part 12: AI chat
- Part 13: professionals, consultation, simulation
- Part 14: profile/settings/notifications

## Deliverables

- mediation hub;
- recovery session minimal end-to-end atau coherent partial flow;
- chatbot sessions/messages;
- suggested actions;
- safety referral;
- professional directory/detail;
- external contact;
- simulation input/result;
- settings/profile;
- privacy toggles;
- disconnect/logout;
- notification list minimal.

## Acceptance

- AI chat tidak crash dan mempunyai safe copy;
- professional links aman;
- simulation disclaimer selalu terlihat;
- private/shared status benar;
- settings persist non-sensitive preference.

## Integration checkpoint

Remote P0:

- chat.

Remote P1 bila stabil:

- recovery;
- commitments;
- professionals;
- simulations.

---

# Day 6 — Integration, QA, Demo, Handoff

## Goal

Mengubah kumpulan feature menjadi aplikasi yang benar-benar dapat dipakai.

## Parts

- Part 15: full integration
- Part 16: QA and demo hardening
- Part 17: documentation and handoff

## Deliverables

- all route walkthrough;
- hybrid config final;
- network/error mapping;
- integration tests;
- visual QA;
- performance pass;
- mock reset;
- demo fixture;
- build APK;
- known issues;
- recording rehearsal.

## Acceptance

- critical integration tests pass;
- no analyzer error;
- no P0 dead end;
- no sensitive log;
- all screens reachable;
- demo completes twice consecutively;
- mock fallback works;
- build artifact installs.

## Freeze rule

Enam jam terakhir:

- tidak menambah feature besar;
- hanya bug P0/P1, copy, visual issue, dan build;
- perubahan contract harus ditolak atau ditunda kecuali benar-benar blocking.

## Final integration matrix

| Domain | Mock | Remote | Tested |
|---|---|---|---|
| auth | yes | yes | yes |
| family | yes | yes | yes |
| dashboard | yes | yes | yes |
| transactions | yes | yes | yes |
| statement | yes | yes | yes |
| check-in | yes | yes | yes |
| assessment | yes | yes | yes |
| chat | yes | yes | yes |
| goals | yes | preferred | yes |
| professionals | yes | optional | yes |
| simulation | yes | optional | yes |
| recovery | yes | optional | smoke |
| settings | local/mock | n/a | yes |

## Risk register

### Backend not ready

Mitigation:

- mock first;
- hybrid per domain;
- fixture contract;
- explicit demo mode.

### API schema mismatch

Mitigation:

- fail fast mapping;
- contract test;
- no silent fallback;
- issue list with request ID and sample payload.

### AI latency

Mitigation:

- meaningful processing state;
- timeout;
- retry;
- mock deterministic fallback for demo build.

### UI scope too broad

Mitigation:

- use design system;
- reuse components;
- defer animation;
- enforce P0/P1/P2.

### Agent changes too many files

Mitigation:

- work part scope;
- stop after part;
- verify before proceeding;
- avoid parallel edit on router/theme/core API.

## Daily report template

```markdown
# Day N Report

## Goal
...

## Completed
...

## Integrated
...

## Verified
...

## Blockers
...

## Contract Issues
...

## Carry Over
...

## Build Status
...
```
