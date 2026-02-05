@echo off
echo Building Messenger NI Edrick APK...
echo.

echo Step 1: Clean previous builds
flutter clean

echo.
echo Step 2: Get dependencies
flutter pub get

echo.
echo Step 3: Build APK
flutter build apk --release

echo.
echo Step 4: Find APK file
echo APK should be in: build\app\outputs\flutter-apk\app-release.apk
echo.

echo Build completed! Check the build/app/outputs/flutter-apk/ folder for your APK file.
pause
