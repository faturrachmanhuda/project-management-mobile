@echo off
title ProManage - Startup Script (Windows)

echo ========================================
echo    ProManage - Aplikasi Manajemen Proyek
echo ========================================
echo.

REM Check if backend setup needed
if not exist "backend\venv" (
    echo [1/4] Backend belum di-setup. Menjalankan setup...
    cd backend
    call setup.bat
    cd ..
) else (
    echo [1/4] Backend sudah di-setup.
)

REM Check if frontend dependencies installed
if not exist "node_modules" (
    echo [2/4] Installing frontend dependencies...
    call pnpm install
) else (
    echo [2/4] Frontend dependencies sudah terinstall.
)

echo.
echo [3/4] Memulai Backend Django...
echo.
start "ProManage Backend" cmd /k "cd backend && venv\Scripts\activate && python manage.py runserver"

timeout /t 3 /nobreak >nul

echo [4/4] Memulai Frontend React...
echo.
start "ProManage Frontend" cmd /k "pnpm dev"

echo.
echo ========================================
echo    Aplikasi sedang starting up...
echo ========================================
echo.
echo Backend akan tersedia di:  http://localhost:8000
echo Frontend akan tersedia di: http://localhost:5173
echo.
echo Tunggu beberapa detik, browser akan terbuka otomatis.
echo.
echo Tekan CTRL+C di masing-masing terminal untuk stop server.
echo.

timeout /t 5 /nobreak >nul
start http://localhost:5173

echo Startup selesai!
echo.
pause
