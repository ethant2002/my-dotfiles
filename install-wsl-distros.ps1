# WSL Multi-Distro Installer Script
# This script installs Ubuntu 22.04, Kali Linux, and Arch Linux on WSL
# Installations are done without immediate user setup, allowing configuration after reboot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL Multi-Distribution Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Check if WSL is enabled
Write-Host "Checking WSL status..." -ForegroundColor Cyan
try {
    $wslVersion = wsl --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "WSL is not installed. Installing WSL first..." -ForegroundColor Yellow
        wsl --install --no-distribution
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "IMPORTANT: System Restart Required!" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "WSL has been installed but requires a restart." -ForegroundColor Yellow
        Write-Host "After restarting:" -ForegroundColor Yellow
        Write-Host "  1. Run this script again to install distributions" -ForegroundColor White
        Write-Host "  2. Then run the configuration script" -ForegroundColor White
        Write-Host ""
        pause
        exit 0
    }
}
catch {
    Write-Host "WSL is not available. Installing WSL..." -ForegroundColor Yellow
    wsl --install --no-distribution
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "IMPORTANT: System Restart Required!" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Please restart your computer." -ForegroundColor Yellow
    Write-Host "After restarting, run this script again." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 0
}

Write-Host "WSL is ready!" -ForegroundColor Green
Write-Host ""

# Download and install distributions using Windows Package Manager
Write-Host "Installing distributions (this may take several minutes)..." -ForegroundColor Yellow
Write-Host "The distributions will NOT prompt for setup during installation." -ForegroundColor Cyan
Write-Host ""

# Install Ubuntu 22.04
Write-Host "[1/3] Installing Ubuntu 22.04 LTS..." -ForegroundColor Yellow
try {
    wsl --install Ubuntu-22.04 --no-launch
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Ubuntu 22.04 downloaded successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ Ubuntu 22.04 installation had issues (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        Write-Host "  Attempting alternative installation method..." -ForegroundColor Yellow
        wsl --install -d Ubuntu-22.04
    }
}
catch {
    Write-Host "✗ Error with Ubuntu 22.04: $_" -ForegroundColor Red
}
Write-Host ""

# Install Kali Linux
Write-Host "[2/3] Installing Kali Linux..." -ForegroundColor Yellow
try {
    wsl --install kali-linux --no-launch
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Kali Linux downloaded successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ Kali Linux installation had issues (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        Write-Host "  Attempting alternative installation method..." -ForegroundColor Yellow
        wsl --install -d kali-linux
    }
}
catch {
    Write-Host "✗ Error with Kali Linux: $_" -ForegroundColor Red
}
Write-Host ""

# Install Arch Linux
Write-Host "[3/3] Installing Arch Linux..." -ForegroundColor Yellow
try {
    wsl --install Arch --no-launch
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Arch Linux downloaded successfully!" -ForegroundColor Green
    } else {
        Write-Host "✗ Arch Linux installation had issues (Exit code: $LASTEXITCODE)" -ForegroundColor Red
        Write-Host "  Attempting alternative installation method..." -ForegroundColor Yellow
        wsl --install -d Arch
    }
}
catch {
    Write-Host "✗ Error with Arch Linux: $_" -ForegroundColor Red
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installation Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed distributions:" -ForegroundColor Yellow
wsl --list --verbose
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. REBOOT your computer (recommended)" -ForegroundColor White
Write-Host "2. Run the configuration script: configure-wsl-distros.ps1" -ForegroundColor White
Write-Host ""
Write-Host "The configuration script will guide you through:" -ForegroundColor Cyan
Write-Host "  • Creating a regular user for Ubuntu 22.04" -ForegroundColor White
Write-Host "  • Creating a regular user for Kali Linux" -ForegroundColor White
Write-Host "  • Creating a regular user for Arch Linux (no root login)" -ForegroundColor White
Write-Host ""
Write-Host "Each distro will be configured separately, one at a time." -ForegroundColor Cyan
Write-Host ""

pause
