# 🚀 Quick Start Guide

## Menjalankan Aplikasi dengan Backend

### Langkah 1: Jalankan Backend Django

```bash
# 1. Buka terminal/CMD
# 2. Masuk ke folder backend
cd "C:\Users\Asus\Documents\tugas project management\flutter cadangan manajemen proyek\PROMANAGE"

# 3. (Optional) Aktifkan virtual environment jika ada
# venv\Scripts\activate

# 4. Jalankan Django server
python manage.py runserver 0.0.0.0:8000
```

**Output yang Diharapkan:**
```
Django version 4.x, using settings 'PROMANAGE.settings'
Starting development server at http://0.0.0.0:8000/
Quit the server with CTRL-BREAK.
```

✅ **Backend Ready!** Biarkan terminal ini tetap buka.

---

### Langkah 2: Cek IP Address Komputer

#### Windows:
```bash
ipconfig
```
Cari baris: `IPv4 Address. . . . . . . . . . . : 192.168.x.x`

#### Mac/Linux:
```bash
ifconfig
```
Cari baris: `inet 192.168.x.x`

📝 **Catat IP ini!**

---

### Langkah 3: Update IP di Flutter

Buka file: `lib/services/api_config.dart`

```dart
class ApiConfig {
  // 👇 GANTI IP INI dengan IP komputer kamu
  static const String laptopIp = '192.168.11.170';  // ← Update ini!
  
  static const bool useLocalOnly = false;  // ← Harus false!
  
  static String get baseUrl => useLocalOnly ? '' : 'http://$laptopIp:8000';
}
```

---

### Langkah 4: Jalankan Flutter App

#### VS Code:
```
F5 atau Run → Start Debugging
```

#### Terminal:
```bash
flutter run
```

#### Build APK untuk Install:
```bash
flutter build apk --debug
```
APK ada di: `build/app/outputs/flutter-apk/app-debug.apk`

---

### Langkah 5: Test Koneksi

1. **Login/Register** di aplikasi
2. **Buat Proyek Baru**
3. **Tambah Pekerjaan**
4. **Buka Detail Proyek**
5. **Verify Timeline Muncul** 📊

**Cek Console:**
```
[ProyekService] getProjects()
[ApiService] GET /api/proyek/
[ApiService] Response: 200 OK ← Koneksi berhasil!
```

---

## Troubleshooting Cepat

### ❌ "Cannot connect to backend"

**Cek:**
1. ✅ Backend Django running? (Terminal masih aktif?)
2. ✅ IP address benar di `api_config.dart`?
3. ✅ HP/Emulator di WiFi yang sama dengan komputer?
4. ✅ Firewall tidak block port 8000?

**Test Manual:**
Buka browser di HP/komputer, akses:
```
http://192.168.11.170:8000/api/proyek/
```
Harus muncul JSON response.

---

### ❌ Timeline tidak muncul

**Cek:**
1. ✅ Sudah ada pekerjaan di proyek?
2. ✅ Tanggal mulai & selesai sudah diisi?
3. ✅ Format tanggal: YYYY-MM-DD (misal: 2026-06-04)

---

### ❌ Build error

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Build lagi
flutter build apk --debug
```

---

## Mode Offline (Tanpa Backend)

Jika tidak perlu backend saat ini:

**Edit:** `lib/services/api_config.dart`
```dart
static const bool useLocalOnly = true;  // ← Set true
```

App akan jalan dengan:
- SQLite local database
- Data tersimpan di HP
- Tidak sync ke server

---

## Fitur Utama

### 1. 📋 Manajemen Proyek
- Buat, Edit, Hapus proyek
- Track progress keseluruhan
- Info detail proyek

### 2. 🔨 Manajemen Pekerjaan  
- Tambah pekerjaan ke proyek
- Set tanggal mulai & selesai
- Assign pelaksana & supervisor
- **NEW:** Tampilan nested dengan aktivitas

### 3. ⚡ Manajemen Aktivitas
- Tambah aktivitas per pekerjaan
- Update status (Proses/Selesai)
- Upload bukti dokumentasi
- Track pelaksana

### 4. 📊 Timeline Grafik **NEW!**
- Visual timeline semua pekerjaan
- Lihat jadwal & overlap
- Auto-update saat data berubah

### 5. 📄 Export & Reports
- Export PDF detail proyek
- Export Excel data proyek
- Share dokumentasi

---

## Tips & Tricks

### 💡 Tip 1: Hot Reload
Setelah ubah code:
- Press `r` di terminal untuk reload
- Press `R` untuk restart full
- VS Code: Ctrl+S auto hot reload

### 💡 Tip 2: Debug Mode
Console akan show logs:
```
[ProyekService] getProjects()
[ApiService] GET /api/proyek/
```
Gunakan untuk debugging koneksi.

### 💡 Tip 3: Test di Berbagai Ukuran
- Portrait mode (vertical)
- Landscape mode (horizontal)
- Tablet mode (larger screen)

Semua sudah responsive! ✅

### 💡 Tip 4: Backup Data
Jika mode offline (local), data ada di:
- Android: `/data/data/com.yourapp/databases/`
- Backup dengan export Excel!

---

## Development Workflow

```
1. Backend Running ✅
   ↓
2. Update Code Flutter
   ↓
3. Hot Reload (r)
   ↓
4. Test di Emulator/HP
   ↓
5. Cek Logs di Console
   ↓
6. Commit Changes
```

---

## Folder Structure

```
flutter_application_1/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── models/                      # Data models
│   │   ├── modelbikinproyek.dart    # Proyek, Pekerjaan, Aktivitas
│   │   └── activity_model.dart
│   ├── services/                    # Backend services
│   │   ├── api_config.dart          # ⚙️ Config IP backend
│   │   ├── api_service.dart         # HTTP client
│   │   └── project_service.dart     # CRUD operations
│   ├── view/                        # UI Screens
│   │   ├── project_detail_page.dart # 📊 Detail proyek + timeline
│   │   ├── bikin_pekerjaan.dart     # Form pekerjaan
│   │   └── gantt_chart_widget.dart  # Timeline widget
│   ├── viewmodel/                   # State management
│   │   └── bikinproyek_viewmodel.dart
│   └── utils/                       # Helpers
│       ├── responsive_helper.dart   # Responsive logic
│       └── toast_helper.dart        # Notifications
├── BACKEND_CONNECTION.md            # 📖 Backend guide
├── FITUR_TIMELINE.md                # 📖 Timeline docs
├── CHANGELOG_LATEST.md              # 📝 Recent changes
└── QUICK_START.md                   # 🚀 This file!
```

---

## Next Steps

Setelah aplikasi running:

1. **Explore Features:**
   - [ ] Buat beberapa proyek
   - [ ] Tambah pekerjaan dengan tanggal berbeda
   - [ ] Lihat timeline grafik
   - [ ] Tambah aktivitas
   - [ ] Test export PDF/Excel

2. **Test Responsive:**
   - [ ] Rotate HP (portrait ↔ landscape)
   - [ ] Test di tablet jika ada
   - [ ] Resize window jika di desktop

3. **Test Backend Sync:**
   - [ ] Buat data di HP A
   - [ ] Login di HP B
   - [ ] Data harus sama (tersync)

---

## Resources

- **Backend Docs:** `BACKEND_CONNECTION.md`
- **Timeline Docs:** `FITUR_TIMELINE.md`
- **Changelog:** `CHANGELOG_LATEST.md`
- **Flutter Docs:** https://docs.flutter.dev
- **Django Docs:** https://docs.djangoproject.com

---

## 🎉 Done!

Aplikasi siap digunakan!

**Happy Coding!** 🚀

---

**Last Updated:** 2026-06-04
