@echo off
echo Building Ethio Tutor APK...
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev
    pause
    exit /b 1
)

echo Getting dependencies...
flutter pub get

echo.
echo Building APK in release mode...
flutter build apk --release

echo.
echo Build complete!
echo APK location: build\app\outputs\flutter-apk\app-release.apk

pause