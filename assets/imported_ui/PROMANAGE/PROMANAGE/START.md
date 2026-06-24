# 🚀 Quick Start - ProManage

Panduan cepat untuk menjalankan aplikasi ProManage.

## ⚡ TL;DR - Jalankan Aplikasi

### Option 1: Pakai Script (Recommended)

**Windows:**
```bash
# Double click file ini di Windows Explorer:
START-WINDOWS.bat
```

**Linux/Mac:**
```bash
chmod +x START-LINUX-MAC.sh
./START-LINUX-MAC.sh
```

### Option 2: Manual

**Terminal 1 - Backend:**
```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

**Terminal 2 - Frontend:**
```bash
pnpm install
pnpm dev
```

Buka browser: `http://localhost:5173`

## 📦 Yang Sudah Tersedia

### ✅ Backend Django (Port 8000)
- Models: User, Project, Work, Activity
- REST API dengan JWT Authentication
- Upload foto dokumentasi
- Admin panel di `/admin`

### ✅ Frontend React (Port 5173)
- Context API untuk state management
- React Router untuk routing
- Toast notifications
- Responsive design (mobile & desktop)
- Inline edit untuk rename

### ✅ Environment Files
- `.env` - Frontend config
- `.env.backend` - Backend config

## 🔑 Default Credentials

Belum ada user. Silakan **Register** di aplikasi.

Atau buat superuser untuk akses admin panel:
```bash
cd backend
python manage.py createsuperuser
```

## 📝 Test Data (Optional)

Untuk populate test data:
```bash
cd backend
python manage.py shell < create_test_data.py
```

Login dengan:
- Email: `test@promanage.com`
- Password: `password123`

## 🌐 URL Aplikasi

| Service | URL | Deskripsi |
|---------|-----|-----------|
| Frontend | http://localhost:5173 | Aplikasi utama |
| Backend API | http://localhost:8000/api | REST API |
| Admin Panel | http://localhost:8000/admin | Django admin |
| API Health | http://localhost:8000/api/health | Health check |

## 📚 API Endpoints

### Authentication
```
POST /api/auth/register/  - Register
POST /api/auth/login/     - Login
GET  /api/users/me/       - Current user
```

### Projects
```
GET    /api/projects/          - List projects
POST   /api/projects/          - Create project
GET    /api/projects/{id}/     - Detail project
PATCH  /api/projects/{id}/     - Update project
DELETE /api/projects/{id}/     - Delete project
PATCH  /api/projects/{id}/close/ - Close project
```

### Works
```
GET    /api/works/by_project/?project_id={id}  - List by project
POST   /api/works/                              - Create work
PATCH  /api/works/{id}/                         - Update work
DELETE /api/works/{id}/                         - Delete work
```

### Activities
```
GET    /api/activities/by_work/?work_id={id}   - List by work
POST   /api/activities/                         - Create activity
PATCH  /api/activities/{id}/                    - Update activity
PATCH  /api/activities/{id}/toggle_done/        - Toggle done
DELETE /api/activities/{id}/                    - Delete activity
```

## 🔄 Migrasi ke API

Saat ini aplikasi masih menggunakan localStorage. Untuk migrasi ke Django API:

1. Baca file `MIGRATION_GUIDE.md`
2. Update AuthContext untuk pakai `src/app/services/api.ts`
3. Update ProjectContext untuk pakai API calls
4. Test semua fitur

## 🐛 Troubleshooting

### Backend tidak bisa diakses
```bash
# Check apakah backend running
curl http://localhost:8000/api/health/

# Jika gagal, restart backend
cd backend
python manage.py runserver
```

### Frontend error CORS
Edit `backend/backend/settings.py`:
```python
CORS_ALLOWED_ORIGINS = [
    'http://localhost:5173',
]
```

### Database error
```bash
cd backend
rm db.sqlite3
python manage.py migrate
```

### Port sudah digunakan
```bash
# Backend - ganti port
python manage.py runserver 8001

# Frontend - edit vite.config.ts atau:
PORT=3000 pnpm dev
```

## 📖 Dokumentasi Lengkap

- `SETUP_GUIDE.md` - Setup lengkap & deployment
- `MIGRATION_GUIDE.md` - Migrasi localStorage → API
- `backend/README.md` - Django backend docs

## 🎯 Fitur Utama

### Autentikasi
- Register & Login mahasiswa
- JWT token authentication
- Protected routes
- Logout

### Manajemen Proyek
- Wizard multi-step untuk buat project
- CRUD projects, works, activities
- Inline edit untuk rename
- Close/archive project
- Status tracking

### Pemantauan
- Pantau progress aktivitas
- Evaluasi aktivitas
- Upload foto dokumentasi
- Perbandingan planning vs realisasi

### UI/UX
- Desain modern & clean
- Warna dominan putih + aksen merah #B91C1C
- Fully responsive (mobile & desktop)
- Toast notifications
- Modal & bottom sheet

## 🚢 Deploy ke Production

Lihat `SETUP_GUIDE.md` bagian "Deploy ke Production" untuk:
- Deploy backend ke Railway/Render
- Deploy frontend ke Vercel/Netlify
- Setup PostgreSQL database
- Environment variables production

## 💬 Need Help?

1. Check documentation files
2. Read Django docs: https://docs.djangoproject.com/
3. Read React docs: https://react.dev/
4. Check browser console untuk errors
5. Check terminal output untuk backend errors

## 📞 Support

Jika ada masalah yang tidak bisa diselesaikan, buka issue di repository atau hubungi developer.

---

**Happy Coding! 🎉**
