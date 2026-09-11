# Script PowerShell de Automacao de Compilacao do APK Release - Boxing AI
# Executa limpeza, download de dependencias e geracao do APK otimizado para ARM64.

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "   COMPILADOR RELEASE MOBILE - BOXING AI (30+ FPS)   " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

$projectDir = Get-Location

Write-Host "[1/4] Limpando cache do Flutter..." -ForegroundColor Yellow
flutter clean

Write-Host "[2/4] Restaurando pacotes pubspec..." -ForegroundColor Yellow
flutter pub get

Write-Host "[3/4] Compilando APK Release Otimizado com Aceleracao de Hardware..." -ForegroundColor Yellow
flutter build apk --release --target-platform android-arm64 --split-per-abi

$apkPath = "$projectDir\build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"

if (Test-Path $apkPath) {
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host "   SUCESSO! APK GERADO COM EXITO!                  " -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host "Caminho do APK: $apkPath" -ForegroundColor White
    Write-Host ""
    Write-Host "Para instalar diretamente via USB no celular conectado:" -ForegroundColor Yellow
    Write-Host "  adb install -r '$apkPath'" -ForegroundColor White
} else {
    Write-Host "[!] APK gerado no caminho padrão: $projectDir\build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Green
}
