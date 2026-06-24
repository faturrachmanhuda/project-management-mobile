# ProManage - Panduan Setup Lengkap

Panduan lengkap untuk menjalankan aplikasi ProManage (Frontend React + Backend Django)

## 📋 Prasyarat

- Node.js 18+ dan pnpm
- Python 3.9+
- Git

## 🚀 Quick Start

### 1. Clone & Install

```bash
# Clone repository
git clone <repository-url>
cd <project-folder>

# Install frontend dependencies
pnpm install
```

### 2. Setup Backend

#### Linux/Mac:

```bash
cd backend
chmod +x setup.sh
./setup.sh
```

#### Windows:

```bash
cd backend
setup.bat
```

#### Manual Setup:

```bash
cd backend

# Create virtual environment
python -m venv venv

# Activate (Linux/Mac)
source venv/bin/activate
# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser (optional)
python manage.py createsuperuser
```

### 3. Konfigurasi Environment

File `.env` dan `.env.backend` sudah tersedia. Edit jika perlu:

**`.env`** (Frontend):
```env
VITE_API_URL=http://localhost:8000/api
```

**`.env.backend`** (Backend):
```env
SECRET_KEY=your-secret-key
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
```

### 4. Jalankan Aplikasi

**Terminal 1 - Backend:**
```bash
cd backend
source venv/bin/activate  # atau venv\Scripts\activate di Windows
python manage.py runserver
```

Backend akan berjalan di: `http://localhost:8000`

**Terminal 2 - Frontend:**
```bash
pnpm dev
```

Frontend akan berjalan di: `http://localhost:5173`

## 🗂️ Struktur Project

```
project/
├── src/                      # Frontend React
│   ├── app/
│   │   ├── components/      # UI Components
│   │   ├── context/         # Context API (Auth & Project)
│   │   ├── pages/           # Page components
│   │   └── routes.tsx       # React Router config
│   └── styles/              # CSS & Theme
├── backend/                  # Django Backend
│   ├── backend/             # Django settings
│   ├── api/                 # REST API app
│   │   ├── models.py        # Database models
│   │   ├── serializers.py   # API serializers
│   │   ├── views.py         # API endpoints
│   │   └── urls.py          # URL routing
│   ├── requirements.txt     # Python dependencies
│   └── manage.py            # Django CLI
├── .env                      # Frontend environment
├── .env.backend              # Backend environment
└── package.json              # Frontend dependencies
```

## 🔌 API Endpoints

### Authentication
- `POST /api/auth/register/` - Daftar user baru
- `POST /api/auth/login/` - Login

### Projects
- `GET /api/projects/` - List projects
- `POST /api/projects/` - Buat project
- `GET /api/projects/{id}/` - Detail project
- `PATCH /api/projects/{id}/rename/` - Rename project
- `PATCH /api/projects/{id}/close/` - Tutup project
- `DELETE /api/projects/{id}/` - Hapus project

### Works
- `GET /api/works/by_project/?project_id={id}` - List works by project
- `POST /api/works/` - Buat work
- `PATCH /api/works/{id}/rename/` - Rename work
- `DELETE /api/works/{id}/` - Hapus work

### Activities
- `GET /api/activities/by_work/?work_id={id}` - List activities by work
- `POST /api/activities/` - Buat activity (dengan foto)
- `PATCH /api/activities/{id}/` - Update activity
- `PATCH /api/activities/{id}/toggle_done/` - Toggle status
- `DELETE /api/activities/{id}/` - Hapus activity

## 🔐 Authentication Flow

1. User register/login di frontend
2. Backend return JWT token
3. Frontend simpan token di localStorage
4. Semua request ke API include header:
   ```
   Authorization: Bearer <jwt_token>
   ```

## 📸 Upload Foto

Frontend mengirim foto sebagai base64 string dalam array `photos`:

```json
{
  "work_id": "123",
  "name": "Aktivitas Test",
  "execution_time": "2 jam",
  "executor": "John Doe",
  "photos": [
    "data:image/png;base64,iVBORw0KGgoAAAA...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
  ]
}
```

## 🐛 Troubleshooting

### Backend tidak bisa diakses
- Pastikan backend running di port 8000
- Check CORS settings di `backend/backend/settings.py`
- Pastikan `.env.backend` sudah benar

### Frontend tidak connect ke backend
- Check `VITE_API_URL` di `.env`
- Buka browser console untuk error message
- Pastikan backend sudah running

### Migration error
```bash
cd backend
python manage.py makemigrations --empty api
python manage.py migrate
```

### Port sudah digunakan
```bash
# Backend - ganti port
python manage.py runserver 8001

# Frontend - ganti di package.json atau
PORT=3000 pnpm dev
```

## 📦 Deploy ke Production

### Backend (Railway/Render/DigitalOcean)

1. Set environment variables:
```env
DEBUG=False
SECRET_KEY=<generate-baru>
ALLOWED_HOSTS=yourdomain.com
DATABASE_ENGINE=django.db.backends.postgresql
DATABASE_NAME=...
DATABASE_USER=...
DATABASE_PASSWORD=...
```

2. Collect static files:
```bash
python manage.py collectstatic --noinput
```

3. Use Gunicorn:
```bash
pip install gunicorn
gunicorn backend.wsgi:application
```

### Frontend (Vercel/Netlify)

1. Build:
```bash
pnpm build
```

2. Set environment variable:
```env
VITE_API_URL=https://your-backend.com/api
```

3. Deploy folder `dist/`

## 📞 Support

Jika ada masalah:
1. Check dokumentasi Django: https://docs.djangoproject.com/
2. Check dokumentasi React: https://react.dev/
3. Buka issue di repository

## 📝 License

MIT License - bebas digunakan untuk project mahasiswa
