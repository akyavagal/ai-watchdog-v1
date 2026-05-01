# AI Watchdog v1.0 - EXE Compiler Script
# Requires: PS2EXE module

Write-Host "--- AI Watchdog v1.0 Build System ---" -ForegroundColor Cyan

$root = Split-Path -Parent $PSScriptRoot
$appDir = Join-Path $root "app"
$buildDir = Join-Path $root "build"
$outputExe = Join-Path $buildDir "AIWatchdog_v1.0.exe"

if (-not (Get-Module -ListAvailable -Name ps2exe)) {
    Write-Host "[!] PS2EXE module not found. Installing..." -ForegroundColor Yellow
    Install-Module ps2exe -Scope CurrentUser -Force
}

Write-Host "[*] Compiling Main.ps1 to EXE..." -ForegroundColor Green

# Note: In a real production build, we would bundle dependencies.
# For MVP, ps2exe will wrap the main script.
Invoke-PS2EXE -InputFile (Join-Path $appDir "Main.ps1") `
              -OutputFile $outputExe `
              -Title "AI Watchdog v1.0" `
              -Description "AI-Powered Threat Detection for Windows" `
              -Company "AI Watchdog Security" `
              -Product "AI Watchdog" `
              -Copyright "2026 AI Watchdog" `
              -NoConsole `
              -Sta

Write-Host "[+] Build Complete: $outputExe" -ForegroundColor Cyan
Write-Host "[*] Ensure 'Modules/' and 'UI/' folders are distributed with the EXE for now." -ForegroundColor Gray
