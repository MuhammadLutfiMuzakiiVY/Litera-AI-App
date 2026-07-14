# Product Requirement Document

## 1. Product Vision

LITERA-AI membantu siswa Indonesia berpindah dari membaca mekanis ke membaca kritis, serta dari hafalan rumus ke penalaran logis-matematis kontekstual melalui pembelajaran adaptif yang ringan, aman, dan mudah dipakai guru.

## 2. Problem Statement

Siswa banyak yang bisa membaca secara teknis tetapi kesulitan memahami teks kompleks, menarik kesimpulan, dan memecahkan soal kontekstual. Platform digital yang ada cenderung statis, memberi materi seragam, dan tidak menyediakan intervensi berbasis profil kognitif individual.

## 3. Target Users

| Persona | Kebutuhan | Pain Point |
| --- | --- | --- |
| Siswa SMP/SMA | Belajar sesuai kemampuan dan mendapat tantangan bertahap. | Cepat bosan, takut salah, sulit memahami teks panjang dan soal cerita. |
| Guru Bahasa/Matematika | Memahami profil siswa dan menentukan intervensi. | Data tersebar, sulit melihat siswa berisiko secara cepat. |
| Admin Sekolah | Menyiapkan akun dan kelas. | Butuh setup sederhana dan aman. |

## 4. Product Goals

| Goal | Metric |
| --- | --- |
| Diagnostik profil siswa akurat. | F1-Score model >= 85% pada test set. |
| Pengalaman belajar responsif. | Startup p95 < 2 detik; scroll 60 FPS. |
| Mudah digunakan siswa dan guru. | SUS >= 70 pada pilot. |
| Efektif secara pedagogis. | Target peningkatan skor pre-test/post-test >= 15%. |
| Cocok untuk infrastruktur terbatas. | Offline module access dan sync event tersedia. |

## 5. MVP Features

### Student Experience

- Splash dan onboarding.
- Register, login, OTP, profile completion.
- Diagnostic assessment.
- Hasil profil dan learning path.
- Modul pembelajaran berbasis STEM.
- Quiz adaptif.
- Dashboard progres.
- Riwayat pembelajaran.
- Settings dan logout.

### Teacher Experience

- Login dan profile completion.
- Dashboard kelas.
- Daftar siswa dan risk flag.
- Detail progres per siswa.
- Rekomendasi intervensi.
- Riwayat pembelajaran siswa.

### Platform Experience

- Offline first untuk modul dan event belajar.
- Push notification dan local reminder.
- Analytics, crash reporting, structured logging.
- Admin support minimal untuk seed class/user/content.

## 6. User Stories

| ID | Story | Priority |
| --- | --- | --- |
| US-001 | Sebagai siswa, saya ingin mendaftar dan memverifikasi email agar akun saya aman. | Must |
| US-002 | Sebagai siswa, saya ingin mengerjakan asesmen awal agar aplikasi memahami kemampuan saya. | Must |
| US-003 | Sebagai siswa, saya ingin mendapat modul yang sesuai kemampuan agar tidak terlalu mudah atau terlalu sulit. | Must |
| US-004 | Sebagai siswa, saya ingin melihat progres agar saya tahu konsep mana yang sudah dikuasai. | Must |
| US-005 | Sebagai guru, saya ingin melihat siswa berisiko agar intervensi bisa cepat dilakukan. | Must |
| US-006 | Sebagai guru, saya ingin rekomendasi intervensi agar tindak lanjut lebih tepat. | Must |
| US-007 | Sebagai siswa, saya ingin belajar offline dari modul yang sudah tersimpan. | Should |
| US-008 | Sebagai admin, saya ingin mengelola kelas dan akun dasar. | Should |

## 7. Release Strategy

| Release | Scope | Outcome |
| --- | --- | --- |
| R0 Design | Dokumen desain, API, ERD, UI wireframe, sprint plan. | Approval implementasi. |
| R1 Foundation | Scaffolding Flutter/FastAPI, auth, theming, CI dasar. | App shell berjalan. |
| R2 Assessment | Diagnostic assessment, question engine, submit result. | Siswa dapat dinilai. |
| R3 Adaptive Learning | Learning path, modul, quiz, DDA rule engine. | Pembelajaran adaptif dasar. |
| R4 Teacher Dashboard | Monitoring kelas dan rekomendasi intervensi. | Guru dapat memantau. |
| R5 AI Hardening | 1D-CNN/TFLite, LSTM-DKT, model registry, evaluation. | AI tervalidasi awal. |
| R6 Pilot Readiness | Offline sync, security hardening, observability, QA. | Siap pilot terbatas. |

## 8. Prioritization

Must:

- Auth dan profile.
- Diagnostic assessment.
- Classification result.
- Learning path.
- Adaptive module dan quiz.
- Student dashboard.
- Teacher dashboard.
- Secure token handling.

Should:

- Offline sync lengkap.
- Push notification.
- TFLite edge inference.
- Admin seed tools.

Could:

- Multi-school analytics.
- Web admin.
- A/B testing DDA.

Won't for MVP:

- Generative AI tutor.
- Payment.
- Social feed.

## 9. Product Risks

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Dataset tidak cukup representatif. | Model bias dan F1 rendah. | Mulai dengan baseline, data sintetis terkendali, k-fold, dan evaluasi per kelas profil. |
| Latensi AI > 200 ms. | UX lambat. | Quantization, model caching, background inference, fallback backend. |
| Guru tidak percaya rekomendasi AI. | Adoption turun. | Tampilkan alasan rekomendasi berbasis indikator belajar. |
| Offline sync konflik. | Data progres salah. | Event-sourcing ringan, idempotency key, server reconciliation. |
| Perangkat low-end lambat. | Drop-off siswa. | Pagination, image cache, isolate untuk parsing berat, minimal animation. |

## 10. Success Criteria MVP

- User auth flow selesai tanpa bug kritis.
- Siswa dapat menyelesaikan asesmen dan menerima learning path.
- Quiz adaptif menghasilkan update knowledge state.
- Guru dapat melihat kelas dan siswa prioritas.
- Offline event queue tersinkron saat koneksi kembali.
- Crash-free session pilot >= 99.5%.
