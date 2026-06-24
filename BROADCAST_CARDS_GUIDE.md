# Flutter Broadcast Cards - Matching Django Style

Komponen Flutter yang dibuat untuk mencocokkan tampilan broadcast system Django dengan presisi tinggi.

## 📁 Files Created

```
lib/
├── widgets/
│   ├── broadcast_colors.dart      # Color palette matching Django
│   └── work_detail_card.dart      # Main card components
└── pages/
    ├── work_detail_page.dart      # Full implementation page
    └── broadcast_demo_page.dart   # Demo & examples
```

## 🎨 Color System

### Broadcast Types
- **IE (Implementation Evaluation)** - Blue theme
- **IC (Implementation Control)** - Green theme  
- **Implementation** - Purple theme

### Status Types
- **BELUM** - Red theme (matching screenshot)
- **PROGRESS** - Orange/Amber theme
- **SELESAI** - Green theme

### Usage
```dart
// Get colors for any broadcast type
final ieColors = BroadcastColors.getBroadcastColors('IE');
final statusColors = BroadcastColors.getStatusColors('BELUM');
```

## 🧩 Components

### 1. BroadcastBadge
Blue "IE" badge matching Django style:
```dart
BroadcastBadge(type: 'IE')
BroadcastBadge(type: 'IC') 
BroadcastBadge(type: 'IMPLEMENTATION')
```

### 2. StatusBadge  
Red "BELUM" pill badge matching screenshot:
```dart
StatusBadge(status: 'BELUM')
StatusBadge(status: 'PROGRESS')
StatusBadge(status: 'SELESAI')
```

### 3. InfoRow
Date range and activity count with icons:
```dart
InfoRow(
  icon: Icons.calendar_today_outlined,
  text: '2026-06-23 - 2026-06-25',
)
InfoRow(
  icon: Icons.assignment_outlined, 
  text: '1 log',
)
```

### 4. ActivitySummaryItem
Individual activity items in card bottom:
```dart
ActivitySummaryItem(
  name: 'dfadf',
  time: '13:13',
  isCompleted: false,
)
```

### 5. WorkDetailCard
Main card component (exact match to screenshot):
```dart
WorkDetailCard(
  title: 'asdas',                    // Work title
  broadcastType: 'IE',              // Blue IE badge
  status: 'BELUM',                  // Red BELUM badge
  dateRange: '2026-06-23 - 2026-06-25',
  activityCount: 1,
  activities: [
    ActivitySummaryItem(
      name: 'dfadf',
      time: '13:13',
      isCompleted: false,
    ),
  ],
  onEdit: () => print('Edit'),
  onDelete: () => print('Delete'),
  onTap: () => print('View details'),
)
```

## 📱 Full Implementation

### Basic Usage
```dart
import 'package:flutter/material.dart';
import 'widgets/work_detail_card.dart';

class MyWorkPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Exact screenshot match
            WorkDetailCard(
              title: 'asdas',
              broadcastType: 'IE', 
              status: 'BELUM',
              dateRange: '2026-06-23 - 2026-06-25',
              activityCount: 1,
              activities: [
                ActivitySummaryItem(
                  name: 'dfadf',
                  time: '13:13', 
                  isCompleted: false,
                ),
              ],
              onEdit: () {}, 
              onDelete: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

### With Dynamic Data
```dart
// Using with your existing models
WorkDetailCard(
  title: work.nama,
  broadcastType: _getBroadcastType(work),
  status: _getWorkStatus(work), 
  dateRange: '${work.tanggalMulai} - ${work.tanggalSelesai}',
  activityCount: activities.length,
  activities: activities.map((activity) => 
    ActivitySummaryItem(
      name: activity.namaKegiatan,
      time: _formatTime(activity.waktuPelaksanaan),
      isCompleted: activity.selesai,
    )
  ).toList(),
  onEdit: () => _editWork(work),
  onDelete: () => _deleteWork(work),
  onTap: () => _viewWorkDetails(work),
)
```

## 🎯 Visual Match to Django

### Card Structure (Exact)
```
┌─────────────────────────────────────────────────────┐
│ [🔧] asdas                            [✏️] [🗑️]   │
│      [IE] [BELUM]                                   │
│                                                     │ 
│ 📅 2026-06-23 - 2026-06-25    📋 1 log            │
│ ─────────────────────────────────────────────────── │
│ [✓] dfadf                                     13:13 │
└─────────────────────────────────────────────────────┘
```

### Colors (Django Matching)
- **Card**: White background, light gray border, subtle shadow
- **IE Badge**: Blue (#3B82F6) with light blue background
- **BELUM Badge**: Red (#EF4444) with light red background  
- **Icon**: Indigo (#6366F1) matching screenshot
- **Text**: Gray hierarchy for title/subtitle/meta

### Typography 
- **Title**: 16px, semibold, dark gray
- **Badges**: 11px, semibold, colored text
- **Meta info**: 13px, regular, medium gray
- **Activities**: 14px, medium weight

### Spacing & Borders
- **Card padding**: 16px all around
- **Border radius**: 10px (medium)
- **Badge radius**: 12px (pill shape)  
- **Icon size**: 18px for main, 16px for meta

## 📖 Demo Pages

### 1. BroadcastDemoPage
Complete showcase with all variations:
- Badge examples
- Multiple card types
- All broadcast types (IE, IC, Implementation)
- All status types (BELUM, PROGRESS, SELESAI)

### 2. WorkDetailPage  
Full page implementation showing:
- Project header
- Work list with cards
- Loading states
- Empty states  
- Action handling (edit/delete/view)

### 3. ColorPaletteDemo
Visual color palette reference showing exact hex values.

## ⚡ Integration with Existing Code

### With ItemPekerjaan Model
```dart
// Convert your existing model to card
ProjectWorkCard(
  workTitle: itemPekerjaan.nama,
  projectTitle: itemPekerjaan.judulProyek,
  broadcastType: 'IE', // or derive from business logic
  status: _getStatusFromDates(itemPekerjaan),
  startDate: itemPekerjaan.tanggalMulai, 
  endDate: itemPekerjaan.tanggalSelesai,
  activityCount: activities.length,
  activities: activities.map(_convertActivity).toList(),
  onEdit: () => _editWork(itemPekerjaan),
  onDelete: () => _deleteWork(itemPekerjaan),
)
```

### With Broadcast Status from Django
```dart
// If your Django response includes broadcast_status
final broadcastType = project.broadcastStatus?.keys.first ?? 'IE';
final broadcastResult = project.broadcastStatus?[broadcastType];

WorkDetailCard(
  title: work.nama,
  broadcastType: broadcastType,
  status: _deriveStatus(broadcastResult),
  // ... rest of properties
)
```

## 🚀 Quick Start

1. **Add the files** to your Flutter project
2. **Import the widgets**:
   ```dart
   import 'widgets/work_detail_card.dart';
   import 'widgets/broadcast_colors.dart';
   ```
3. **Use WorkDetailCard** with your data
4. **Customize colors** in `broadcast_colors.dart` if needed
5. **Test with demo page** to see all variations

## 🎨 Customization

### Adjust Colors
Edit `broadcast_colors.dart` to match your exact Django colors:
```dart
static const Color iePrimary = Color(0xFF3B82F6); // Your Django blue
static const Color statusBelum = Color(0xFFEF4444); // Your Django red
```

### Add New Broadcast Types
```dart
// Add new type to getBroadcastColors()
case 'QUALITY':
  return {
    'primary': Color(0xFFPURPLE),  // Your color
    'background': Color(0xFFLIGHT),
    // ...
  };
```

### Modify Card Layout
Extend `WorkDetailCard` or create variants for different use cases.

---

**Result**: Pixel-perfect Flutter cards matching your Django broadcast system! 🎯