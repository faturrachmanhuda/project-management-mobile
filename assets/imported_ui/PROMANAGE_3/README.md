# 🎓 ProManage - Aplikasi Manajemen Proyek Mahasiswa

Aplikasi web modern untuk manajemen proyek mahasiswa dengan fitur lengkap tracking aktivitas, evaluasi, dan dokumentasi foto. Dibangun dengan React + TypeScript untuk frontend dan Django + DRF untuk backend REST API.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![React](https://img.shields.io/badge/React-18.3.1-61dafb?logo=react)
![Django](https://img.shields.io/badge/Django-5.0-green?logo=django)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue?logo=typescript)
![License](https://img.shields.io/badge/license-MIT-green)

---

## ✨ Fitur Utama

### 🔐 Autentikasi & User Management
- ✅ Register & Login mahasiswa dengan NIM
- ✅ JWT Token authentication
- ✅ Protected routes & authorization
- ✅ Session persistence

### 📊 Manajemen Proyek
- ✅ **Wizard multi-step** untuk pembuatan proyek baru
- ✅ Hierarki: **Project → Work → Activity**
- ✅ CRUD lengkap (Create, Read, Update, Delete)
- ✅ **Inline edit** untuk rename (hover → edit icon)
- ✅ Status tracking & close project
- ✅ Filter & search

### 🏗️ Pekerjaan (Works)
- ✅ Kategori: Engineering, Creation, Implementation
- ✅ Multiple works per project
- ✅ Date range & executor tracking
- ✅ Location & supervisor management

### 📝 Aktivitas (Activities)
- ✅ Detail tracking: nama, waktu eksekusi, pelaksana
- ✅ **Toggle status** "Mark as Done" / "Done"
- ✅ **Upload foto dokumentasi** (multiple photos)
- ✅ **Form evaluasi** terpisah di modal
- ✅ Additional planning notes

### 📸 Dokumentasi Foto
- ✅ Upload multiple photos per activity
- ✅ Base64 encoding → Server file storage
- ✅ Preview thumbnail
- ✅ Validasi file type & size (max 5MB)

### 🎨 UI/UX
- ✅ **Desain modern & clean** (putih dominan + aksen merah #B91C1C)
- ✅ **Fully responsive** (desktop, tablet, mobile)
- ✅ Header dengan menu hamburger untuk mobile
- ✅ Modal → Bottom sheet di mobile
- ✅ **Toast notifications** (pojok kanan atas)
- ✅ Loading states & error handling

---

## 🚀 Quick Start

### 📋 Prerequisites
- Node.js 18+ dan pnpm
- Python 3.9+
- Git

### ⚡ 1-Click Start

**Windows:**
```bash
START-WINDOWS.bat
```

**Linux/Mac:**
```bash
chmod +x START-LINUX-MAC.sh
./START-LINUX-MAC.sh
```

### 🔧 Manual Setup

#### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate    # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

#### Frontend
```bash
pnpm install
pnpm dev
```

**Aplikasi akan berjalan di:**
- Frontend: http://localhost:5173
- Backend API: http://localhost:8000/api
- Admin Panel: http://localhost:8000/admin

---

## 📚 Dokumentasi Lengkap

| File | Deskripsi |
|------|-----------|
| **[START.md](START.md)** | ⭐ Quick start guide |
| **[SETUP_GUIDE.md](SETUP_GUIDE.md)** | Setup lengkap & deployment |
| **[MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)** | Migrasi localStorage → Django API |
| **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** | Struktur project & file |
| **[QUICK_COMMANDS.md](QUICK_COMMANDS.md)** | Command reference cheat sheet |
| **[backend/README.md](backend/README.md)** | Backend API documentation |

---

## 🏗️ Tech Stack

### Frontend
- **React 18** - UI Library
- **TypeScript** - Type safety
- **Vite** - Build tool & dev server
- **React Router 7** - Client-side routing
- **Tailwind CSS v4** - Styling
- **shadcn/ui** - Component library
- **Radix UI** - Headless UI primitives
- **Sonner** - Toast notifications
- **Lucide React** - Icons

### Backend
- **Django 5** - Web framework
- **Django REST Framework** - REST API
- **PyJWT** - JWT authentication
- **Pillow** - Image processing
- **CORS Headers** - Cross-origin support
- **SQLite** (dev) / **PostgreSQL** (prod)

---

## 📂 Struktur Project

```
promanage/
├── src/                          # Frontend React
│   ├── app/
│   │   ├── components/          # UI Components
│   │   ├── context/             # Auth & Project Context
│   │   ├── pages/               # Page components
│   │   ├── services/            # API services
│   │   └── routes.tsx           # React Router config
│   └── styles/                  # CSS & Theme
│
├── backend/                      # Django Backend
│   ├── backend/                 # Django settings
│   ├── api/                     # REST API app
│   │   ├── models.py           # Database models
│   │   ├── serializers.py      # API serializers
│   │   ├── views.py            # API endpoints
│   │   └── authentication.py   # JWT auth
│   └── requirements.txt        # Python dependencies
│
├── .env                         # Frontend environment
├── .env.backend                 # Backend environment
└── Documentation files...
```

---

## 🔌 API Endpoints

### Authentication
```
POST /api/auth/register/     Register user baru
POST /api/auth/login/        Login user
GET  /api/users/me/          Current user info
```

### Projects
```
GET    /api/projects/              List all projects
POST   /api/projects/              Create project
GET    /api/projects/{id}/         Project detail
PATCH  /api/projects/{id}/         Update project
DELETE /api/projects/{id}/         Delete project
PATCH  /api/projects/{id}/close/   Close project
PATCH  /api/projects/{id}/rename/  Rename project
```

### Works
```
GET    /api/works/by_project/?project_id={id}  List works
POST   /api/works/                              Create work
PATCH  /api/works/{id}/rename/                  Rename work
DELETE /api/works/{id}/                         Delete work
```

### Activities
```
GET    /api/activities/by_work/?work_id={id}   List activities
POST   /api/activities/                         Create activity
PATCH  /api/activities/{id}/                    Update activity
PATCH  /api/activities/{id}/toggle_done/        Toggle done status
DELETE /api/activities/{id}/                    Delete activity
```

---

## 🔐 Environment Variables

### Frontend (`.env`)
```env
VITE_API_URL=http://localhost:8000/api
VITE_API_TIMEOUT=30000
```

### Backend (`.env.backend`)
```env
SECRET_KEY=your-secret-key
DEBUG=True
DATABASE_ENGINE=django.db.backends.sqlite3
DATABASE_NAME=db.sqlite3
CORS_ALLOWED_ORIGINS=http://localhost:5173
JWT_SECRET_KEY=your-jwt-secret
JWT_EXPIRATION_DAYS=7
MAX_UPLOAD_SIZE=5242880
```

**Template tersedia di:**
- `.env.example`
- `backend/.env.example`

---

## 🧪 Testing

### Create Test Data
```bash
cd backend
python manage.py shell < create_test_data.py
```

**Test credentials:**
- Email: `test@promanage.com`
- Password: `password123`

### API Testing dengan curl
```bash
# Register
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"name":"John","nim":"123","email":"john@test.com","password":"pass123"}'

# Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"john@test.com","password":"pass123"}'
```

Lihat [QUICK_COMMANDS.md](QUICK_COMMANDS.md) untuk lebih banyak contoh.

---

## 📦 Deployment

### Backend (Railway / Render / DigitalOcean)

1. **Environment Variables:**
   ```env
   DEBUG=False
   SECRET_KEY=<generate-baru>
   ALLOWED_HOSTS=yourdomain.com
   DATABASE_URL=<postgresql-url>
   ```

2. **Install dependencies:**
   ```bash
   pip install -r requirements-prod.txt
   ```

3. **Run migrations & collect static:**
   ```bash
   python manage.py migrate
   python manage.py collectstatic --noinput
   ```

4. **Run with Gunicorn:**
   ```bash
   gunicorn backend.wsgi:application
   ```

### Frontend (Vercel / Netlify)

1. **Build:**
   ```bash
   pnpm build
   ```

2. **Environment Variables:**
   ```env
   VITE_API_URL=https://your-backend-api.com/api
   ```

3. **Deploy:**
   ```bash
   vercel deploy  # atau
   netlify deploy --prod
   ```

Lihat [SETUP_GUIDE.md](SETUP_GUIDE.md) untuk detail deployment.

---

## 🐛 Troubleshooting

### CORS Error
**Problem:** Frontend tidak bisa akses backend

**Solution:** Check `CORS_ALLOWED_ORIGINS` di `backend/backend/settings.py`:
```python
CORS_ALLOWED_ORIGINS = [
    'http://localhost:5173',
]
```

### Port Already in Use
```bash
# Backend - ganti port
python manage.py runserver 8001

# Frontend
PORT=3000 pnpm dev
```

### Database Reset
```bash
cd backend
rm db.sqlite3
python manage.py migrate
```

Lihat [QUICK_COMMANDS.md](QUICK_COMMANDS.md) untuk solusi lainnya.

---

## 🔄 Status Development

### ✅ Implemented (Current)
- [x] Authentication (Register, Login, Logout)
- [x] Context API + localStorage
- [x] CRUD Projects, Works, Activities
- [x] Inline edit untuk rename
- [x] Upload foto dokumentasi
- [x] Toast notifications
- [x] Responsive design
- [x] Django REST API backend
- [x] JWT authentication
- [x] File upload API

### 🚧 Migration to API (Optional)
- [ ] Update AuthContext menggunakan API
- [ ] Update ProjectContext menggunakan API
- [ ] Real-time sync dengan backend
- [ ] Error handling & retry logic
- [ ] Loading states improvement

### 🎯 Future Enhancements
- [ ] React Query untuk data fetching
- [ ] Real-time updates (WebSocket)
- [ ] Export data (PDF, Excel)
- [ ] Calendar view untuk timeline
- [ ] Team collaboration features
- [ ] Email notifications
- [ ] Advanced analytics & reports

---

## 📝 Migration Guide

Aplikasi saat ini menggunakan **Context API + localStorage**. Untuk migrasi ke **Django REST API**, ikuti langkah di [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md).

**Summary:**
1. Backend Django sudah siap dengan REST API
2. API service tersedia di `src/app/services/api.ts`
3. Update Context untuk pakai API calls
4. Test & deploy

---

## 🤝 Contributing

Contributions are welcome! Untuk berkontribusi:

1. Fork repository
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License - bebas digunakan untuk project mahasiswa & komersial.

---

## 👨‍💻 Developer

Developed with ❤️ for students by students.

**Tech Support:**
- Documentation: Lihat folder root untuk semua .md files
- Issues: Buka issue di repository
- Django Docs: https://docs.djangoproject.com/
- React Docs: https://react.dev/

---

## 📞 Quick Links

- 📖 [Quick Start Guide](START.md)
- 🔧 [Setup Guide](SETUP_GUIDE.md)
- 🔄 [Migration Guide](MIGRATION_GUIDE.md)
- 📂 [Project Structure](PROJECT_STRUCTURE.md)
- ⚡ [Quick Commands](QUICK_COMMANDS.md)
- 🔌 [Backend API Docs](backend/README.md)

---

## 🎉 Features Showcase

### Wizard Multi-Step
Pembuatan proyek dengan wizard yang memandu user step-by-step:
1. Data Proyek → 2. Tambah Pekerjaan → 3. Tambah Aktivitas

### Inline Edit
Hover pada nama project/work/activity → klik icon pensil → edit langsung → Enter untuk save

### Photo Upload
Upload multiple photos per activity dengan preview thumbnail dan validasi file

### Responsive Design
Mobile-first design dengan bottom sheet untuk modal di perangkat kecil

### Toast Notifications
Notifikasi real-time di pojok kanan atas untuk setiap aksi (create, update, delete)

---

**⭐ Star repository ini jika bermanfaat!**

**🚀 Happy Coding & Good Luck with Your Projects!**
