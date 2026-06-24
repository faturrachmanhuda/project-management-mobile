<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Django-092E20?style=for-the-badge&logo=django&logoColor=white" />
  <img src="https://img.shields.io/badge/REST_API-FF6F00?style=for-the-badge&logo=fastapi&logoColor=white" />
</p>

# 📋 Project Management — Mobile

> **Subsistem Manajemen Proyek & Aktivitas Kerja**
> 
> Bagian dari ekosistem **Intelligence Engineerings** — Platform Terintegrasi untuk Siklus Hidup Pengembangan Kecerdasan Buatan.

---

## 📖 Tentang Proyek

**Intelligence Engineerings** adalah sebuah platform terintegrasi yang dirancang untuk mendukung seluruh siklus hidup (*lifecycle*) pengembangan proyek berbasis kecerdasan buatan (AI). Platform ini dikembangkan sebagai bagian dari mata kuliah **Praktikum Rekayasa Perangkat Lunak** di **Universitas Trisakti**, dengan tujuan memberikan pengalaman langsung kepada mahasiswa dalam membangun sistem perangkat lunak berskala besar yang saling terintegrasi.

Platform ini terdiri dari **5 subsistem** yang masing-masing menangani fase berbeda dalam *lifecycle* pengembangan AI:

| # | Subsistem | Deskripsi |
|---|-----------|-----------|
| 1 | **Intelligence Engineering** | Perencanaan & perancangan blueprint proyek AI |
| 2 | **Project Management** | Manajemen proyek, tugas, dan timeline |
| 3 | **Intelligence Creation** | Pembuatan & pelatihan model machine learning |
| 4 | **Dataset Management** | Pengelolaan dataset dan distribusi data |
| 5 | **Implementation** | Deployment, monitoring, dan pemeliharaan model AI |

Aplikasi mobile ini merupakan **companion app** untuk subsistem **Project Management**, yang memungkinkan manajer proyek untuk memantau progres, mengelola tugas, dan menerima update integrasi dari seluruh subsistem secara *real-time*.

---

## ✨ Fitur Utama

- 📊 **Dashboard Proyek** — Ringkasan status seluruh proyek AI dalam satu tampilan
- 📝 **Work Activity Management** — Kelola pekerjaan dan aktivitas dengan detail lengkap
- 📈 **Timeline & Progress Tracking** — Monitor progres proyek dengan grafik interaktif
- 📄 **Task Reporting** — Generate laporan tugas dan aktivitas kerja
- 🔔 **Real-time Notifications** — Terima notifikasi dari subsistem terintegrasi
- 🔗 **Cross-System Integration** — Sinkronisasi otomatis dengan Engineering, Creation, & Implementation
- 📱 **Responsive Design** — UI modern dengan Material Design 3

---

## 🛠️ Tech Stack

| Teknologi | Versi | Keterangan |
|-----------|-------|------------|
| Flutter | 3.x | Framework UI cross-platform |
| Dart | 3.x | Bahasa pemrograman |
| Provider | Latest | State management |
| HTTP | Latest | REST API communication |
| SQLite | Latest | Local database |
| Django REST API | 5.x | Backend server |

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- [Android Studio](https://developer.android.com/studio) atau [VS Code](https://code.visualstudio.com/)
- Android Emulator atau physical device

### Installation

```bash
# Clone repository
git clone https://github.com/faturrachmanhuda/project-management-mobile.git

# Masuk ke direktori proyek
cd project-management-mobile

# Install dependencies
flutter pub get

# Jalankan aplikasi
flutter run
```

### Konfigurasi API

Sesuaikan base URL API di `lib/services/api_config.dart`:
```dart
static const String baseUrl = 'http://38.47.94.194/tif2/pm';
```

---

## 📁 Struktur Proyek

```
lib/
├── main.dart                         # Entry point
├── about_page.dart                   # Halaman tentang
├── models/                           # Data models
│   ├── activity_model.dart
│   ├── proyek_model.dart
│   ├── pekerjaan_model.dart
│   ├── note_model.dart
│   └── user.dart
├── services/                         # API & business logic
│   ├── api_config.dart
│   └── project_service.dart
├── features/                         # Feature modules
│   └── project_management/
│       ├── models/
│       ├── repositories/
│       ├── viewmodels/
│       └── views/
├── view/                             # UI screens
│   ├── project_detail_page.dart
│   ├── work_detail_page.dart
│   └── task_report_page.dart
└── database/                         # Local storage
    └── db_helper.dart
```

---

## 📚 Dokumentasi

| Dokumen | Link |
|---------|------|
| 📘 User Guide | [Download PDF](https://drive.google.com/file/d/1obTTjqjNEa90zDH8pmakdq8ZMTkkvknY/view?usp=sharing) |
| 📐 UML Diagrams (APPL) | [Download PDF](https://drive.google.com/file/d/16yh5spR06qp6fMkeIMKSiF4Z6tvOAoV-/view?usp=sharing) |
| 🎨 Figma Design | [Open in Figma](https://www.figma.com/make/gy9RAk5Z3E8Ok2muvBLPL3/Landing-page-design?t=Zs60uOBNHtD5dP2n-20&fullscreen=1) |
| 🌐 Web Demo | [Open Web App](http://38.47.94.194/tif2/pm/) |

> **User Guide** berisi panduan lengkap penggunaan aplikasi, termasuk langkah-langkah manajemen proyek, navigasi fitur, dan troubleshooting umum.
>
> **UML Diagrams (APPL)** berisi dokumentasi arsitektur sistem yang mencakup Use Case Diagram, Sequence Diagram, Activity Diagram, Class Diagram, dan Component Diagram.

---

## 🔗 Subsistem Terkait

| Subsistem | Repository | Web Demo |
|-----------|------------|----------|
| Intelligence Engineering | [GitHub](https://github.com/faturrachmanhuda/intelligence-engineering-mobile) | [🌐 Demo](http://38.47.94.194/tif2/engineering/) |
| Project Management | 📍 *You are here* | [🌐 Demo](http://38.47.94.194/tif2/pm/) |
| Intelligence Creation | [GitHub](https://github.com/faturrachmanhuda/intelligence-creation-mobile) | [🌐 Demo](http://38.47.94.194/tif2/creation/) |
| Dataset Management | [GitHub](https://github.com/faturrachmanhuda/dataset-management-mobile) | [🌐 Demo](http://38.47.94.194/tif2/dataset/) |
| Implementation | [GitHub](https://github.com/faturrachmanhuda/implementation-mobile) | [🌐 Demo](http://38.47.94.194/tif2/implementation/) |

---

## 👥 Tim Pengembang

Dikembangkan oleh mahasiswa **Universitas Trisakti** — Fakultas Teknologi Industri, Program Studi Teknik Informatika.

---

## 📄 Lisensi

Proyek ini dikembangkan untuk keperluan akademis dalam rangka mata kuliah **Praktikum Rekayasa Perangkat Lunak**.

---

<p align="center">
  <b>Intelligence Engineerings</b> — Integrated AI Development Lifecycle Platform<br/>
  <sub>Universitas Trisakti • 2024/2025</sub>
</p>
