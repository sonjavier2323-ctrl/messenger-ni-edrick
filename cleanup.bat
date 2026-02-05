@echo off
echo Cleaning Messenger Project...
echo.

echo Step 1: Cleaning Flutter build files...
flutter clean

echo.
echo Step 2: Cleaning Android build files...
if exist android\.gradle rmdir /s /q android\.gradle
if exist android\build rmdir /s /q android\build

echo.
echo Step 3: Cleaning iOS build files...
if exist ios\build rmdir /s /q ios\build
if exist ios\.symlinks rmdir /s /q ios\.symlinks

echo.
echo Step 4: Cleaning Windows build files...
if exist windows\build rmdir /s /q windows\build

echo.
echo Step 5: Cleaning Web build files...
if exist web\build rmdir /s /q web\build

echo.
echo Step 6: Cleaning temporary files...
if exist .dart_tool rmdir /s /q .dart_tool
if exist .flutter-plugins rmdir /s /q .flutter-plugins
if exist .flutter-plugins-dependencies rmdir /s /q .flutter-plugins-dependencies

echo.
echo Step 7: Cleaning system temp files...
del /q /s %TEMP%\* 2>nul

echo.
echo Step 8: Cleaning Flutter cache...
flutter pub cache clean

echo.
echo Cleanup completed!
echo.
pause
