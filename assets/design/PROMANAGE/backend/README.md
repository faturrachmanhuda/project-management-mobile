# ProManage Django Backend

Backend REST API untuk aplikasi manajemen proyek mahasiswa menggunakan Django & Django REST Framework.

## Fitur

- Autentikasi JWT (Register, Login)
- CRUD untuk Projects, Works, dan Activities
- Upload foto dokumentasi aktivitas
- Filter data berdasarkan user yang login
- Permission system untuk akses data
- CORS enabled untuk frontend React

## Setup

### 1. Install Dependencies

```bash
cd backend
python -m venv venv
source venv/bin/activate  # di Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Environment Variables

Pastikan file `.env.backend` sudah ada di root project. Edit sesuai kebutuhan.

### 3. Database Migration

```bash
python manage.py makemigrations
python manage.py migrate
```

### 4. Create Superuser (Optional)

```bash
python manage.py createsuperuser
```

Isi data:
- Email: admin@promanage.com
- NIM: ADMIN001
- Name: Administrator
- Password: (pilih password)

### 5. Run Development Server

```bash
python manage.py runserver
```

Server akan berjalan di `http://localhost:8000`

## API Endpoints

### Authentication

- `POST /api/auth/register/` - Register user baru
  ```json
  {
    "name": "John Doe",
    "nim": "123456",
    "email": "john@example.com",
    "password": "password123"
  }
  ```

- `POST /api/auth/login/` - Login user
  ```json
  {
    "email": "john@example.com",
    "password": "password123"
  }
  ```

### Projects

- `GET /api/projects/` - List semua projects
- `POST /api/projects/` - Buat project baru
- `GET /api/projects/{id}/` - Detail project
- `PUT /api/projects/{id}/` - Update project
- `PATCH /api/projects/{id}/` - Partial update project
- `DELETE /api/projects/{id}/` - Hapus project
- `PATCH /api/projects/{id}/close/` - Tutup project
- `PATCH /api/projects/{id}/rename/` - Rename project

### Works

- `GET /api/works/` - List semua works
- `GET /api/works/by_project/?project_id={id}` - List works by project
- `POST /api/works/` - Buat work baru
- `GET /api/works/{id}/` - Detail work
- `PUT /api/works/{id}/` - Update work
- `DELETE /api/works/{id}/` - Hapus work
- `PATCH /api/works/{id}/rename/` - Rename work

### Activities

- `GET /api/activities/` - List semua activities
- `GET /api/activities/by_work/?work_id={id}` - List activities by work
- `POST /api/activities/` - Buat activity baru (dengan foto base64)
- `GET /api/activities/{id}/` - Detail activity
- `PUT /api/activities/{id}/` - Update activity
- `DELETE /api/activities/{id}/` - Hapus activity
- `PATCH /api/activities/{id}/toggle_done/` - Toggle status done

### Health Check

- `GET /api/health/` - Check API status

## Authentication

Semua endpoint (kecuali register & login) memerlukan JWT token di header:

```
Authorization: Bearer <your_jwt_token>
```

## Upload Foto

Untuk upload foto pada activity, kirim array base64 images di field `photos`:

```json
{
  "work_id": "123",
  "name": "Aktivitas Test",
  "execution_time": "2 jam",
  "executor": "John Doe",
  "photos": [
    "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgA...",
    "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYA..."
  ]
}
```

## Database

Default menggunakan SQLite. Untuk production, gunakan PostgreSQL dengan mengubah konfigurasi di `.env.backend`:

```env
DATABASE_ENGINE=django.db.backends.postgresql
DATABASE_NAME=promanage_db
DATABASE_USER=postgres
DATABASE_PASSWORD=your_password
DATABASE_HOST=localhost
DATABASE_PORT=5432
```

## Admin Panel

Akses admin panel di `http://localhost:8000/admin/` dengan akun superuser.

## Production Deployment

1. Set `DEBUG=False` di `.env.backend`
2. Generate SECRET_KEY baru: `python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'`
3. Update `ALLOWED_HOSTS` dengan domain production
4. Update `CORS_ALLOWED_ORIGINS` dengan URL frontend production
5. Gunakan PostgreSQL atau MySQL untuk database
6. Collect static files: `python manage.py collectstatic`
7. Deploy menggunakan Gunicorn + Nginx atau platform seperti Railway, Render, atau DigitalOcean

## Testing

```bash
# Run tests
python manage.py test

# Run dengan coverage
pip install coverage
coverage run --source='.' manage.py test
coverage report
```
