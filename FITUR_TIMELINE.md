# 📊 Fitur Timeline Grafik (Gantt Chart)

## Overview

Timeline grafik menampilkan visualisasi waktu pelaksanaan semua pekerjaan dalam sebuah proyek secara horizontal, memudahkan untuk melihat:
- Jadwal setiap pekerjaan
- Overlap/tumpang tindih waktu
- Durasi relatif antar pekerjaan
- Progress keseluruhan proyek

---

## Lokasi Tampilan

### Di Halaman Detail Proyek
File: `lib/view/project_detail_page.dart`

**Posisi:**
```
┌─────────────────────────────────────────┐
│  [Header Proyek]                        │
├─────────────────────────────────────────┤
│ [Info Card]  │  📊 [Timeline Card]      │
│ [Progress]   │  📋 [Daftar Pekerjaan]   │
└─────────────────────────────────────────┘
```

---

## Implementasi

### 1. Widget Timeline Card

```dart
Widget _buildTimelineCard(Proyek project) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _cardBorder),
    ),
    child: Column(
      children: [
        // Header dengan icon
        Row(
          children: [
            Icon(Icons.timeline, color: _maroon),
            Text('Timeline Pekerjaan'),
          ],
        ),
        
        // Gantt Chart Widget
        if (project.daftarPekerjaan.isNotEmpty)
          SimpleGanttChart(jobs: project.daftarPekerjaan)
        else
          EmptyState(),
      ],
    ),
  );
}
```

### 2. Gantt Chart Widget

File: `lib/view/gantt_chart_widget.dart`

**Input:**
- `List<ItemPekerjaan> jobs` - Daftar pekerjaan dalam proyek

**Output:**
- Visual timeline horizontal dengan bar untuk setiap pekerjaan
- Label tanggal mulai dan selesai
- Indicator progress

**Fitur:**
- ✅ Auto-calculate date range (min-max dari semua pekerjaan)
- ✅ Responsive width berdasarkan durasi
- ✅ Color coding per status
- ✅ Empty state handling
- ✅ Error handling untuk invalid dates

---

## Cara Kerja

### 1. Data Flow

```
Proyek Model
    ↓
project.daftarPekerjaan (List<ItemPekerjaan>)
    ↓
SimpleGanttChart Widget
    ↓
Calculate: minDate, maxDate, totalDays
    ↓
Render: horizontal bars per pekerjaan
```

### 2. Perhitungan Timeline

```dart
// Find min and max dates
for (var job in jobs) {
  DateTime start = DateTime.parse(job.tanggalMulai);
  DateTime end = DateTime.parse(job.tanggalSelesai);
  
  if (start.isBefore(minDate)) minDate = start;
  if (end.isAfter(maxDate)) maxDate = end;
}

// Calculate total days
totalDays = maxDate.difference(minDate).inDays;

// Calculate bar position and width for each job
for (var job in jobs) {
  startOffset = (jobStart - minDate).inDays / totalDays;
  width = (jobEnd - jobStart).inDays / totalDays;
}
```

### 3. Rendering

```dart
// For each job
Container(
  margin: EdgeInsets.only(left: startOffset * totalWidth),
  width: jobDuration * totalWidth,
  height: 40,
  decoration: BoxDecoration(
    color: jobColor,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(job.nama),
)
```

---

## Responsive Design

### Mobile Portrait
```
┌─────────────────┐
│  Info Card      │
├─────────────────┤
│  Progress Card  │
├─────────────────┤
│  Timeline       │  ← Full width
├─────────────────┤
│  Pekerjaan List │
└─────────────────┘
```

### Tablet/Desktop
```
┌──────────┬──────────────────────┐
│  Info    │  Timeline            │
│  Card    ├──────────────────────┤
│          │  Pekerjaan List      │
├──────────┤                      │
│ Progress │                      │
└──────────┴──────────────────────┘
```

---

## Customization

### 1. Mengubah Warna Bar

Edit di `gantt_chart_widget.dart`:

```dart
Color getJobColor(ItemPekerjaan job) {
  // Custom logic
  if (job.status == 'selesai') return Colors.green;
  if (job.status == 'tertunda') return Colors.orange;
  return Colors.blue; // default
}
```

### 2. Menambah Informasi

```dart
// Di dalam bar
Column(
  children: [
    Text(job.nama),
    Text('${job.pelaksana}'),  // Tambah info pelaksana
    Icon(statusIcon),           // Tambah icon status
  ],
)
```

### 3. Interaktivitas

```dart
// Tambah GestureDetector
GestureDetector(
  onTap: () => _showJobDetails(job),
  child: jobBar,
)

void _showJobDetails(ItemPekerjaan job) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(job.nama),
      content: Column(
        children: [
          Text('Mulai: ${job.tanggalMulai}'),
          Text('Selesai: ${job.tanggalSelesai}'),
          Text('Lokasi: ${job.lokasi}'),
          Text('Pelaksana: ${job.pelaksana}'),
        ],
      ),
    ),
  );
}
```

---

## Backend Integration

### Data Source
Timeline menggunakan data dari backend Django:

**Endpoint:** `GET /api/pekerjaan/berdasarkan_proyek/?id_proyek={projectId}`

**Response:**
```json
[
  {
    "id": "1",
    "nama": "Pekerjaan A",
    "tanggal_mulai": "2026-06-01",
    "tanggal_selesai": "2026-06-15",
    "lokasi": "Jakarta",
    "pelaksana": "Tim A"
  }
]
```

### Sync Logic

1. User membuka detail proyek
2. `project.daftarPekerjaan` sudah loaded dari backend
3. Widget langsung render timeline
4. Jika ada perubahan (tambah/edit pekerjaan), timeline auto-update via Provider

```dart
// Di ViewModel
context.watch<ProyekViewModel>(); // Auto rebuild saat data berubah
```

---

## Handling Edge Cases

### 1. Tidak Ada Pekerjaan

```dart
if (jobs.isEmpty) {
  return Center(
    child: Column(
      children: [
        Icon(Icons.calendar_month_outlined, size: 56),
        Text('Belum ada pekerjaan'),
      ],
    ),
  );
}
```

### 2. Tanggal Invalid

```dart
try {
  final start = DateTime.parse(job.tanggalMulai);
} catch (e) {
  // Skip atau gunakan default date
  developer.log('Invalid date format: ${job.tanggalMulai}');
  return SizedBox.shrink();
}
```

### 3. Durasi Negatif

```dart
if (endDate.isBefore(startDate)) {
  // Swap dates atau show error
  final temp = startDate;
  startDate = endDate;
  endDate = temp;
}
```

### 4. Semua Pekerjaan di Hari yang Sama

```dart
if (totalDays <= 0) {
  // Add margin untuk visibility
  minDate = minDate.subtract(Duration(days: 1));
  maxDate = maxDate.add(Duration(days: 1));
}
```

---

## Performance Optimization

### 1. Lazy Loading
Timeline hanya di-render saat card visible (scroll):

```dart
VisibilityDetector(
  key: Key('timeline-card'),
  onVisibilityChanged: (info) {
    if (info.visibleFraction > 0.5) {
      setState(() => _shouldRenderTimeline = true);
    }
  },
  child: _shouldRenderTimeline ? SimpleGanttChart(...) : Placeholder(),
)
```

### 2. Caching
Hasil perhitungan date range di-cache:

```dart
DateTime? _cachedMinDate;
DateTime? _cachedMaxDate;

void _calculateDateRange() {
  if (_cachedMinDate != null) return; // Use cache
  
  // Calculate...
  _cachedMinDate = minDate;
  _cachedMaxDate = maxDate;
}
```

---

## Testing

### Manual Testing

1. **Empty State:**
   - Buat proyek baru tanpa pekerjaan
   - Cek tampilan "Belum ada pekerjaan"

2. **Single Job:**
   - Tambah 1 pekerjaan
   - Timeline harus render 1 bar

3. **Multiple Jobs:**
   - Tambah beberapa pekerjaan dengan tanggal berbeda
   - Bar harus proporsional dengan durasi

4. **Overlapping Dates:**
   - 2 pekerjaan dengan tanggal yang overlap
   - Kedua bar harus terlihat (stacked)

5. **Invalid Dates:**
   - Input tanggal selesai < tanggal mulai
   - Aplikasi tidak crash

### Unit Testing

```dart
void main() {
  test('Calculate date range correctly', () {
    final jobs = [
      ItemPekerjaan(
        tanggalMulai: '2026-06-01',
        tanggalSelesai: '2026-06-10',
      ),
      ItemPekerjaan(
        tanggalMulai: '2026-06-05',
        tanggalSelesai: '2026-06-15',
      ),
    ];
    
    final chart = SimpleGanttChart(jobs: jobs);
    // Assert min = 2026-06-01, max = 2026-06-15
  });
}
```

---

## Future Enhancements

### Fitur yang Bisa Ditambahkan:

1. **Zoom In/Out:** Pinch gesture untuk zoom timeline
2. **Scroll Horizontal:** Jika banyak pekerjaan
3. **Filter:** Show/hide pekerjaan tertentu
4. **Export:** Download timeline sebagai PNG/PDF
5. **Critical Path:** Highlight jalur kritis proyek
6. **Dependencies:** Panah antar pekerjaan yang dependent
7. **Milestones:** Marker untuk milestone penting
8. **Today Indicator:** Garis vertikal untuk hari ini

---

## Troubleshooting

### Timeline Tidak Muncul

✅ **Cek:**
1. `project.daftarPekerjaan` tidak kosong
2. Tanggal mulai dan selesai valid
3. Import `gantt_chart_widget.dart` sudah benar
4. Widget di-render dalam `Expanded` atau container dengan width

### Bar Terlalu Kecil/Besar

✅ **Solusi:**
```dart
// Tambah constraint
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 50,  // Min width per bar
    maxWidth: 300, // Max width per bar
  ),
  child: SimpleGanttChart(...),
)
```

### Tanggal Tidak Akurat

✅ **Cek Format:**
```dart
// Harus format: YYYY-MM-DD
"2026-06-04" ✅
"04/06/2026" ❌
"June 4, 2026" ❌
```

---

Dibuat: 2026-06-04
Update terakhir: 2026-06-04
