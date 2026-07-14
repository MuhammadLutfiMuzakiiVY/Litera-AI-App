# Software Requirement Specification

## 1. Tujuan

LITERA-AI adalah aplikasi mobile pembelajaran adaptif berbasis AI prediktif untuk membantu siswa SMP/SMA meningkatkan literasi membaca kritis dan penalaran logis-matematis melalui asesmen diagnostik, learning path adaptif, quiz adaptif, dan dashboard guru.

## 2. Aktor

| Aktor | Deskripsi | Prioritas |
| --- | --- | --- |
| Siswa | Mengikuti asesmen, modul belajar, quiz, dan melihat progres pribadi. | MVP |
| Guru | Memantau progres kelas, melihat profil siswa, dan menerima rekomendasi intervensi. | MVP |
| Admin | Mengelola akun, kelas, konten, dan monitoring sistem. | Pendukung |
| System AI | Mengklasifikasi profil, memperbarui knowledge state, dan menentukan difficulty. | MVP |

## 3. Functional Requirements

| ID | Kebutuhan | Prioritas | Acceptance Criteria |
| --- | --- | --- | --- |
| FR-001 | Aplikasi menampilkan splash screen dan mengecek status sesi. | Must | User diarahkan ke onboarding, auth, profile completion, assessment, atau dashboard sesuai state. |
| FR-002 | Aplikasi menampilkan onboarding singkat. | Must | Onboarding hanya muncul untuk pengguna baru atau jika flag lokal belum selesai. |
| FR-003 | User dapat register dengan email, password, role, dan profil dasar. | Must | Input divalidasi, password policy diterapkan, OTP email dikirim. |
| FR-004 | User dapat login memakai email/password. | Must | Access token dan refresh token tersimpan di secure storage. |
| FR-005 | User harus verifikasi email OTP. | Must | OTP expired ditolak, retry/resend dibatasi rate limit. |
| FR-006 | User melengkapi profil. | Must | Siswa mengisi jenjang, kelas, sekolah opsional, preferensi belajar; guru mengisi sekolah dan mata pelajaran. |
| FR-007 | Siswa mengerjakan AI diagnostic assessment. | Must | Pertanyaan dipaginasi, jawaban tersimpan lokal sementara, submit idempotent. |
| FR-008 | Backend/edge model mengklasifikasi profil siswa dengan 1D-CNN. | Must | Hasil profil menyimpan confidence, model version, dan timestamp. |
| FR-009 | Sistem membuat learning path awal. | Must | Learning path berisi konsep, urutan modul, difficulty awal, dan target mastery. |
| FR-010 | Siswa dapat membuka modul pembelajaran adaptif. | Must | Konten mendukung text, gambar terkompresi/cache, contoh STEM, dan checkpoint. |
| FR-011 | Siswa mengerjakan quiz adaptif. | Must | Soal menyesuaikan difficulty berdasarkan DDA dan knowledge state. |
| FR-012 | Sistem mengevaluasi hasil dan memperbarui LSTM-DKT. | Must | Knowledge state berubah setelah submit, event tercatat untuk audit. |
| FR-013 | DDA menyesuaikan difficulty berikutnya. | Must | Difficulty naik/turun/stabil berdasarkan aturan dan confidence. |
| FR-014 | Dashboard siswa menampilkan progres, streak, mastery, dan rekomendasi berikutnya. | Must | Loading, empty, error, retry tersedia. |
| FR-015 | Dashboard guru menampilkan kelas, peta kompetensi, siswa berisiko, dan rekomendasi intervensi. | Must | Data dapat difilter per kelas, konsep, dan rentang waktu. |
| FR-016 | Aplikasi mendukung offline first. | Must | Konten yang sudah diunduh dapat dibuka offline; event belajar disinkronkan saat online. |
| FR-017 | Push notification dan local reminder tersedia. | Should | Notifikasi tugas, reminder belajar, dan intervensi guru dapat dikirim. |
| FR-018 | User dapat logout dengan revoke refresh token. | Must | Token lokal dibersihkan dan session server direvoke. |

## 4. Non-Functional Requirements

| ID | Kebutuhan | Target |
| --- | --- | --- |
| NFR-001 | Startup performance | Cold start p95 < 2 detik pada perangkat target. |
| NFR-002 | Runtime performance | Scroll 60 FPS pada list dashboard dan modul. |
| NFR-003 | Memory | Aman pada Android RAM 2GB dengan lazy loading dan disposal controller. |
| NFR-004 | Offline first | Queue event lokal, conflict handling, dan retry exponential backoff. |
| NFR-005 | API latency | p95 REST < 500 ms untuk endpoint normal; AI inference <= 200 ms target model. |
| NFR-006 | Reliability | Crash-free sessions >= 99.5% pada pilot. |
| NFR-007 | Accessibility | Minimum WCAG 2.1 AA untuk kontras, semantic labels, text scale, dan focus order. |
| NFR-008 | Security | HTTPS only, JWT, refresh rotation, secure storage, certificate pinning, AES local encryption. |
| NFR-009 | Observability | Structured logs, crash reports, analytics event, API tracing, model inference audit. |
| NFR-010 | Maintainability | Clean Architecture, feature-first modules, generated models, lint strict. |

## 5. Security Requirements

- JWT access token pendek umur.
- Refresh token rotation dan revocation.
- Flutter Secure Storage untuk token.
- AES encryption untuk cache sensitif.
- HTTPS only dan certificate pinning pada client.
- SQLAlchemy parameter binding untuk proteksi SQL injection.
- Pydantic validation pada semua input API.
- CSRF protection untuk endpoint cookie-based jika digunakan; mobile API default bearer token.
- XSS protection untuk admin/web surface dan sanitasi rich content.
- Rate limiting berbasis Redis untuk login, OTP, refresh, dan submit assessment.
- Audit log untuk auth, profil, assessment, AI inference, dan teacher access.

## 6. Data Requirements

Data utama:

- User, role, profile, school, class.
- Diagnostic assessment, question, answer, result.
- Learning path, module, lesson content, quiz, attempt.
- Knowledge state, concept mastery, DDA decision.
- Teacher intervention recommendation.
- Offline sync event.
- Notification device token.

Data privacy:

- Data siswa untuk training model harus dianonimkan.
- PII dipisahkan secara logis dari event belajar.
- Export data pilot harus memakai student pseudonym.

## 7. State Requirements

Setiap proses harus memiliki:

- Loading state.
- Empty state.
- Error state.
- Retry mechanism.
- Local optimistic state jika aman.
- Structured logging.

## 8. Constraints

- Android 8+.
- iOS 15+.
- Perangkat Android RAM 2GB.
- Tidak ada business logic di UI.
- AI inti bersifat prediktif, bukan generative AI.
- Implementasi kode menunggu approval paket desain.

## 9. Assumptions

- Email OTP provider tersedia melalui backend.
- Konten pembelajaran awal disediakan oleh tim pedagogis.
- Dataset awal dapat berasal dari ASSISTments/EdNet, data sintetis, dan data pilot yang dianonimkan.
- TensorFlow Lite dipakai untuk model yang cukup kecil; fallback inference tetap tersedia di backend.

## 10. Acceptance Gate

SRS dianggap disetujui jika:

- Scope MVP dan aktor disepakati.
- Target performa realistis untuk fase pilot.
- Risiko privasi dan AI disetujui.
- API dan database sudah selaras dengan fitur MVP.
