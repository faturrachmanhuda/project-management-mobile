#!/bin/bash

echo "======================================"
echo "   ProManage - Django Full Stack"
echo "======================================"
echo ""

cd backend

# Check if venv exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

# Check if dependencies installed
if [ ! -f "venv/installed.flag" ]; then
    echo "Installing dependencies..."
    pip install --upgrade pip
    pip install -r requirements.txt
    touch venv/installed.flag
fi

# Check if database exists
if [ ! -f "db.sqlite3" ]; then
    echo "Setting up database..."
    python manage.py makemigrations
    python manage.py migrate

    echo ""
    echo "Create test data? (y/n)"
    read -p "> " create_test
    if [ "$create_test" = "y" ]; then
        python manage.py shell < create_test_data.py
        echo ""
        echo "✓ Test data created!"
        echo "  Email: test@promanage.com"
        echo "  Password: password123"
    fi
fi

echo ""
echo "======================================"
echo "   Starting Django Server..."
echo "======================================"
echo ""
echo "Application running at:"
echo "  🌐 http://localhost:8000"
echo ""
echo "Press CTRL+C to stop server"
echo ""

python manage.py runserver
