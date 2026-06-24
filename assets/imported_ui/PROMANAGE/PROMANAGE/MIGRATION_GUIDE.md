# Panduan Migrasi dari localStorage ke Django API

Dokumen ini menjelaskan cara mengubah aplikasi dari menggunakan Context API + localStorage menjadi menggunakan Django REST API.

## 🎯 Overview

Saat ini aplikasi menggunakan:
- **Frontend**: Context API + localStorage untuk state management
- **Data**: Tersimpan di browser localStorage

Setelah migrasi:
- **Frontend**: Tetap menggunakan Context API untuk state management
- **Backend**: Django REST API dengan database SQLite/PostgreSQL
- **Data**: Tersimpan di database server

## 📝 Langkah Migrasi

### Step 1: Setup Backend (Sudah selesai!)

Backend Django sudah siap dengan:
- ✅ Models (User, Project, Work, Activity)
- ✅ REST API endpoints
- ✅ JWT Authentication
- ✅ File upload untuk foto
- ✅ CORS configuration

### Step 2: Update AuthContext

Ubah `src/app/context/AuthContext.tsx` untuk menggunakan API:

```tsx
import { authAPI } from '../services/api';

// Ubah fungsi login
const login = async (email: string, password: string) => {
  try {
    const data = await authAPI.login(email, password);
    setUser(data.user);
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
};

// Ubah fungsi register
const register = async (name: string, nim: string, email: string, password: string) => {
  try {
    const data = await authAPI.register(name, nim, email, password);
    setUser(data.user);
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
};

// Ubah fungsi logout
const logout = () => {
  authAPI.logout();
  setUser(null);
};

// Update useEffect untuk check session
useEffect(() => {
  const user = authAPI.getCurrentUser();
  if (user) {
    setUser(user);
  }
}, []);
```

### Step 3: Update ProjectContext

Ubah `src/app/context/ProjectContext.tsx` untuk menggunakan API:

```tsx
import api from '../services/api';

// Ubah addProject
const addProject = async (projectData: Omit<Project, 'id' | 'status' | 'isClosed'>) => {
  try {
    const newProject = await api.projects.create({
      name: projectData.name,
      description: projectData.description,
      location: projectData.location,
      start_date: projectData.startDate,
      end_date: projectData.endDate,
      executor: projectData.executor,
      supervisor: projectData.supervisor,
    });
    
    // Update local state
    setProjects([...projects, {
      id: newProject.id,
      name: newProject.name,
      description: newProject.description,
      location: newProject.location,
      startDate: newProject.start_date,
      endDate: newProject.end_date,
      executor: newProject.executor,
      supervisor: newProject.supervisor,
      status: newProject.status,
      isClosed: newProject.is_closed,
    }]);
    
    return newProject.id;
  } catch (error) {
    console.error('Error creating project:', error);
    throw error;
  }
};

// Ubah deleteProject
const deleteProject = async (projectId: string) => {
  try {
    await api.projects.delete(projectId);
    setProjects(projects.filter(p => p.id !== projectId));
    setWorks(works.filter(w => w.projectId !== projectId));
  } catch (error) {
    console.error('Error deleting project:', error);
    throw error;
  }
};

// Ubah renameProject
const renameProject = async (projectId: string, name: string) => {
  try {
    await api.projects.rename(projectId, name);
    setProjects(projects.map(p => 
      p.id === projectId ? { ...p, name } : p
    ));
  } catch (error) {
    console.error('Error renaming project:', error);
    throw error;
  }
};

// Load data dari API saat component mount
useEffect(() => {
  const loadProjects = async () => {
    try {
      const data = await api.projects.getAll();
      setProjects(data.map((p: any) => ({
        id: p.id,
        name: p.name,
        description: p.description,
        location: p.location,
        startDate: p.start_date,
        endDate: p.end_date,
        executor: p.executor,
        supervisor: p.supervisor,
        status: p.status,
        isClosed: p.is_closed,
      })));
    } catch (error) {
      console.error('Error loading projects:', error);
    }
  };

  if (authAPI.isAuthenticated()) {
    loadProjects();
  }
}, []);

// Hapus useEffect yang menyimpan ke localStorage
```

### Step 4: Update Work dan Activity Functions

Gunakan pola yang sama untuk:
- `addWork` → `api.works.create()`
- `deleteWork` → `api.works.delete()`
- `renameWork` → `api.works.rename()`
- `addActivity` → `api.activities.create()`
- `updateActivity` → `api.activities.update()`
- `deleteActivity` → `api.activities.delete()`

## 🔄 Perbedaan Format Data

### Backend API (snake_case)
```json
{
  "id": "123",
  "start_date": "2026-01-15",
  "end_date": "2026-06-30",
  "is_closed": false
}
```

### Frontend (camelCase)
```json
{
  "id": "123",
  "startDate": "2026-01-15",
  "endDate": "2026-06-30",
  "isClosed": false
}
```

**Solusi**: Transform data di Context saat fetch/send ke API.

## 🖼️ Upload Foto

### Sebelum (localStorage):
```tsx
// Simpan sebagai base64 di localStorage
photos: ["data:image/png;base64,iVBORw0KGgo..."]
```

### Sesudah (API):
```tsx
// Kirim base64 ke API, server convert ke file
await api.activities.create({
  work_id: workId,
  name: "Activity Name",
  photos: ["data:image/png;base64,iVBORw0KGgo..."]
});

// Server return URL foto
{
  "id": "123",
  "photo_urls": [
    "http://localhost:8000/media/activity_photos/2026/04/22/123_0.png"
  ]
}
```

## 🔐 Authentication Flow

### Login/Register
1. User submit form
2. Frontend call `authAPI.login()` atau `authAPI.register()`
3. Backend validate & return JWT token
4. Frontend simpan token di localStorage
5. Frontend simpan user data di state

### Subsequent Requests
1. Ambil token dari localStorage
2. Kirim di header: `Authorization: Bearer <token>`
3. Backend verify token
4. Return data user yang bersangkutan

## ✅ Testing Checklist

Setelah migrasi, test fitur-fitur berikut:

### Authentication
- [ ] Register user baru
- [ ] Login dengan user yang sudah ada
- [ ] Logout
- [ ] Protected routes (redirect jika belum login)
- [ ] Token persistence (refresh page tetap login)

### Projects
- [ ] List projects
- [ ] Create new project (wizard multi-step)
- [ ] Rename project (inline edit)
- [ ] Close project
- [ ] Delete project
- [ ] View project detail

### Works
- [ ] Add work ke project
- [ ] List works by project
- [ ] Rename work
- [ ] Delete work
- [ ] View work detail

### Activities
- [ ] Add activity ke work
- [ ] List activities by work
- [ ] Update activity (nama, executor, dll)
- [ ] Toggle done status
- [ ] Upload foto dokumentasi
- [ ] View foto yang sudah diupload
- [ ] Add evaluation
- [ ] Delete activity

### UI/UX
- [ ] Toast notifications muncul
- [ ] Responsive di mobile
- [ ] Modal/bottom sheet berfungsi
- [ ] Loading states
- [ ] Error handling

## 🐛 Common Issues

### CORS Error
**Problem**: `Access to fetch blocked by CORS policy`

**Solution**: Check `CORS_ALLOWED_ORIGINS` di `backend/backend/settings.py`:
```python
CORS_ALLOWED_ORIGINS = [
    'http://localhost:5173',  # Vite dev server
]
```

### Token Expired
**Problem**: `Token telah kadaluarsa`

**Solution**: User harus login ulang, atau implement refresh token mechanism.

### 401 Unauthorized
**Problem**: Request ditolak dengan error 401

**Solution**: 
1. Check token tersimpan di localStorage
2. Check header `Authorization` di request
3. Check token valid di backend

### Network Error
**Problem**: `Failed to fetch`

**Solution**:
1. Check backend running di port 8000
2. Check `VITE_API_URL` di `.env`
3. Check network tab di browser DevTools

## 📚 Resources

- Django REST Framework: https://www.django-rest-framework.org/
- JWT Authentication: https://jwt.io/
- Fetch API: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API

## 🚀 Next Steps

Setelah migrasi selesai:

1. **Testing**: Test semua fitur secara menyeluruh
2. **Optimization**: Add loading states, error boundaries
3. **Security**: Review security best practices
4. **Deploy**: Deploy backend & frontend ke production
5. **Monitoring**: Setup error tracking (Sentry, LogRocket)

## 💡 Tips

- Migrasi satu fitur pada satu waktu (mulai dari Auth)
- Keep localStorage version sebagai backup selama development
- Use React Query atau SWR untuk better data fetching
- Add proper loading & error states
- Test di berbagai browser & device
