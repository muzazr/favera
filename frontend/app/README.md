# Favera Antigravity Context Pack

Paket ini menjadi konteks kerja utama untuk pengembangan frontend Flutter Favera.

## Tujuan

Membangun aplikasi Favera hingga tingkat kesiapan sekitar **70–80%** dalam sprint enam hari, termasuk:

- seluruh alur utama dapat dijalankan;
- mock API stateful mengikuti kontrak public API final;
- integrasi frontend, backend Express, dan AI service pada alur prioritas;
- tampilan cukup dekat dengan mockup untuk demonstrasi GEMASTIK;
- fondasi kode dapat dilanjutkan menjadi produk penuh tanpa penulisan ulang besar.

## Cara menggunakan

Salin seluruh isi folder ini ke root repository Flutter.

```text
repository/
├── AGENTS.md
├── docs/
└── .agents/
    └── rules/
```

Antigravity wajib membaca `AGENTS.md` terlebih dahulu. Dokumen tersebut menunjuk urutan bacaan dan aturan yang berlaku.

## Dokumen

| Berkas | Fungsi |
|---|---|
| `AGENTS.md` | Entry point dan instruksi utama agent |
| `docs/PROJECT_CONTEXT.md` | Konteks produk, pengguna, batasan, target |
| `docs/FRONTEND_ARCHITECTURE.md` | Arsitektur Flutter dan struktur kode |
| `docs/DESIGN_BRIEF.md` | Deskripsi visual tekstual agar tidak bergantung pada gambar |
| `docs/API_CONTRACT_AND_MOCKING.md` | Kontrak API, mock, mode remote, dan integrasi |
| `docs/ENGINEERING_RULES.md` | Aturan implementasi dan kualitas |
| `docs/DEMO_SCENARIO.md` | Skenario data dan alur demonstrasi |
| `docs/SPRINT_6_DAY_EXECUTION.md` | Rencana sprint enam hari |
| `docs/WORK_PARTS.md` | Pembagian pekerjaan per part untuk Antigravity |

## Sumber utama

- `UI SO FAR.pdf`, halaman 1–4.
- `PengembanganPerangkatLunak_IkiAeSerius_MuhammadZakiAzhar.pdf`, terutama halaman 6–26.
- `README-contract-decisions.md`.
- `favera-public-api-v0.1.openapi.json`.
- `favera-ai-service-v0.1.openapi.json`.
- `ESTATEMEN.docx` sebagai contoh Mandiri, BRI, dan GoPay.

Kontrak public API dan internal AI API diperlakukan sebagai **baseline final sprint**. Jangan menyebutnya draft di implementasi atau dokumentasi frontend.
