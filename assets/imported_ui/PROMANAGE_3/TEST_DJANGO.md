# 🧪 Testing Django Application

Panduan testing aplikasi ProManage Django.

## ✅ Manual Testing Steps

### 1. Start Server
```bash
cd backend
python manage.py runserver
```

### 2. Test Home Page
1. Buka: http://localhost:8000/
2. ✅ Home page muncul dengan hero section
3. ✅ Header menampilkan "Login" & "Register"
4. ✅ Features section terlihat
5. ✅ Footer muncul

### 3. Test About Page
1. Klik "About" di header
2. ✅ About page muncul
3. ✅ Vision & Mission section terlihat
4. ✅ Scroll smooth

### 4. Test Authentication

#### Register
1. Klik "Register" di header
2. ✅ Modal muncul
3. Isi form:
   - Nama: Test User
   - NIM: 123456
   - Email: test@example.com
   - Password: password123
4. Klik "Register"
5. ✅ Toast "Pendaftaran berhasil!" muncul
6. ✅ Redirect ke /projects
7. ✅ Header menampilkan nama user

#### Login
1. Logout (klik avatar → Logout)
2. ✅ Redirect ke home
3. Klik "Login"
4. ✅ Modal muncul
5. Login dengan:
   - Email: test@example.com
   - Password: password123
6. ✅ Toast "Login berhasil!" muncul
7. ✅ Redirect ke /projects

### 5. Test Projects Page
1. Login terlebih dahulu
2. Navigate ke /projects
3. ✅ Page title "My Projects" muncul
4. ✅ Button "Buat Proyek" terlihat
5. ✅ Jika tidak ada project, empty state muncul

#### Create Project
1. Klik "Buat Proyek"
2. ✅ Modal form muncul
3. Isi form:
   - Nama Proyek: Test Project
   - Deskripsi: Test Description
   - Lokasi: Jakarta
   - Tanggal Mulai: 2026-04-22
   - Tanggal Selesai: 2026-12-31
   - Pelaksana: Tim A
   - Supervisor: Dr. Budi
4. Klik "Buat Proyek"
5. ✅ Toast "Proyek berhasil dibuat!" muncul
6. ✅ Modal close
7. ✅ Project card muncul di grid

### 6. Test Project Detail
1. Klik "Lihat Detail" pada project card
2. ✅ Redirect ke /projects/{id}/
3. ✅ Project detail muncul (nama, lokasi, tanggal, dll)
4. ✅ Section "Pekerjaan" terlihat
5. ✅ Button "Tambah Pekerjaan" ada
6. ✅ Empty state "Belum ada pekerjaan" muncul (jika belum ada work)

### 7. Test Responsive Design

#### Mobile View (< 768px)
1. Resize browser ke mobile size
2. ✅ Header berubah jadi hamburger menu
3. ✅ Hero section stack vertical
4. ✅ Features grid jadi 1 kolom
5. ✅ Modal jadi bottom sheet
6. ✅ Buttons full width

#### Tablet View (768px - 1024px)
1. Resize browser ke tablet size
2. ✅ Features grid jadi 2 kolom
3. ✅ Navigation tetap visible
4. ✅ Layout responsive

#### Desktop View (> 1024px)
1. Resize browser ke desktop size
2. ✅ Full navigation bar
3. ✅ Features grid 3 kolom
4. ✅ Optimal spacing

### 8. Test API Endpoints

#### Health Check
```bash
curl http://localhost:8000/api/health/
```
Expected: `{"status": "OK", ...}`

#### Register API
```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"name":"API Test","nim":"999","email":"apitest@test.com","password":"test123"}'
```
Expected: `{"success": true, "token": "...", "user": {...}}`

#### Login API
```bash
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"apitest@test.com","password":"test123"}'
```
Expected: `{"success": true, "token": "...", "user": {...}}`

#### List Projects (dengan token)
```bash
TOKEN="your_token_here"
curl http://localhost:8000/api/projects/ \
  -H "Authorization: Bearer $TOKEN"
```
Expected: Array of projects

### 9. Test Browser Compatibility
- ✅ Chrome/Edge (latest)
- ✅ Firefox (latest)
- ✅ Safari (latest)
- ✅ Mobile browsers

### 10. Test JavaScript Console
1. Buka browser DevTools (F12)
2. Check Console tab
3. ✅ Tidak ada errors
4. ✅ Hanya logs yang expected (jika ada)

## 🐛 Common Issues & Solutions

### Issue: CSRF token missing
**Solution:** API endpoints sudah exempt dari CSRF. Pastikan requests ke `/api/*` pakai `Content-Type: application/json`

### Issue: Login success but not redirecting
**Solution:** Check browser console. Pastikan `localStorage` working dan token tersimpan.

### Issue: 404 Not Found on templates
**Solution:** Check `settings.py` → `TEMPLATES['DIRS']` harus include `api/templates`

### Issue: Icons not showing
**Solution:** Check internet connection. Icons loaded dari CDN (Lucide).

### Issue: Tailwind classes not working
**Solution:** Tailwind loaded dari CDN. Check internet connection.

## ✅ Test Checklist

### Frontend (Templates)
- [ ] Home page renders
- [ ] About page renders
- [ ] Projects page renders (after login)
- [ ] Project detail renders
- [ ] Work detail renders
- [ ] Header shows correctly
- [ ] Login modal works
- [ ] Register modal works
- [ ] Toast notifications appear
- [ ] Responsive on mobile
- [ ] Responsive on tablet
- [ ] Responsive on desktop

### Backend (API)
- [ ] Health check works
- [ ] Register endpoint works
- [ ] Login endpoint works
- [ ] JWT token generated
- [ ] List projects works (with auth)
- [ ] Create project works
- [ ] Project detail works
- [ ] List works works
- [ ] List activities works

### Integration
- [ ] Login from UI → token saved
- [ ] Fetch projects with token
- [ ] Create project from UI
- [ ] Logout clears token
- [ ] Protected routes redirect if not authenticated
- [ ] Header updates after login
- [ ] Header updates after logout

### Performance
- [ ] Pages load < 2 seconds
- [ ] No console errors
- [ ] Icons load properly
- [ ] Images load (Unsplash)
- [ ] API calls < 1 second

---

**All tests passing? 🎉 Aplikasi siap digunakan!**
