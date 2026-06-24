@echo off

echo ======================================
echo    ProManage - Django Full Stack
echo ======================================
echo.

cd backend

REM Check if venv exists
if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Check if dependencies installed
if not exist "venv\installed.flag" (
    echo Installing dependencies...
    python -m pip install --upgrade pip
    pip install -r requirements.txt
    type nul > venv\installed.flag
)

REM Check if database exists
if not exist "db.sqlite3" (
    echo Setting up database...
    python manage.py makemigrations
    python manage.py migrate

    echo.
    set /p create_test="Create test data? (y/n): "
    if "%create_test%"=="y" (
        python manage.py shell < create_test_data.py
        echo.
        echo Test data created!
        echo   Email: test@promanage.com
        echo   Password: password123
    )
)

echo.
echo ======================================
echo    Starting Django Server...
echo ======================================
echo.
echo Application running at:
echo   http://localhost:8000
echo.
echo Press CTRL+C to stop server
echo.

python manage.py runserver
