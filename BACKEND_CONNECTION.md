# 🔌 Koneksi Backend Django

## Konfigurasi Backend

### 1. API Configuration
File: `lib/services/api_config.dart`

```dart
class ApiConfig {
  // IP Address komputer yang menjalankan Django backend
  static const String laptopIp = '192.168.11.170';

  // Set true untuk mode offline (tanpa backend)
  static const bool useLocalOnly = false;

  static String get baseUrl => useLocalOnly ? '' : 'http://$laptopIp:8000';
}
```

### 2. Cara Mengganti IP Backend

**Untuk Testing di Perangkat yang Sama:**
```dart
static const String laptopIp = '127.0.0.1';  // atau 'localhost'
```

**Untuk Testing di HP/Emulator:**
```dart
static const String laptopIp = '192.168.x.x';  // IP komputer di network
```

**Cara Cek IP Komputer:**
- Windows: Buka CMD → ketik `ipconfig` → lihat IPv4 Address
- Mac/Linux: Buka Terminal → ketik `ifconfig` → lihat inet address

### 3. Menjalankan Backend Django

**Lokasi Backend:**
```
C:\Users\Asus\Documents\tugas project management\flutter cadangan manajemen proyek\PROMANAGE\
```

**Langkah Menjalankan:**
```bash
# 1. Masuk ke folder backend
cd "C:\Users\Asus\Documents\tugas project management\flutter cadangan manajemen proyek\PROMANAGE"

# 2. Aktifkan virtual environment (jika ada)
venv\Scripts\activate

# 3. Jalankan server Django
python manage.py runserver 0.0.0.0:8000
```

**Catatan:** `0.0.0.0:8000` membuat server bisa diakses dari perangkat lain di network yang sama.

---

## Endpoint API yang Tersedia

### 📋 Proyek (Projects)

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/proyek/` | Ambil semua proyek user |
| POST | `/api/proyek/` | Buat proyek baru |
| PUT | `/api/proyek/{id}/` | Update proyek |
| DELETE | `/api/proyek/{id}/` | Hapus proyek |

### 🔨 Pekerjaan (Works)

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/pekerjaan/` | Ambil semua pekerjaan |
| GET | `/api/pekerjaan/berdasarkan_proyek/?id_proyek={id}` | Pekerjaan per proyek |
| POST | `/api/pekerjaan/` | Buat pekerjaan baru |
| PUT | `/api/pekerjaan/{id}/` | Update pekerjaan |
| DELETE | `/api/pekerjaan/{id}/` | Hapus pekerjaan |

### ⚡ Aktivitas (Activities)

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/aktivitas/` | Ambil semua aktivitas |
| GET | `/api/aktivitas/berdasarkan_pekerjaan/?id_pekerjaan={id}` | Aktivitas per pekerjaan |
| POST | `/api/aktivitas/` | Buat aktivitas baru |
| PUT | `/api/aktivitas/{id}/` | Update aktivitas |
| DELETE | `/api/aktivitas/{id}/` | Hapus aktivitas |

### 📊 Reports

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| GET | `/api/reports/project/{id}/excel/` | Export proyek ke Excel |

### 👤 Authentication

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/api/auth/login/` | Login user |
| POST | `/api/auth/register/` | Register user baru |
| POST | `/api/auth/logout/` | Logout user |

---

## Service Layer

### ProjectService
File: `lib/services/project_service.dart`

**Fungsi Utama:**
- `getProjects()` - Ambil semua proyek
- `createProject(Proyek)` - Buat proyek
- `updateProject(Proyek)` - Update proyek
- `deleteProject(String id)` - Hapus proyek
- `getWorks({projectId})` - Ambil pekerjaan
- `createWork(Pekerjaan)` - Buat pekerjaan
- `updateWork(Pekerjaan)` - Update pekerjaan
- `deleteWork(String id)` - Hapus pekerjaan
- `getActivities({workId})` - Ambil aktivitas
- `createActivity(Kegiatan)` - Buat aktivitas

### ApiService
File: `lib/services/api_service.dart`

**Fungsi HTTP:**
- `get(String endpoint)` - HTTP GET
- `post(String endpoint, dynamic body)` - HTTP POST
- `put(String endpoint, dynamic body)` - HTTP PUT
- `delete(String endpoint)` - HTTP DELETE

**Fitur:**
- Auto-retry pada network error
- Token authentication
- Error handling
- Logging untuk debugging

---

## Mode Offline

Jika tidak ada koneksi backend, set:

```dart
static const bool useLocalOnly = true;
```

Aplikasi akan bekerja dalam mode offline menggunakan:
- SQLite local database
- SharedPreferences
- File system local

---

## Troubleshooting

### ❌ Tidak Bisa Koneksi Backend

**1. Cek Backend Running:**
```bash
# Test di browser atau Postman
http://192.168.11.170:8000/api/proyek/
```

**2. Cek Firewall:**
- Windows Defender mungkin memblok port 8000
- Buka pengaturan firewall dan allow port 8000

**3. Cek Network:**
- HP/Emulator harus di network yang sama dengan komputer
- Gunakan WiFi yang sama

**4. Cek IP Address:**
- IP bisa berubah saat restart komputer
- Update `laptopIp` di `api_config.dart`

### ❌ Error 401 Unauthorized

User belum login. Pastikan sudah:
1. Register/Login melalui halaman auth
2. Token tersimpan di SharedPreferences

### ❌ Error 404 Not Found

Endpoint salah atau backend tidak jalan. Cek:
1. Backend Django running di port 8000
2. URL endpoint benar
3. Migrations sudah dijalankan

---

## Testing Koneksi

### Test Manual:

```dart
// Di dalam Flutter app
import 'package:flutter_application_1/services/project_service.dart';

// Test get projects
final service = ProyekService();
try {
  final projects = await service.getProjects();
  print('✅ Koneksi berhasil! Proyek: ${projects.length}');
} catch (e) {
  print('❌ Error: $e');
}
```

### Log Output:

Cek console Flutter untuk melihat log API calls:
```
[ProyekService] getProjects()
[ApiService] GET /api/proyek/
[ApiService] Response: 200 OK
```

---

## Security

### Development (Sekarang):
- HTTP tanpa SSL (http://)
- Token di SharedPreferences
- CORS enabled untuk semua origin

### Production (Nanti):
- Gunakan HTTPS (https://)
- Encrypt token
- Restrict CORS ke domain spesifik
- Rate limiting
- Input validation

---

## Tips Pengembangan

1. **Selalu Running Backend:** Backend harus jalan saat test aplikasi
2. **Check Logs:** Monitor console untuk API errors
3. **Use Postman:** Test endpoint di Postman dulu sebelum di Flutter
4. **Sync Issues:** Jika data tidak sync, cek method `isTersinkron` di model
5. **Hot Reload:** Setelah ubah IP, restart aplikasi (tidak cukup hot reload)

---

Dibuat: 2026-06-04
Update terakhir: 2026-06-04
