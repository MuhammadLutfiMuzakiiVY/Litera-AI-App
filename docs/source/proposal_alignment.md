# Proposal Alignment

Dokumen ini menerjemahkan proposal LITERA-AI menjadi rancangan aplikasi mobile produksi.

## Ringkasan Proposal

LITERA-AI adalah platform pembelajaran adaptif berbasis deep learning untuk mengatasi krisis literasi membaca kritis dan penalaran logis-matematis siswa Indonesia. Sistem menggunakan:

- 1D-CNN untuk klasifikasi profil literasi dan numerasi dari asesmen diagnostik.
- LSTM Deep Knowledge Tracing untuk melacak penguasaan konsep secara sekuensial.
- Dynamic Difficulty Adjustment untuk memilih tingkat kesulitan konten berikutnya.
- Dashboard Guru untuk monitoring progres dan rekomendasi intervensi.

Target proposal:

- F1-Score diagnostik >= 85%.
- Latensi inferensi <= 200 ms.
- SUS >= 70.
- Peningkatan skor literasi dan numerasi minimal 15% pada pilot satu semester.

## Adaptasi Dari Proposal Ke Prompt Mobile

Proposal awal menyebut frontend web responsif React.js. Prompt pengembangan saat ini menetapkan aplikasi mobile Flutter Android dan iOS. Keputusan desain:

- Flutter menjadi client utama.
- Backend FastAPI menjadi sumber kebenaran data, autentikasi, sinkronisasi, dan inferensi server-side.
- TensorFlow Lite disiapkan untuk inferensi edge/offline pada perangkat yang memenuhi syarat.
- Web dashboard dapat menjadi fase lanjutan; MVP tetap menyediakan dashboard guru mobile/tablet di Flutter.

## Scope MVP

MVP kompetisi dan pilot:

- Splash, onboarding, login, register, verifikasi email OTP.
- Lengkapi profil siswa/guru.
- Asesmen diagnostik literasi dan numerasi.
- Klasifikasi profil siswa.
- Learning path awal.
- Modul belajar adaptif.
- Quiz adaptif.
- Knowledge tracing dan DDA.
- Dashboard siswa.
- Dashboard guru untuk kelas, progres siswa, risiko, dan rekomendasi intervensi.
- Riwayat pembelajaran dan pengaturan akun.
- Offline first untuk konten yang sudah tersinkron.

## Scope Lanjutan

- Admin panel skala sekolah/dinas.
- Manajemen konten skala besar.
- A/B testing algoritma rekomendasi.
- Multi-school analytics.
- Integrasi SSO sekolah.
- Payment atau monetisasi, jika produk dikomersialisasi.

## Prinsip Produk

- AI harus dapat dijelaskan secara pedagogis.
- Tidak memakai generative AI sebagai fitur inti produk.
- Data siswa harus dianonimkan untuk pelatihan model.
- UX harus ringan untuk perangkat Android RAM 2GB.
- Aplikasi harus tetap bermanfaat saat koneksi buruk.
