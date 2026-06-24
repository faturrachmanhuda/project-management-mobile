# 🚀 Cara Menjalankan Backend Django

## Quick Start

### 1. Buka Terminal/CMD Baru

```bash
cd "C:\Users\Asus\Documents\tugas project management\flutter cadangan manajemen proyek\PROMANAGE"
```

### 2. Jalankan Django Server

**PENTING:** Gunakan `0.0.0.0:8000` bukan `127.0.0.1:8000`

```bash
python manage.py runserver 0.0.0.0:8000
```

**Output yang Diharapkan:**
```
Starting development server at http://0.0.0.0:8000/
Quit the server with CTRL-BREAK.
```

✅ **Backend siap!** Jangan tutup terminal ini.

---

## 3. Konfigurasi IP di Flutter

### Untuk Android Emulator (SDK gphone64):
File: `lib/services/api_config.dart`

```dart
static const String laptopIp = '10.0.2.2';  // ✅ Sudah diset
```

**Kenapa `10.0.2.2`?**  
Ini adalah IP khusus di Android Emulator yang mengarah ke `localhost` komputer host.

### Untuk HP/Device Fisik:
```dart
// Uncomment ini dan ganti dengan IP komputer Anda
// static const String laptopIp = '192.168.11.170';
```

**Cara Cek IP Komputer:**
```bash
# Windows CMD:
ipconfig

# Cari: IPv4 Address . . . : 192.168.x.x
```

---

## 4. Test Koneksi

### Test 1: Di Browser Komputer
Buka: http://localhost:8000/api/proyek/

Harus muncul JSON atau login page.

### Test 2: Di Browser Emulator
1. Buka Chrome di emulator
2. Akses: http://10.0.2.2:8000/api/proyek/
3. Harus muncul sama seperti di komputer

### Test 3: Di Flutter App
```bash
flutter run
```

Console harus show:
```
✅ No more "Connection refused" errors
```

---

## Troubleshooting

### ❌ Error: "Connection refused"

**Kemungkinan Penyebab:**

1. **Backend tidak running**
   - Cek: Ada terminal yang running `python manage.py runserver`?
   - Fix: Jalankan backend dulu

2. **Backend running di `127.0.0.1` bukan `0.0.0.0`**
   - Cek: Terminal backend show "http://127.0.0.1:8000" atau "http://0.0.0.0:8000"?
   - Fix: Stop (Ctrl+C), lalu run ulang dengan `python manage.py runserver 0.0.0.0:8000`

3. **Firewall blocking port 8000**
   - Windows Defender mungkin block
   - Fix: Allow Python/Django di firewall settings

4. **Salah IP untuk physical device**
   - Cek: Device dan komputer di WiFi yang sama?
   - Fix: Ganti IP di `api_config.dart` dengan IP komputer

---

## IP Configuration Cheat Sheet

| Environment | IP Setting | Notes |
|-------------|-----------|-------|
| Android Emulator | `10.0.2.2` | Always use this |
| iOS Simulator | `127.0.0.1` atau `localhost` | Native to Mac |
| Physical Device (WiFi) | `192.168.x.x` | Check with `ipconfig` |
| Physical Device (USB) | `10.0.2.2` with USB debugging | Android only |

---

## Testing Flow

```
Step 1: Start Backend
  ↓
  python manage.py runserver 0.0.0.0:8000
  ↓
Step 2: Verify in Browser
  ↓
  http://localhost:8000/api/proyek/
  ↓
Step 3: Set IP in Flutter
  ↓
  api_config.dart → laptopIp = '10.0.2.2'
  ↓
Step 4: Hot Restart Flutter
  ↓
  Press 'R' in flutter run terminal
  ↓
Step 5: Check Console
  ↓
  ✅ No more connection errors!
```

---

## Commands Summary

```bash
# 1. Start Backend
cd "PROMANAGE folder"
python manage.py runserver 0.0.0.0:8000

# 2. Run Flutter (separate terminal)
cd "flutter_application_1 folder"
flutter run

# 3. Hot Restart (if backend was started after flutter)
# In flutter terminal, press: R
```

---

## Backend Checklist

Before running Flutter app:

- [ ] Backend terminal is open and running
- [ ] Shows: "Starting development server at http://0.0.0.0:8000/"
- [ ] Browser test: http://localhost:8000/api/proyek/ works
- [ ] Emulator test: http://10.0.2.2:8000/api/proyek/ works
- [ ] Flutter `api_config.dart` has correct IP
- [ ] Firewall allows Python on port 8000

---

## Quick Fix Commands

```bash
# If backend not responding:
# 1. Stop backend: Ctrl+C
# 2. Restart:
python manage.py runserver 0.0.0.0:8000

# If Flutter still shows connection refused:
# In flutter terminal:
R  # Hot restart (capital R)

# If still not working:
# Stop flutter (q) and restart:
flutter run
```

---

**Dibuat:** 2026-06-04  
**Environment:** Android Emulator (sdk gphone64 x86 64)  
**Backend:** Django @ port 8000
