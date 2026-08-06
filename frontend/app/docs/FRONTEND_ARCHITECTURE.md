# Frontend Architecture — Flutter

## 1. Tujuan arsitektur

Arsitektur harus mendukung dua kebutuhan yang biasanya saling berkelahi:

1. cepat dibangun dalam sprint enam hari;
2. cukup bersih untuk diteruskan setelah GEMASTIK.

Gunakan arsitektur **feature-first, layered, pragmatic**. Hindari Clean Architecture seremonial dengan puluhan file untuk memindahkan satu string.

## 2. Diagram konteks

```text
Flutter App
    |
    | HTTPS REST
    v
Express.js Public Backend
    |-- authentication dan authorization
    |-- family workflow
    |-- persistence
    |-- Supabase PostgreSQL dan Storage
    |-- business rules
    |
    | private HTTP
    v
FastAPI AI Service
    |-- statement parsing
    |-- anomaly inference
    |-- family risk assessment
    |-- structured LLM output
```

Flutter tidak mengetahui implementasi internal FastAPI atau Supabase.

## 3. Layer frontend

```text
Presentation
  Pages, widgets, route rendering
        ↓
Application
  Riverpod Notifier/AsyncNotifier, state, orchestration
        ↓
Data
  Repository contract + mock/remote implementation
        ↓
Infrastructure
  Dio, secure storage, preferences, file access
```

Domain/use-case layer boleh ditambahkan hanya ketika satu feature mempunyai business rule yang benar-benar kompleks dan digunakan oleh lebih dari satu controller.

## 4. Struktur folder

```text
lib/
├── main.dart
├── bootstrap.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── route_names.dart
│   │   └── route_redirect.dart
│   └── theme/
│       ├── app_colors.dart
│       ├── app_spacing.dart
│       ├── app_radius.dart
│       ├── app_typography.dart
│       └── app_theme.dart
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   ├── api_error_mapper.dart
│   │   ├── auth_interceptor.dart
│   │   └── request_id_interceptor.dart
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── app_environment.dart
│   │   └── data_source_mode.dart
│   ├── errors/
│   ├── formatters/
│   ├── storage/
│   ├── logging/
│   └── widgets/
├── features/
│   ├── onboarding/
│   ├── auth/
│   ├── profile/
│   ├── family/
│   ├── dashboard/
│   ├── transactions/
│   ├── statement_import/
│   ├── goals/
│   ├── check_in/
│   ├── family_assessment/
│   ├── recovery/
│   ├── commitments/
│   ├── ai_chat/
│   ├── professionals/
│   ├── consultations/
│   ├── simulations/
│   ├── notifications/
│   └── settings/
├── mock/
│   ├── mock_backend.dart
│   ├── mock_clock.dart
│   ├── mock_scenario.dart
│   ├── mock_store.dart
│   └── fixtures/
└── shared/
    ├── models/
    ├── widgets/
    └── extensions/
```

Struktur feature:

```text
features/statement_import/
├── data/
│   ├── models/
│   ├── statement_repository.dart
│   ├── mock_statement_repository.dart
│   ├── remote_statement_repository.dart
│   └── statement_api.dart
├── application/
│   ├── statement_import_controller.dart
│   ├── statement_import_state.dart
│   └── statement_import_providers.dart
└── presentation/
    ├── pages/
    └── widgets/
```

## 5. Package

### Runtime

```yaml
dependencies:
  flutter_riverpod:
  go_router:
  dio:
  json_annotation:
  file_picker:
  flutter_secure_storage:
  shared_preferences:
  intl:
  flutter_svg:
  url_launcher:
```

### Development

```yaml
dev_dependencies:
  build_runner:
  json_serializable:
  flutter_lints:
  mocktail:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
```

Tidak perlu menambahkan state manager kedua, router kedua, service locator kedua, atau database lokal besar.

## 6. Repository contract

Setiap feature memiliki satu contract yang dipakai mock dan remote.

```dart
abstract interface class DashboardRepository {
  Future<FinancialDashboard> getDashboard({
    DateTime? periodStart,
    DateTime? periodEnd,
  });
}
```

```dart
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final config = ref.watch(appConfigProvider);

  return switch (config.dataSourceFor(DataDomain.dashboard)) {
    DataSourceMode.mock => ref.watch(mockDashboardRepositoryProvider),
    DataSourceMode.remote => ref.watch(remoteDashboardRepositoryProvider),
  };
});
```

Widget tidak boleh melakukan:

```dart
if (isMock) { ... }
```

Pemilihan sumber data hanya di provider/composition root.

## 7. Mode mock, remote, hybrid

```dart
enum DataSourceMode { mock, remote }

enum DataDomain {
  auth,
  family,
  dashboard,
  transactions,
  statementImport,
  goals,
  checkIn,
  assessment,
  recovery,
  commitments,
  chat,
  professionals,
  consultations,
  simulations,
  notifications,
}
```

`hybrid` bukan mode pada repository. Hybrid adalah konfigurasi yang memetakan domain tertentu ke `remote` dan sisanya ke `mock`.

Contoh:

```text
auth               remote
family             remote
dashboard          remote
statementImport    remote
checkIn            remote
chat               remote
professionals      mock
simulations        mock
```

## 8. State management

Gunakan:

- `Notifier` untuk state sinkron;
- `AsyncNotifier` untuk fetch/mutate;
- immutable state;
- `AsyncValue` untuk loading/data/error;
- provider family untuk resource berbasis ID.

Controller menangani orchestration, bukan menggambar UI.

Contoh state statement import:

```dart
sealed class StatementFlowState {
  const StatementFlowState();
}

class StatementIdle extends StatementFlowState {}
class StatementSelectingFile extends StatementFlowState {}
class StatementUploading extends StatementFlowState {
  final double progress;
}
class StatementPolling extends StatementFlowState {
  final StatementImport import;
}
class StatementReviewReady extends StatementFlowState {
  final StatementImport import;
  final List<ParsedTransactionDraft> drafts;
}
class StatementFailure extends StatementFlowState {
  final AppFailure failure;
}
```

Gunakan state machine eksplisit untuk flow panjang. Jangan menyimpan lima boolean yang dapat menghasilkan kombinasi absurd seperti `isLoading == true` dan `isSuccess == true`.

## 9. Routing

Gunakan `go_router` dan shell untuk empat tab utama:

```text
/onboarding
/auth/login
/auth/register
/auth/forgot-password
/profile/setup
/family/connect
/family/invitation

/app
├── /home
├── /finance
│   ├── /transactions
│   ├── /transactions/new
│   ├── /transactions/:id
│   ├── /statements/upload
│   ├── /statements/:id/review
│   ├── /goals
│   ├── /goals/new
│   └── /goals/:id
├── /mediation
│   ├── /chat
│   ├── /chat/:sessionId
│   ├── /recovery
│   ├── /recovery/:id
│   ├── /professionals
│   ├── /professionals/:id
│   ├── /consultations
│   ├── /simulations/new
│   └── /simulations/:id
└── /profile
    ├── /settings
    ├── /privacy
    └── /family-settings
```

Redirect rules:

1. onboarding belum selesai → `/onboarding`;
2. belum login → `/auth/login`;
3. profil belum lengkap → `/profile/setup`;
4. pairing belum aktif → `/family/connect`;
5. setelah semua terpenuhi → `/app/home`.

Sediakan debug route catalog hanya pada build non-production agar semua screen dapat diperiksa cepat.

## 10. API client

`ApiClient` menangani:

- base URL;
- bearer token;
- refresh token;
- timeout;
- `request_id`;
- common error mapping;
- multipart;
- cancellation;
- optional retry hanya untuk request aman;
- `Idempotency-Key` pada write request yang rawan retry.

Jangan me-retry upload atau mutation tanpa idempotency key.

Error model frontend:

```dart
sealed class AppFailure {
  const AppFailure();
}

class NetworkFailure extends AppFailure {}
class UnauthorizedFailure extends AppFailure {}
class ForbiddenFailure extends AppFailure {}
class NotFoundFailure extends AppFailure {}
class ConflictFailure extends AppFailure {}
class ValidationFailure extends AppFailure {
  final Map<String, String> fields;
}
class ServerFailure extends AppFailure {
  final String? requestId;
}
class UnknownFailure extends AppFailure {}
```

UI menampilkan bahasa manusia. Log menyimpan `request_id`, bukan data sensitif.

## 11. Model dan serialization

- DTO mengikuti public API.
- Field transport tetap `snake_case`.
- Model view boleh menghitung presentational values.
- Money disimpan `int`.
- Jangan gunakan `double` untuk rupiah.
- Parsing date-time dilakukan terpusat.
- Jangan mengirim enum display label ke API.
- Unknown enum harus menghasilkan failure terkontrol, bukan crash acak.

Tidak wajib menghasilkan seluruh client OpenAPI. Untuk sprint, implementasikan typed API per feature dan jaga agar endpoint path tersentralisasi. Repository memisahkan UI dari keputusan tersebut.

## 12. Storage

### Secure storage

- access token;
- refresh token;
- optional secure session metadata.

### Shared preferences

- onboarding viewed;
- hide balance preference;
- selected theme;
- mock scenario;
- non-sensitive notification preference cache.

Dilarang menyimpan:

- password;
- PDF password;
- raw statement;
- check-in answer;
- chat content;
- reflection;
- token di preferences biasa.

## 13. Upload statement

Flow:

```text
select file
→ validate extension and size
→ POST /statement-imports
→ poll GET /statement-imports/{id}
→ if password_required, show password form
→ POST /unlock
→ poll until review_required
→ GET draft-transactions
→ PATCH review items
→ POST confirm
→ refresh dashboard and transactions
```

Polling:

- interval awal 1–2 detik;
- berhenti ketika status terminal;
- dapat dibatalkan saat page dispose;
- tampilkan status yang dapat dipahami;
- jangan menampilkan spinner tanpa penjelasan lebih dari beberapa detik.

## 14. Testing

Prioritas:

1. repository mapping;
2. auth refresh interceptor;
3. statement status machine;
4. check-in save/submit;
5. route redirect;
6. demo happy path;
7. safety copy dan privacy visibility.

Gunakan:

- unit test untuk mapper/controller;
- widget test untuk screen penting;
- integration test untuk alur demo.

## 15. Observability ringan

Pada development:

- log method, path, status, duration, request_id;
- redact token, password, chat, reflection, answer, document content;
- banner atau indicator mode mock/hybrid hanya pada debug build;
- feature flag panel hanya pada debug build.

## 16. Performance

- hindari fetch berulang ketika tab berpindah;
- gunakan pagination untuk list;
- gunakan `const` jika masuk akal;
- batasi rebuild dengan provider granular;
- kompres atau cache asset;
- jangan menaruh proses parsing PDF di Flutter;
- tampilkan skeleton/loading yang stabil;
- target respons UI lokal instan dan respons network utama terasa di bawah tiga detik pada koneksi stabil.
