# 🎉 ProManage - Django Full Stack Application

Aplikasi ProManage sekarang **fully integrated dengan Django**! Semua halaman React sudah dikonversi ke Django Templates. Tidak perlu lagi `npm`, `pnpm`, atau `Vite` — cukup jalankan Django server dan semua fitur sudah berfungsi!

## ✨ Yang Sudah Terintegrasi

### 🎨 Frontend (Django Templates)
- ✅ **Home Page** - Landing page dengan hero section & features
- ✅ **About Page** - Informasi tim & visi misi
- ✅ **Projects Page** - Dashboard untuk manage projects (perlu login)
- ✅ **Project Detail** - Detail project & list works
- ✅ **Work Detail** - Detail work & list activities
- ✅ **Login/Register Modal** - Authentication UI
- ✅ **Header Component** - Navigation dengan auth status
- ✅ **Responsive Design** - Mobile & desktop friendly
- ✅ **Toast Notifications** - Notifikasi real-time

### 🔧 Backend (Django + DRF)
- ✅ **REST API** - Endpoints lengkap untuk CRUD
- ✅ **JWT Authentication** - Token-based auth
- ✅ **Database Models** - User, Project, Work, Activity
- ✅ **Admin Panel** - Django admin untuk manage data
- ✅ **CORS Support** - Cross-origin ready
- ✅ **File Upload** - Support upload foto

## 🚀 Quick Start

### Option 1: Auto Script (RECOMMENDED)

**Windows:**
```bash
RUN-DJANGO.bat
```

**Linux/Mac:**
```bash
chmod +x RUN-DJANGO.sh
./RUN-DJANGO.sh
```

Script akan:
1. ✅ Buat virtual environment (jika belum ada)
2. ✅ Install dependencies
3. ✅ Setup database (migrate)
4. ✅ (Optional) Create test data
5. ✅ Run Django server

**Aplikasi langsung jalan di: http://localhost:8000**

### Option 2: Manual

```bash
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

Buka: **http://localhost:8000**

## 📖 Panduan Lengkap

Lihat file **[DJANGO_QUICKSTART.md](backend/DJANGO_QUICKSTART.md)** untuk dokumentasi lengkap.

## 🌐 Halaman & Endpoints

### Halaman Web (Templates)

| URL | Deskripsi | Auth Required |
|-----|-----------|---------------|
| `/` | Home page | ❌ |
| `/about` | About page | ❌ |
| `/projects` | Projects dashboard | ✅ |
| `/projects/<id>/` | Project detail | ✅ |
| `/works/<id>/` | Work detail | ✅ |
| `/admin` | Admin panel | ✅ (superuser) |

### API Endpoints

| Endpoint | Method | Deskripsi |
|----------|--------|-----------|
| `/api/auth/register/` | POST | Register |
| `/api/auth/login/` | POST | Login |
| `/api/projects/` | GET/POST | List/Create projects |
| `/api/projects/<id>/` | GET/PUT/DELETE | Project CRUD |
| `/api/works/` | GET/POST | List/Create works |
| `/api/activities/` | GET/POST | List/Create activities |

## 🔑 Test Account

Jika create test data saat setup:

```
Email: test@promanage.com
Password: password123
```

Atau buat superuser:
```bash
cd backend
python manage.py createsuperuser
```

## 💡 Cara Kerja

1. **User** buka browser → `http://localhost:8000`
2. **Django** render template `home.html`
3. **User** klik "Mulai Sekarang" → Modal login muncul
4. **JavaScript** call `/api/auth/login/` → Django return JWT token
5. **Token** disimpan di `localStorage`
6. **User** redirect ke `/projects`
7. **JavaScript** fetch data dari `/api/projects/` dengan token
8. **Django** verify token → return data user tersebut
9. **JavaScript** render data di halaman

## 🎨 Tech Stack

| Layer | Technology |
|-------|------------|
| Templates | Django Templates |
| Styling | Tailwind CSS (CDN) |
| JavaScript | Vanilla JS (no framework!) |
| Icons | Lucide Icons (CDN) |
| Backend | Django 5.0 |
| API | Django REST Framework |
| Auth | JWT (PyJWT) |
| Database | SQLite (dev) / PostgreSQL (prod) |

## 📁 Struktur File

```
promanage/
├── backend/
│   ├── api/
│   │   ├── templates/              # Django Templates
│   │   │   ├── base.html          # Base template
│   │   │   ├── home.html          # Home page
│   │   │   ├── about.html         # About page
│   │   │   ├── projects.html      # Projects list
│   │   │   ├── project_detail.html
│   │   │   ├── work_detail.html
│   │   │   └── components/
│   │   │       ├── header.html
│   │   │       └── login_modal.html
│   │   ├── models.py              # Database models
│   │   ├── views.py               # Template & API views
│   │   ├── serializers.py         # DRF serializers
│   │   └── urls.py                # URL routing
│   ├── backend/
│   │   ├── settings.py            # Django config
│   │   └── urls.py                # Root URLs
│   ├── manage.py                  # Django CLI
│   ├── requirements.txt           # Python deps
│   └── db.sqlite3                 # SQLite DB
├── RUN-DJANGO.sh                  # Start script (Linux/Mac)
├── RUN-DJANGO.bat                 # Start script (Windows)
├── DJANGO_README.md               # This file
└── DJANGO_QUICKSTART.md           # Full documentation
```

## 🔧 Development

### Run Migrations
```bash
cd backend
python manage.py makemigrations
python manage.py migrate
```

### Create Superuser
```bash
python manage.py createsuperuser
```

### Reset Database
```bash
rm db.sqlite3
python manage.py migrate
```

### Run Tests
```bash
python manage.py test
```

## 📱 Features

### ✅ Sudah Berfungsi
- Home page dengan hero & features section
- About page dengan team info
- Projects list & create
- Project detail dengan list works
- Work detail dengan list activities
- Login & Register
- Header dengan auth status
- Responsive mobile & desktop
- Toast notifications
- JWT authentication

### 🚧 Perlu Ditambahkan (Optional)
- Form wizard untuk create project
- Inline edit untuk rename
- Upload foto UI
- Delete & update modals
- Evaluasi form detail
- Close project functionality

## 🐛 Troubleshooting

### Port 8000 Already in Use
```bash
# Ganti port
python manage.py runserver 8001
```

### Template Not Found
Check `settings.py`:
```python
TEMPLATES = [{
    'DIRS': [BASE_DIR / 'api' / 'templates'],
    ...
}]
```

### API 404 Error
Pastikan URL di JavaScript pakai `/api/` prefix

### Cannot Login
1. Check backend running
2. Check browser console untuk errors
3. Verify token di localStorage

## 📞 Support

- Django Docs: https://docs.djangoproject.com/
- DRF Docs: https://www.django-rest-framework.org/
- Tailwind CSS: https://tailwindcss.com/

## 🎯 Next Steps

1. ✅ Jalankan aplikasi dengan script
2. ✅ Buka http://localhost:8000
3. ✅ Register atau login
4. ✅ Mulai manage projects!

---

**🎉 Aplikasi sudah siap digunakan!**

Cukup jalankan `RUN-DJANGO.bat` (Windows) atau `./RUN-DJANGO.sh` (Linux/Mac), lalu buka browser ke http://localhost:8000.

**No npm, no pnpm, no vite — just pure Django! 🚀**
