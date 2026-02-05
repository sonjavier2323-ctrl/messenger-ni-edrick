# Messenger Project Cleanup Script
Write-Host "Cleaning Messenger Project..." -ForegroundColor Green
Write-Host ""

# Step 1: Clean Flutter build files
Write-Host "Step 1: Cleaning Flutter build files..." -ForegroundColor Yellow
flutter clean

# Step 2: Clean Android build files
Write-Host "Step 2: Cleaning Android build files..." -ForegroundColor Yellow
if (Test-Path "android\.gradle") { Remove-Item -Recurse -Force "android\.gradle" }
if (Test-Path "android\build") { Remove-Item -Recurse -Force "android\build" }

# Step 3: Clean iOS build files
Write-Host "Step 3: Cleaning iOS build files..." -ForegroundColor Yellow
if (Test-Path "ios\build") { Remove-Item -Recurse -Force "ios\build" }
if (Test-Path "ios\.symlinks") { Remove-Item -Recurse -Force "ios\.symlinks" }

# Step 4: Clean Windows build files
Write-Host "Step 4: Cleaning Windows build files..." -ForegroundColor Yellow
if (Test-Path "windows\build") { Remove-Item -Recurse -Force "windows\build" }

# Step 5: Clean Web build files
Write-Host "Step 5: Cleaning Web build files..." -ForegroundColor Yellow
if (Test-Path "web\build") { Remove-Item -Recurse -Force "web\build" }

# Step 6: Clean temporary files
Write-Host "Step 6: Cleaning temporary files..." -ForegroundColor Yellow
if (Test-Path ".dart_tool") { Remove-Item -Recurse -Force ".dart_tool" }
if (Test-Path ".flutter-plugins") { Remove-Item -Recurse -Force ".flutter-plugins" }
if (Test-Path ".flutter-plugins-dependencies") { Remove-Item -Recurse -Force ".flutter-plugins-dependencies" }

# Step 7: Clean system temp files (safe)
Write-Host "Step 7: Cleaning system temp files..." -ForegroundColor Yellow
try {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    Write-Host "Some temp files could not be deleted (in use by system)" -ForegroundColor Yellow
}

# Step 8: Clean Flutter cache
Write-Host "Step 8: Cleaning Flutter cache..." -ForegroundColor Yellow
flutter pub cache clean

# Step 9: Clean npm cache
Write-Host "Step 9: Cleaning npm cache..." -ForegroundColor Yellow
npm cache clean --force

# Step 10: Show project size
Write-Host "Step 10: Calculating project size..." -ForegroundColor Yellow
$size = (Get-ChildItem -Path . -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "Project size after cleanup: $([math]::Round($size, 2)) MB" -ForegroundColor Green

Write-Host ""
Write-Host "Cleanup completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next time you can run: .\cleanup.ps1" -ForegroundColor Cyan
Read-Host "Press Enter to exit"
