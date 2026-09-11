# Script PowerShell de Automacao de Compilacao do Pacote iOS (.ipa) - Boxing AI
# Prepara e instrui a compilacao do pacote para AltStore PAL / Sideloadly.

Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "   COMPILADOR DE PACOTE iOS (.IPA) - BOXING AI     " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

$projectDir = Get-Location

Write-Host "[1/3] Verificando arquivo ExportOptions.plist..." -ForegroundColor Yellow
if (Test-Path "$projectDir\ios\ExportOptions.plist") {
    Write-Host "  -> ExportOptions.plist encontrado em ios\ExportOptions.plist" -ForegroundColor Green
} else {
    Write-Host "[!] ExportOptions.plist nao encontrado." -ForegroundColor Red
}

Write-Host "[2/3] Comando exato da Flutter CLI para compilar o .ipa:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  flutter build ipa --release --export-options-plist=ios/ExportOptions.plist" -ForegroundColor White
Write-Host ""
Write-Host "Nota: Se estiver compilando em um ambiente sem certificado pago da Apple, use:" -ForegroundColor Yellow
Write-Host "  flutter build ipa --release --no-codesign" -ForegroundColor White
Write-Host ""

Write-Host "[3/3] Instrucoes de empacotamento manual do container Payload (.ipa):" -ForegroundColor Yellow
Write-Host "  1. Navegue ate a pasta: build\ios\archive\Runner.xcarchive\Products\Applications\" -ForegroundColor White
Write-Host "  2. Crie uma pasta chamada 'Payload'" -ForegroundColor White
Write-Host "  3. Copie 'Runner.app' para dentro da pasta 'Payload'" -ForegroundColor White
Write-Host "  4. Compacte a pasta 'Payload' em ZIP e renomeie a extensao para 'BoxingAI.ipa'" -ForegroundColor White
Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host "   PACOTE PRONTO PARA SIDELOADING VIA ALTSTORE PAL! " -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
