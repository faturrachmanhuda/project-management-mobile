#!/bin/bash

echo "========================================"
echo "   ProManage - Aplikasi Manajemen Proyek"
echo "========================================"
echo ""

# Check if backend setup needed
if [ ! -d "backend/venv" ]; then
    echo "[1/4] Backend belum di-setup. Menjalankan setup..."
    cd backend
    chmod +x setup.sh
    ./setup.sh
    cd ..
else
    echo "[1/4] Backend sudah di-setup."
fi

# Check if frontend dependencies installed
if [ ! -d "node_modules" ]; then
    echo "[2/4] Installing frontend dependencies..."
    pnpm install
else
    echo "[2/4] Frontend dependencies sudah terinstall."
fi

echo ""
echo "[3/4] Memulai Backend Django..."
echo ""

# Start backend in background
cd backend
source venv/bin/activate
python manage.py runserver &
BACKEND_PID=$!
cd ..

sleep 3

echo "[4/4] Memulai Frontend React..."
echo ""

# Start frontend in background
pnpm dev &
FRONTEND_PID=$!

echo ""
echo "========================================"
echo "   Aplikasi sedang running!"
echo "========================================"
echo ""
echo "Backend:  http://localhost:8000"
echo "Frontend: http://localhost:5173"
echo ""
echo "Tekan CTRL+C untuk stop semua server."
echo ""

# Wait for Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT

# Open browser (optional)
sleep 5
if command -v xdg-open > /dev/null; then
    xdg-open http://localhost:5173
elif command -v open > /dev/null; then
    open http://localhost:5173
fi

# Keep script running
wait
