# ⚡ Quick Commands Reference

Cheat sheet untuk command yang sering dipakai.

## 🚀 Startup

### Jalankan Aplikasi Lengkap
```bash
# Windows
START-WINDOWS.bat

# Linux/Mac
chmod +x START-LINUX-MAC.sh
./START-LINUX-MAC.sh
```

### Manual Start
```bash
# Terminal 1 - Backend
cd backend
source venv/bin/activate    # Windows: venv\Scripts\activate
python manage.py runserver

# Terminal 2 - Frontend
pnpm dev
```

## 🔧 Backend (Django)

### Setup & Installation
```bash
cd backend
python -m venv venv
source venv/bin/activate    # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Database
```bash
# Create migrations
python manage.py makemigrations

# Run migrations
python manage.py migrate

# Reset database
rm db.sqlite3
python manage.py migrate

# Create test data
python manage.py shell < create_test_data.py
```

### User Management
```bash
# Create superuser
python manage.py createsuperuser

# Shell (Python REPL)
python manage.py shell
```

### Server
```bash
# Run server (default port 8000)
python manage.py runserver

# Run on different port
python manage.py runserver 8001

# Run on all interfaces
python manage.py runserver 0.0.0.0:8000
```

### Utilities
```bash
# Show all URLs
python manage.py show_urls  # Jika django-extensions installed

# Collect static files
python manage.py collectstatic

# Check for issues
python manage.py check

# Database shell
python manage.py dbshell
```

## 💻 Frontend (React)

### Installation
```bash
# Install dependencies
pnpm install

# Install specific package
pnpm add <package-name>

# Install dev dependency
pnpm add -D <package-name>
```

### Development
```bash
# Start dev server (port 5173)
pnpm dev

# Start on different port
PORT=3000 pnpm dev

# Build for production
pnpm build

# Preview production build
pnpm preview
```

### Cleanup
```bash
# Remove node_modules
rm -rf node_modules
pnpm install

# Clear cache
rm -rf node_modules/.vite
pnpm dev
```

## 🗄️ Database Operations

### SQLite (Development)
```bash
# Open database
cd backend
sqlite3 db.sqlite3

# Common SQLite commands
.tables                 # List tables
.schema tablename       # Show schema
SELECT * FROM users;    # Query
.exit                   # Exit
```

### PostgreSQL (Production)
```bash
# Connect to database
psql -U username -d dbname

# Common psql commands
\dt                     # List tables
\d tablename            # Describe table
SELECT * FROM users;    # Query
\q                      # Exit
```

## 🔐 Authentication Testing

### Register User (curl)
```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "nim": "123456",
    "email": "john@example.com",
    "password": "password123"
  }'
```

### Login (curl)
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }'
```

### API Request with Token (curl)
```bash
TOKEN="your_jwt_token_here"

curl http://localhost:8000/api/projects/ \
  -H "Authorization: Bearer $TOKEN"
```

## 📊 Projects API Testing

### Create Project
```bash
curl -X POST http://localhost:8000/api/projects/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Project",
    "description": "Project description",
    "location": "Kampus",
    "start_date": "2026-04-22",
    "end_date": "2026-12-31",
    "executor": "Tim A",
    "supervisor": "Dr. Budi"
  }'
```

### List Projects
```bash
curl http://localhost:8000/api/projects/ \
  -H "Authorization: Bearer $TOKEN"
```

### Get Project Detail
```bash
curl http://localhost:8000/api/projects/123/ \
  -H "Authorization: Bearer $TOKEN"
```

### Delete Project
```bash
curl -X DELETE http://localhost:8000/api/projects/123/ \
  -H "Authorization: Bearer $TOKEN"
```

## 🏗️ Works & Activities

### Create Work
```bash
curl -X POST http://localhost:8000/api/works/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": "123",
    "name": "Work 1",
    "description": "Description",
    "location": "Lab",
    "start_date": "2026-04-22",
    "end_date": "2026-05-22",
    "executor": "Team",
    "supervisor": "Supervisor",
    "category": "engineering"
  }'
```

### Create Activity with Photos
```bash
curl -X POST http://localhost:8000/api/activities/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "work_id": "456",
    "name": "Activity 1",
    "execution_time": "2 jam",
    "executor": "John",
    "photos": [
      "data:image/png;base64,iVBORw0KGgo..."
    ]
  }'
```

## 🐛 Debugging

### View Logs
```bash
# Backend logs (console output)
# Check terminal running python manage.py runserver

# Frontend logs
# Check browser console (F12)
```

### Check Running Processes
```bash
# Linux/Mac
lsof -i :8000    # Check port 8000
lsof -i :5173    # Check port 5173

# Windows
netstat -ano | findstr :8000
netstat -ano | findstr :5173
```

### Kill Process on Port
```bash
# Linux/Mac
kill -9 $(lsof -t -i:8000)

# Windows
# Find PID first, then:
taskkill /PID <pid> /F
```

## 📦 Deployment

### Backend to Railway/Render
```bash
# Install production dependencies
pip install -r requirements-prod.txt

# Set environment variables in platform dashboard
# DATABASE_URL, SECRET_KEY, DEBUG=False, etc.

# Run migrations
python manage.py migrate

# Collect static
python manage.py collectstatic --noinput

# Run with gunicorn
gunicorn backend.wsgi:application
```

### Frontend to Vercel/Netlify
```bash
# Build
pnpm build

# Test build locally
pnpm preview

# Deploy (Vercel)
vercel deploy

# Deploy (Netlify)
netlify deploy --prod
```

## 🔄 Git Commands

### Basic Workflow
```bash
# Check status
git status

# Add files
git add .
git add specific-file.txt

# Commit
git commit -m "Message"

# Push
git push origin main

# Pull
git pull origin main
```

### Branch Management
```bash
# Create branch
git checkout -b feature/new-feature

# Switch branch
git checkout main

# Merge branch
git merge feature/new-feature

# Delete branch
git branch -d feature/new-feature
```

## 🧪 Testing

### Backend Tests
```bash
cd backend

# Run all tests
python manage.py test

# Run specific app
python manage.py test api

# Run with verbosity
python manage.py test --verbosity=2

# With coverage
pip install coverage
coverage run --source='.' manage.py test
coverage report
coverage html  # Generate HTML report
```

## 📊 Performance

### Backend Performance
```bash
# Install django-debug-toolbar
pip install django-debug-toolbar

# Add to INSTALLED_APPS in settings.py
# View SQL queries, templates, etc.
```

### Frontend Performance
```bash
# Analyze bundle size
pnpm build
npx vite-bundle-visualizer
```

## 🔍 Health Checks

### Quick Health Check
```bash
# Backend health
curl http://localhost:8000/api/health/

# Frontend
curl http://localhost:5173/

# Expected responses:
# Backend: {"status": "OK", ...}
# Frontend: HTML content
```

## 💡 Pro Tips

### Environment Variables
```bash
# Load .env in bash
export $(cat .env | xargs)

# Load .env.backend
export $(cat .env.backend | xargs)
```

### Quick Project Status
```bash
# Backend: Count records
cd backend
python manage.py shell
>>> from api.models import User, Project, Work, Activity
>>> print(f"Users: {User.objects.count()}")
>>> print(f"Projects: {Project.objects.count()}")
>>> print(f"Works: {Work.objects.count()}")
>>> print(f"Activities: {Activity.objects.count()}")
```

### Database Backup & Restore
```bash
# Backup SQLite
cp backend/db.sqlite3 backend/db.backup.sqlite3

# Restore
cp backend/db.backup.sqlite3 backend/db.sqlite3

# Export data to JSON
python manage.py dumpdata > backup.json

# Import data from JSON
python manage.py loaddata backup.json
```

## 📞 Emergency Commands

### Complete Reset
```bash
# Backend
cd backend
rm db.sqlite3
rm -rf api/migrations/*
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser

# Frontend
rm -rf node_modules
rm pnpm-lock.yaml
pnpm install
```

### Force Stop All
```bash
# Linux/Mac
pkill -f "manage.py runserver"
pkill -f "vite"

# Windows
taskkill /F /IM python.exe
taskkill /F /IM node.exe
```

---

**💾 Bookmark file ini untuk akses cepat ke semua commands!**
