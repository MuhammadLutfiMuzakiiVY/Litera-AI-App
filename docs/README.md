# LITERA-AI Design Pack

Dokumen ini adalah gerbang desain sebelum implementasi kode aplikasi mobile LITERA-AI. Implementasi Flutter, FastAPI, database, AI pipeline, dan DevOps baru boleh dimulai setelah dokumen ini direview dan disetujui.

## Dasar

- Proposal sumber: `C:\Users\muham\Downloads\PROPOSAL_LIDM_ITDP_LITERA-AI_Revisi.docx`
- Produk: LITERA-AI (Literacy Intelligent Assistant)
- Platform target: Android 8+ dan iOS 15+
- Mode AI: predictive deep learning, bukan generative AI
- Fokus awal: Siswa, Guru, dan Admin pendukung

## Indeks Artefak

1. [Software Requirement Specification](requirements/01_srs.md)
2. [Product Requirement Document](requirements/02_prd.md)
3. [System Architecture](architecture/03_system_architecture.md)
4. [Database Design dan ERD](database/04_database_design_erd.md)
5. [API Specification OpenAPI](api/05_openapi.yaml)
6. [Folder Structure](mobile/06_folder_structure.md)
7. [State Management Flow](mobile/07_state_management_flow.md)
8. [Navigation Flow](mobile/08_navigation_flow.md)
9. [User Flow](diagrams/09_user_flow.md)
10. [Use Case Diagram](diagrams/10_use_case_diagram.md)
11. [Activity Diagram](diagrams/11_activity_diagram.md)
12. [Sequence Diagram](diagrams/12_sequence_diagram.md)
13. [Class Diagram](diagrams/13_class_diagram.md)
14. [AI Workflow](ai/14_ai_workflow.md)
15. [UI Wireframe](design/15_ui_wireframe.md)
16. [Design System](design/16_design_system.md)
17. [Sprint Planning](planning/17_sprint_planning.md)
18. [Testing Strategy](testing/18_testing_strategy.md)

## Catatan Versi Stack

Versi final akan dipin saat scaffolding project supaya build reproducible. Acuan resmi yang dipakai untuk desain ini:

- Flutter stable channel direkomendasikan untuk produksi; dokumentasi resmi menunjukkan lini Flutter 3.44 dan jadwal rilis 2026.
- Python.org menunjukkan Python 3.14.6 sebagai latest stable source release, tetap kompatibel dengan requirement Python 3.13+.
- FastAPI release notes menunjukkan 0.139.0 (2026-07-01) sebagai rilis terbaru yang tercatat pada dokumen resmi.

## Approval Gate

Status saat ini: `DESIGN_READY_FOR_REVIEW`

Checklist sebelum implementasi:

- Semua artefak desain dibuat.
- Scope MVP dan non-MVP disepakati.
- Model data dan API disetujui.
- UI wireframe dan design system disetujui.
- Sprint 1 dipilih untuk implementasi.
