@echo off
echo ========================================
echo   Gestion des Reclamations - Startup
echo ========================================
echo.

:: Start Backend Server
echo [1/2] Starting Django Backend Server...
cd /d "%~dp0server"
start "Django Backend" cmd /k "python manage.py runserver 0.0.0.0:8000"
timeout /t 3 /nobreak >nul

:: Start Frontend App
echo [2/2] Starting Flutter Frontend...
cd /d "%~dp0client\reclamations_app"
start "Flutter App" cmd /k "flutter run"

echo.
echo ========================================
echo   Both servers are starting!
echo ========================================
echo.
echo Backend API: http://localhost:8000
echo Flutter App will connect to: http://10.0.2.2:8000 (Android Emulator)
echo.
pause
