# Run this script from inside the project directory to verify the build
Set-Location "c:\Users\Mannvi SD\OneDrive\Desktop\edhithaapp\edhitha_team2027_swarm_interface"

Write-Host "=== Step 1: flutter pub get ===" -ForegroundColor Cyan
flutter pub get
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: pub get" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "=== Step 2: flutter analyze ===" -ForegroundColor Cyan
flutter analyze
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: analyze" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "=== Step 3: flutter test ===" -ForegroundColor Cyan
flutter test test/intent_parser_test.dart --reporter=expanded
if ($LASTEXITCODE -ne 0) { Write-Host "FAILED: tests" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "=== ALL CHECKS PASSED ===" -ForegroundColor Green
