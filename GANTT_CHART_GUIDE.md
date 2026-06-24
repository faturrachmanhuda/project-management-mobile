# Gantt Chart Integration Guide

## Overview

Gantt Chart widget telah diperbarui dengan desain yang lebih modern dan responsif, dengan support untuk update real-time menggunakan Provider.

## Fitur Utama

✅ Desain modern yang sesuai dengan gambar referensi Anda  
✅ Responsive - horizontal scrollable untuk dataset besar  
✅ Real-time updates menggunakan Provider  
✅ Menampilkan timeline tasks dengan bar chart  
✅ Identifikasi hari libur (weekend) dengan warna berbeda  
✅ Tooltip untuk informasi tanggal detail

## Cara Penggunaan

### 1. Penggunaan Dasar

```dart
import 'package:flutter/material.dart';
import 'view/gantt_chart_widget.dart';
import 'models/modelbikinproyek.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // List of ItemPekerjaan dari API/database Anda
    List<ItemPekerjaan> tasks = [...];

    return Scaffold(
      body: SimpleGanttChart(jobs: tasks),
    );
  }
}
```

### 2. Integrasi dengan Provider (Real-Time Updates)

```dart
import 'package:provider/provider.dart';
import 'viewmodel/bikinproyek_viewmodel.dart';

class ProjectDetailPage extends StatelessWidget {
  final String projectId;

  const ProjectDetailPage({required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProyekViewModel>(
      builder: (context, viewModel, _) {
        // Otomatis rebuild ketika daftarProyek berubah
        final proyek = viewModel.daftarProyek.firstWhere(
          (p) => p.id == projectId,
        );

        return Scaffold(
          body: SimpleGanttChart(jobs: proyek.daftarPekerjaan),
        );
      },
    );
  }
}
```

### 3. Menggunakan GanttChartExamplePage (Ready-to-use)

```dart
// Import
import 'view/gantt_chart_example.dart';

// Navigasi ke halaman
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => GanttChartExamplePage(
      proyekId: 'your-project-id',
    ),
  ),
);
```

## Integrasi ke Halaman Existing

### Option A: Tambah ke View Project Page

Edit `lib/view/view_project_page.dart`:

```dart
import 'view/gantt_chart_widget.dart';

// Di dalam build method, setelah menampilkan list pekerjaan:
if (vm.selectedProyek != null &&
    vm.selectedProyek!.daftarPekerjaan.isNotEmpty) {
  SimpleGanttChart(jobs: vm.selectedProyek!.daftarPekerjaan),
}
```

### Option B: Tambah ke Project Management Page

Edit `lib/features/project_management/views/project_management_page.dart`:

```dart
import '../../view/gantt_chart_widget.dart';

// Di dalam _projectTile() method, tambahkan:
children: [
  // Existing children...

  // Tambahkan Gantt Chart
  if (project.works.isNotEmpty)
    Padding(
      padding: const EdgeInsets.all(16),
      child: SimpleGanttChart(jobs: project.works),
    ),
]
```

## Structure Gantt Chart

```
├── SimpleGanttChart (Main Widget)
│   └── _GanttChartContent (Layout Manager)
│       ├── _HeaderRow (Date Header)
│       └── _TaskRow[] (Task Rows)
│           ├── _GridBackground (Grid Lines)
│           └── _TaskBar (Task Bar)
```

## Customization

### Mengubah Warna Bar

Di `_TaskBar` widget, ubah properti `color`:

```dart
color: const Color(0xFFEF4444), // Ganti warna sini
```

### Mengubah Lebar Kolom

Di `_GanttChartContent`, ubah `dayWidth`:

```dart
final dayWidth = 80.0; // Ubah dari 60.0 ke nilai yang diinginkan
```

### Mengubah Tinggi Task Row

Di `_TaskRow`, ubah `height` di `SizedBox`:

```dart
height: 40, // Ubah dari 32 ke nilai yang diinginkan
```

## Real-Time Update Flow

```
1. Data di ProyekViewModel berubah
   ↓
2. ProyekViewModel.notifyListeners() dipanggil
   ↓
3. Consumer<ProyekViewModel> merender ulang
   ↓
4. SimpleGanttChart menerima jobs data baru
   ↓
5. Widget rebuild dengan animasi smooth
```

## Troubleshooting

### Issue: Gantt Chart tidak menampilkan bars

**Solution:** Pastikan tanggal dalam format yang benar:

- Format: `YYYY-MM-DD` (contoh: 2026-05-22)
- Cek: `itemPekerjaan.tanggalMulai` dan `itemPekerjaan.tanggalSelesai`

### Issue: Text tasks terpotong

**Solution:** Ubah lebar kolom nama task:

```dart
// Di _HeaderRow dan _TaskRow, ubah width
SizedBox(
  width: 150, // Tingkatkan dari 120
  child: ...
)
```

### Issue: Scroll horizontal tidak smooth

**Solution:** Pastikan menggunakan `SingleChildScrollView` dengan `scrollDirection: Axis.horizontal`

## Dependencies

```yaml
provider: 6.1.1 # Untuk real-time updates
flutter: sdk # Material Design
```

Tidak ada package tambahan yang diperlukan! Gantt Chart widget ini menggunakan hanya Flutter built-in widgets.

## Next Steps

1. ✅ Copy contoh code ke halaman Anda
2. ✅ Test dengan data proyek yang ada
3. ✅ Customize warna & styling sesuai brand guidelines
4. ✅ Monitor performance jika data tasks > 100 items

---

Updated: 2026-05-22
