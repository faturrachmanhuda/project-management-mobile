# 📁 Struktur Project ProManage

Dokumen ini menjelaskan struktur lengkap project dan fungsi setiap file/folder.

## 🌳 Tree Structure

```
promanage/
│
├── 📱 FRONTEND (React + Vite + TypeScript)
│   ├── src/
│   │   ├── app/
│   │   │   ├── components/          # React Components
│   │   │   │   ├── ui/             # shadcn/ui components
│   │   │   │   ├── AuthGuard.tsx   # Protected route wrapper
│   │   │   │   ├── Header.tsx      # App header with auth
│   │   │   │   ├── InlineEdit.tsx  # Inline edit component
│   │   │   │   └── LoginModal.tsx  # Login/Register modal
│   │   │   │
│   │   │   ├── context/            # React Context API
│   │   │   │   ├── AuthContext.tsx      # Authentication state
│   │   │   │   └── ProjectContext.tsx   # Project/Work/Activity state
│   │   │   │
│   │   │   ├── pages/              # Page components
│   │   │   │   ├── Home.tsx             # Landing page
│   │   │   │   ├── AboutUs.tsx          # About page
│   │   │   │   ├── ProjectManagement.tsx # Main dashboard
│   │   │   │   ├── ProjectDetail.tsx    # Project detail page
│   │   │   │   └── WorkDetail.tsx       # Work detail page
│   │   │   │
│   │   │   ├── services/           # API Services
│   │   │   │   └── api.ts          # Django API client
│   │   │   │
│   │   │   ├── App.tsx             # Root component
│   │   │   └── routes.tsx          # React Router config
│   │   │
│   │   └── styles/                 # CSS & Theme
│   │       ├── fonts.css           # Font imports
│   │       └── theme.css           # Theme variables
│   │
│   ├── .env                        # Frontend environment variables
│   ├── package.json                # Frontend dependencies
│   ├── vite.config.ts              # Vite configuration
│   └── tsconfig.json               # TypeScript config
│
├── 🔧 BACKEND (Django + DRF)
│   ├── backend/                    # Django project folder
│   │   ├── __init__.py
│   │   ├── settings.py             # Django settings ⭐
│   │   ├── urls.py                 # Root URL config
│   │   ├── wsgi.py                 # WSGI entry point
│   │   └── asgi.py                 # ASGI entry point
│   │
│   ├── api/                        # Django app untuk REST API
│   │   ├── __init__.py
│   │   ├── models.py               # Database models ⭐
│   │   ├── serializers.py          # DRF serializers ⭐
│   │   ├── views.py                # API views ⭐
│   │   ├── urls.py                 # API URL routing ⭐
│   │   ├── admin.py                # Django admin config
│   │   ├── apps.py                 # App config
│   │   ├── authentication.py       # JWT authentication ⭐
│   │   ├── permissions.py          # Custom permissions
│   │   └── exceptions.py           # Custom exception handler
│   │
│   ├── media/                      # Uploaded files (gitignored)
│   ├── staticfiles/                # Collected static files (gitignored)
│   ├── db.sqlite3                  # SQLite database (gitignored)
│   │
│   ├── .env.backend                # Backend environment variables
│   ├── requirements.txt            # Python dependencies (dev)
│   ├── requirements-prod.txt       # Python dependencies (prod)
│   ├── manage.py                   # Django CLI
│   ├── Procfile                    # For Heroku/Railway deployment
│   ├── runtime.txt                 # Python version
│   ├── .gitignore                  # Git ignore rules
│   │
│   ├── setup.sh                    # Setup script (Linux/Mac)
│   ├── setup.bat                   # Setup script (Windows)
│   ├── create_test_data.py         # Test data generator
│   └── README.md                   # Backend documentation
│
├── 📚 DOCUMENTATION
│   ├── START.md                    # Quick start guide ⭐
│   ├── SETUP_GUIDE.md              # Complete setup guide ⭐
│   ├── MIGRATION_GUIDE.md          # localStorage → API migration ⭐
│   └── PROJECT_STRUCTURE.md        # This file
│
├── 🚀 STARTUP SCRIPTS
│   ├── START-WINDOWS.bat           # Windows startup script
│   └── START-LINUX-MAC.sh          # Linux/Mac startup script
│
└── 📝 PROJECT FILES
    ├── package.json                # Frontend package config
    ├── pnpm-lock.yaml              # pnpm lockfile
    ├── .gitignore                  # Git ignore rules
    └── README.md                   # Project README
```

## 🎯 File Penting (⭐ = Must Know)

### Frontend

| File | Fungsi | Catatan |
|------|--------|---------|
| `src/app/App.tsx` | Root component | Entry point aplikasi |
| `src/app/routes.tsx` | React Router config | Define semua routes |
| `src/app/context/AuthContext.tsx` | Auth state management | Login, register, logout |
| `src/app/context/ProjectContext.tsx` | Project state | CRUD projects/works/activities |
| `src/app/services/api.ts` | API client | Untuk integrasi dengan backend |
| `.env` | Environment variables | API URL, config |

### Backend

| File | Fungsi | Catatan |
|------|--------|---------|
| `backend/settings.py` | Django config | Database, CORS, JWT settings |
| `api/models.py` | Database schema | User, Project, Work, Activity |
| `api/serializers.py` | Data serialization | JSON ↔ Model conversion |
| `api/views.py` | API endpoints | Business logic |
| `api/urls.py` | API routing | URL → View mapping |
| `api/authentication.py` | JWT auth | Token generation & validation |
| `.env.backend` | Environment variables | Secret keys, database config |

### Documentation

| File | Untuk Apa | Kapan Dibaca |
|------|----------|--------------|
| `START.md` | Quick start | Pertama kali clone project |
| `SETUP_GUIDE.md` | Setup lengkap | Setup production/deployment |
| `MIGRATION_GUIDE.md` | Migrasi localStorage → API | Saat mau pakai backend API |
| `backend/README.md` | Backend docs | Setup & API reference |

## 🔄 Data Flow

### Current (localStorage)
```
User Input → Context API → localStorage → Browser
```

### After Migration (API)
```
User Input → Context API → API Service → Django Backend → Database
                                ↓
                            JWT Token in localStorage
```

## 📊 Database Schema

### User
- id (UUID)
- email (unique)
- nim (unique)
- name
- password (hashed)
- is_active
- created_at, updated_at

### Project
- id (string)
- user (FK → User)
- name, description, location
- start_date, end_date
- executor, supervisor
- status (Aktif/Selesai/Tertunda)
- is_closed
- created_at, updated_at

### Work
- id (string)
- project (FK → Project)
- name, description, location
- start_date, end_date
- executor, supervisor
- category (engineering/creation/implementation)
- created_at, updated_at

### Activity
- id (string)
- work (FK → Work)
- name, execution_time, executor
- done (boolean)
- evaluation, additional_plan
- created_at, updated_at

### ActivityPhoto
- id (UUID)
- activity (FK → Activity)
- photo (ImageField)
- uploaded_at

## 🔐 Authentication

### JWT Token Structure
```json
{
  "user_id": "uuid",
  "email": "user@example.com",
  "exp": 1234567890,
  "iat": 1234567890
}
```

### Request Header
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 🎨 Styling

### Colors
- **Primary**: `#B91C1C` (red-700) - Aksen merah gelap
- **Background**: `#FFFFFF` - Putih dominan
- **Text**: Default dari theme.css

### Framework
- **Tailwind CSS v4** - Utility-first CSS
- **shadcn/ui** - Component library
- **Radix UI** - Headless UI primitives

### Fonts
- Defined in `src/styles/fonts.css`
- System fonts with fallbacks

## 🛠️ Development Tools

### Frontend
- **Vite** - Build tool & dev server
- **TypeScript** - Type safety
- **React Router** - Client-side routing
- **Sonner** - Toast notifications
- **Lucide React** - Icons

### Backend
- **Django** - Web framework
- **Django REST Framework** - REST API
- **PyJWT** - JWT authentication
- **Pillow** - Image processing
- **CORS Headers** - Cross-origin requests

## 📦 Package Management

### Frontend
- **pnpm** - Fast, disk space efficient package manager
- Lock file: `pnpm-lock.yaml`

### Backend
- **pip** - Python package installer
- Virtual environment: `backend/venv/`
- Requirements: `requirements.txt`

## 🔀 Git Workflow

### Branches (Suggested)
```
main/master     → Production-ready code
develop         → Development branch
feature/*       → New features
bugfix/*        → Bug fixes
hotfix/*        → Production hotfixes
```

### .gitignore Important Entries
```
# Frontend
node_modules/
dist/
.env.local

# Backend
__pycache__/
*.pyc
venv/
db.sqlite3
media/
.env
.env.backend
```

## 🚀 Deployment

### Frontend (Vercel/Netlify)
1. Build: `pnpm build`
2. Deploy folder: `dist/`
3. Environment: `VITE_API_URL`

### Backend (Railway/Render)
1. Database: PostgreSQL
2. Server: Gunicorn
3. Static: WhiteNoise
4. Environment: Multiple vars in `.env.backend`

## 📈 Scaling Considerations

### Database
- Start: SQLite (development)
- Production: PostgreSQL/MySQL
- Large scale: Add caching (Redis)

### File Storage
- Start: Local filesystem
- Production: AWS S3/Cloudinary

### Performance
- Add: React Query untuk caching
- Add: Database indexing
- Add: API pagination
- Add: Image optimization

## 🧪 Testing (Future)

### Frontend
```bash
# Belum implemented, tapi bisa pakai:
pnpm add -D vitest @testing-library/react
```

### Backend
```bash
cd backend
python manage.py test
```

## 📝 Notes

- **Environment files** (`.env`, `.env.backend`) tidak di-commit ke git
- **Database** SQLite untuk development, PostgreSQL untuk production
- **API URL** harus sesuai antara frontend `.env` dan backend running port
- **CORS** harus di-configure agar frontend bisa akses backend
- **JWT Token** expired dalam 7 hari (configurable di `.env.backend`)

## 🔍 Quick Reference

### Start Development
```bash
./START-WINDOWS.bat        # Windows
./START-LINUX-MAC.sh       # Linux/Mac
```

### Backend Commands
```bash
cd backend
python manage.py runserver              # Run server
python manage.py migrate                # Run migrations
python manage.py makemigrations         # Create migrations
python manage.py createsuperuser        # Create admin
python manage.py shell                  # Django shell
```

### Frontend Commands
```bash
pnpm dev         # Start dev server
pnpm build       # Build for production
pnpm preview     # Preview production build
```

---

**💡 Tip**: Bookmark file ini untuk referensi cepat tentang struktur project!
