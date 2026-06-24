# 🚀 CARA JALANKAN ProManage - Django Full Stack

## ✨ Aplikasi Sudah Fully Integrated!

Semua halaman React sudah dikonversi ke **Django Templates**. 
Tidak perlu lagi `npm`, `pnpm`, atau `vite` untuk development!

**Cukup jalankan Django server dan SEMUA sudah berfungsi!** 🎉

---

## 🎯 Quick Start (PALING MUDAH!)

### Windows:
```bash
RUN-DJANGO.bat
```

### Linux/Mac:
```bash
chmod +x RUN-DJANGO.sh
./RUN-DJANGO.sh
```

**Lalu buka browser:** http://localhost:8000

DONE! ✅

---

## 📖 Yang Akan Terjadi:

1. ✅ Script membuat virtual environment (jika belum ada)
2. ✅ Install dependencies Python
3. ✅ Setup database (migrate)
4. ✅ Tanya apakah mau create test data (opsional)
5. ✅ Jalankan Django server di port 8000

---

## 🎨 Halaman Yang Tersedia:

| URL | Deskripsi |
|-----|-----------|
| http://localhost:8000/ | Home page (landing page) |
| http://localhost:8000/about | About page (info tim & visi misi) |
| http://localhost:8000/projects | Projects dashboard (perlu login) |
| http://localhost:8000/admin | Django admin panel |

---

## 🔑 Test Account (Jika Create Test Data):

```
Email: test@promanage.com
Password: password123
```

Atau register account baru langsung di aplikasi!

---

## 📱 Fitur Yang Sudah Jalan:

### ✅ Frontend (Templates)
- Home page dengan hero section & features
- About page dengan team info
- Projects list & create project
- Project detail & list works
- Work detail & list activities
- Login & Register modal
- Header dengan authentication status
- Toast notifications
- Responsive mobile & desktop

### ✅ Backend (Django)
- REST API lengkap (CRUD)
- JWT Authentication
- Database (SQLite)
- Admin panel
- File upload support
- CORS configured

---

## 🛠️ Manual Setup (Jika Mau)

### 1. Install Dependencies
```bash
cd backend
python -m venv venv

# Activate
source venv/bin/activate          # Linux/Mac
venv\Scripts\activate             # Windows

pip install -r requirements.txt
```

### 2. Setup Database
```bash
python manage.py makemigrations
python manage.py migrate
```

### 3. (Optional) Create Test Data
```bash
python manage.py shell < create_test_data.py
```

### 4. Run Server
```bash
python manage.py runserver
```

### 5. Open Browser
http://localhost:8000

---

## 🎓 Flow Penggunaan:

1. **Buka** http://localhost:8000
2. **Klik** "Mulai Sekarang" atau "Register"
3. **Isi** form register (nama, NIM, email, password)
4. **Klik** "Register"
5. **Redirect** otomatis ke halaman Projects
6. **Klik** "Buat Proyek" untuk create project baru
7. **Isi** data project lalu submit
8. **Klik** "Lihat Detail" untuk lihat project detail
9. **Explore!** 🎉

---

## 📂 Struktur File:

```
promanage/
├── backend/
│   ├── api/
│   │   ├── templates/              # Django Templates ✨
│   │   │   ├── base.html
│   │   │   ├── home.html
│   │   │   ├── about.html
│   │   │   ├── projects.html
│   │   │   └── components/
│   │   ├── models.py               # Database models
│   │   ├── views.py                # Template & API views
│   │   ├── serializers.py          # DRF serializers
│   │   └── urls.py                 # URL routing
│   ├── backend/
│   │   ├── settings.py             # Django config
│   │   └── urls.py                 # Root URLs
│   ├── manage.py                   # Django CLI
│   └── db.sqlite3                  # Database file
├── RUN-DJANGO.sh                   # Start script (Linux/Mac)
├── RUN-DJANGO.bat                  # Start script (Windows)
└── CARA_JALANKAN.md                # File ini
```

---

## 🔧 Commands Berguna:

### Create Superuser (untuk admin panel)
```bash
cd backend
python manage.py createsuperuser
```
Lalu akses: http://localhost:8000/admin

### Reset Database
```bash
cd backend
rm db.sqlite3
python manage.py migrate
```

### Ganti Port (jika 8000 sudah dipakai)
```bash
python manage.py runserver 8001
```
Buka: http://localhost:8001

---

## 💡 Technology Stack:

| Layer | Technology |
|-------|------------|
| Templates | Django Templates |
| Styling | Tailwind CSS (CDN) |
| Icons | Lucide Icons (CDN) |
| JavaScript | Vanilla JS |
| Backend | Django 5.0 |
| API | Django REST Framework |
| Auth | JWT (PyJWT) |
| Database | SQLite (dev) |

**Tidak ada Node.js, npm, webpack, vite, atau build process!**
**Pure Python + Django! 🐍**

---

## 🐛 Troubleshooting:

### 1. Port 8000 already in use
```bash
python manage.py runserver 8001
```

### 2. Module not found
```bash
pip install -r requirements.txt
```

### 3. Database error
```bash
rm db.sqlite3
python manage.py migrate
```

### 4. Template not found
Pastikan di `backend/backend/settings.py`:
```python
TEMPLATES = [{
    'DIRS': [BASE_DIR / 'api' / 'templates'],
    ...
}]
```

### 5. API tidak bisa diakses
Check URL pakai `/api/` prefix:
- ✅ `/api/auth/login/`
- ❌ `/auth/login/`

---

## 📚 Dokumentasi Lengkap:

- **[DJANGO_README.md](DJANGO_README.md)** - Overview & features
- **[DJANGO_QUICKSTART.md](backend/DJANGO_QUICKSTART.md)** - Setup detail
- **[TEST_DJANGO.md](TEST_DJANGO.md)** - Testing guide
- **[backend/README.md](backend/README.md)** - Backend API docs

---

## 🎯 Next Steps:

1. ✅ Jalankan `RUN-DJANGO.bat` atau `RUN-DJANGO.sh`
2. ✅ Buka http://localhost:8000
3. ✅ Register / Login
4. ✅ Buat project pertama
5. ✅ Explore fitur-fitur lainnya!

---

## ❓ FAQ:

### Q: Apakah masih perlu jalankan React/Vite?
**A:** TIDAK! Semua sudah di Django. Cukup `python manage.py runserver`

### Q: Apakah perlu install Node.js?
**A:** TIDAK! Tidak perlu npm, pnpm, atau node. Pure Python!

### Q: Bagaimana cara deploy?
**A:** Deploy seperti Django app biasa. Railway, Render, atau Heroku.

### Q: Apakah data tersimpan di database?
**A:** YA! Data tersimpan di `backend/db.sqlite3` (SQLite)

### Q: Bisa pakai PostgreSQL?
**A:** YA! Edit `.env.backend` dan ganti DATABASE_ENGINE

### Q: Frontend dimana?
**A:** Frontend = Django Templates di `backend/api/templates/`

### Q: API dimana?
**A:** API tetap ada di `/api/*` untuk AJAX calls dari templates

---

## 🎉 Summary:

**ONE COMMAND TO RULE THEM ALL:**

```bash
RUN-DJANGO.bat      # Windows
./RUN-DJANGO.sh     # Linux/Mac
```

**Buka:** http://localhost:8000

**DONE!** 🚀

---

**Happy Coding! 💻**

Jika ada pertanyaan atau issue, check dokumentasi lengkap di file-file .md lainnya atau buka issue di repository.
