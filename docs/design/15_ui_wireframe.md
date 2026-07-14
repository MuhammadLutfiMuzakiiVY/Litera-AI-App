# UI Wireframe

Wireframe ini adalah low-fidelity blueprint untuk aplikasi mobile. Visual final mengikuti design system pada dokumen berikutnya.

## 1. Splash

```text
+--------------------------------+
|                                |
|            LITERA-AI           |
|     Literacy Intelligent       |
|          Assistant             |
|                                |
|        [loading indicator]     |
|                                |
+--------------------------------+
```

## 2. Onboarding

```text
+--------------------------------+
| [Illustration / learning image]|
|                                |
| Belajar sesuai kemampuanmu     |
| Materi dan quiz akan           |
| menyesuaikan progres belajar.  |
|                                |
|   o   o   o                    |
|                                |
| [Lewati]              [Lanjut] |
+--------------------------------+
```

## 3. Login / Register

```text
+--------------------------------+
| LITERA-AI                      |
| Masuk ke akun                  |
|                                |
| Email                          |
| [__________________________]   |
| Password                       |
| [__________________________]   |
|                                |
| [ Masuk ]                      |
|                                |
| Belum punya akun? Daftar       |
+--------------------------------+
```

## 4. Email OTP

```text
+--------------------------------+
| Verifikasi Email               |
| Kode dikirim ke email Anda.    |
|                                |
| [ _ ] [ _ ] [ _ ] [ _ ] [ _ ] [ _ ] |
|                                |
| [ Verifikasi ]                 |
| Kirim ulang dalam 00:45        |
+--------------------------------+
```

## 5. Complete Profile

```text
+--------------------------------+
| Lengkapi Profil                |
|                                |
| Nama lengkap                   |
| [__________________________]   |
| Peran                          |
| [ Siswa | Guru ]               |
| Jenjang/Kelas                  |
| [ Pilih ]                      |
| Preferensi belajar             |
| [Visual] [Teks] [Seimbang]     |
|                                |
| [ Simpan Profil ]              |
+--------------------------------+
```

## 6. Diagnostic Assessment

```text
+--------------------------------+
| Asesmen Diagnostik       06/20 |
| Progress bar                    |
|                                |
| Bacalah teks berikut...        |
| [content block]                |
|                                |
| Pertanyaan                     |
| [A. option]                    |
| [B. option]                    |
| [C. option]                    |
| [D. option]                    |
|                                |
| [Sebelumnya]          [Lanjut] |
+--------------------------------+
```

States:

- Loading: skeleton question card.
- Empty: "Soal belum tersedia".
- Error: retry with request id.
- Offline: answers queued indicator.

## 7. AI Diagnostic Result

```text
+--------------------------------+
| Profil Belajar                 |
|                                |
| Literasi: Developing Reader    |
| Numerasi: Transitional         |
| Confidence: 0.86               |
|                                |
| Fokus awal                     |
| - Inferensi teks               |
| - Soal cerita kontekstual      |
|                                |
| [Mulai Learning Path]          |
+--------------------------------+
```

## 8. Student Dashboard

```text
+--------------------------------+
| Halo, Lutfi              [bell]|
|                                |
| Progress Minggu Ini            |
| [mastery chart / progress]     |
|                                |
| Rekomendasi Berikutnya         |
| [Module card]                  |
|                                |
| Konsep Perlu Latihan           |
| [Inferensi Teks] [Soal Cerita] |
|                                |
| Bottom nav: Home Path History  |
+--------------------------------+
```

## 9. Adaptive Module

```text
+--------------------------------+
| < Modul                        |
| Inferensi Teks dalam STEM      |
| Difficulty: Medium             |
|                                |
| [Image / diagram cached]       |
|                                |
| Content paragraph...           |
| Example block...               |
|                                |
| [Checkpoint]                   |
| [Mulai Quiz]                   |
+--------------------------------+
```

## 10. Adaptive Quiz Evaluation

```text
+--------------------------------+
| Hasil Quiz                     |
| Skor: 80                       |
| Mastery: 0.74                  |
|                                |
| Difficulty berikutnya: Medium  |
| Alasan: pertahankan latihan    |
| untuk menguatkan konsep.       |
|                                |
| [Lanjut Belajar] [Ulangi]      |
+--------------------------------+
```

## 11. Teacher Dashboard

```text
+--------------------------------+
| Dashboard Guru           [bell]|
| Kelas: VIII A                  |
|                                |
| Ringkasan                      |
| [Avg mastery] [At risk]        |
|                                |
| Siswa Prioritas                |
| [Nama] [Risk] [Konsep]         |
| [Nama] [Risk] [Konsep]         |
|                                |
| Peta Kompetensi                |
| [concept heatmap]              |
|                                |
| Bottom nav: Home Classes Intv  |
+--------------------------------+
```

## 12. Student Progress Detail for Teacher

```text
+--------------------------------+
| < Detail Siswa                 |
| Nama Siswa                     |
| Risk: High                     |
|                                |
| Mastery per konsep             |
| [chart/list]                   |
|                                |
| Rekomendasi Intervensi         |
| - Remedial inferensi teks      |
| - Diskusi berpasangan          |
|                                |
| [Tandai Ditindaklanjuti]       |
+--------------------------------+
```

## 13. Settings

```text
+--------------------------------+
| Pengaturan                     |
| Profil                         |
| Notifikasi                     |
| Mode Tampilan                  |
| Unduh Konten Offline           |
| Privasi dan Keamanan           |
|                                |
| [Logout]                       |
+--------------------------------+
```

## 14. Responsive Behavior

- Phone portrait: single column, bottom navigation.
- Phone landscape: compact top app bar, content retains readable width.
- Tablet: two-pane teacher dashboard when width allows.
- iOS: Cupertino back gesture, native switch/date picker feel where appropriate.
- Android: Material navigation bar, Material motion, platform back behavior.

## 15. Accessibility

- Minimum tap target 48x48 dp.
- Text scale up to 200% without clipped critical content.
- Semantic labels for icon buttons.
- High contrast mode compatible.
- Error text must not rely only on color.
