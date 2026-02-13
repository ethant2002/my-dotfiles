# WSL Multi-Distro Installer (Microsoft Store Method)
# This uses winget to install distributions from Microsoft Store for better reliability

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL Multi-Distribution Installer" -ForegroundColor Cyan
Write-Host "Using Microsoft Store (More Reliable)" -ForegroundColor Yellow
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

# Check if winget is available
Write-Host "Checking for Windows Package Manager (winget)..." -ForegroundColor Cyan
try {
    $wingetVersion = winget --version
    Write-Host "✓ winget found: $wingetVersion" -ForegroundColor Green
}
catch {
    Write-Host "✗ winget not found!" -ForegroundColor Red
    Write-Host "Please install App Installer from Microsoft Store:" -ForegroundColor Yellow
    Write-Host "  https://apps.microsoft.com/detail/9nblggh4nns1" -ForegroundColor White
    pause
    exit 1
}
Write-Host ""

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
        Write-Host "  1. Run this script again" -ForegroundColor White
        Write-Host ""
        pause
        exit 0
    }
}
catch {
    Write-Host "WSL is not available. Installing WSL..." -ForegroundColor Yellow
    wsl --install --no-distribution
    Write-Host ""
    Write-Host "Please restart your computer and run this script again." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 0
}

Write-Host "✓ WSL is ready!" -ForegroundColor Green
Write-Host ""

# Install distributions using winget
Write-Host "Installing distributions from Microsoft Store..." -ForegroundColor Yellow
Write-Host "This method is more reliable than wsl --install" -ForegroundColor Cyan
Write-Host ""

# Install Ubuntu 22.04
Write-Host "[1/3] Installing Ubuntu 22.04 LTS..." -ForegroundColor Yellow
try {
    winget install Canonical.Ubuntu.2204 --source msstore --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Ubuntu 22.04 installed!" -ForegroundColor Green
    } else {
        Write-Host "⚠ Ubuntu 22.04 installation returned code: $LASTEXITCODE" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "✗ Error installing Ubuntu 22.04: $_" -ForegroundColor Red
}
Write-Host ""

# Install Kali Linux
Write-Host "[2/3] Installing Kali Linux..." -ForegroundColor Yellow
try {
    winget install KaliLinux.KaliLinux --source msstore --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Kali Linux installed!" -ForegroundColor Green
    } else {
        Write-Host "⚠ Kali Linux installation returned code: $LASTEXITCODE" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "✗ Error installing Kali Linux: $_" -ForegroundColor Red
}
Write-Host ""

# Install Arch Linux
Write-Host "[3/3] Installing Arch Linux..." -ForegroundColor Yellow
try {
    # Try the official Arch Linux WSL package
    winget install 9MZNMNKSM73X --source msstore --accept-package-agreements --accept-source-agreements --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Arch Linux installed!" -ForegroundColor Green
    } else {
        Write-Host "⚠ Arch Linux installation returned code: $LASTEXITCODE" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "✗ Error installing Arch Linux: $_" -ForegroundColor Red
}
Write-Host ""

# Shutdown WSL to ensure clean state
Write-Host "Shutting down WSL to ensure clean state..." -ForegroundColor Cyan
wsl --shutdown
Start-Sleep -Seconds 3
Write-Host ""

# Verify installations
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verifying Installations..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$allInstalled = $true

# Check Ubuntu
$ubuntuCheck = wsl --list | Select-String "Ubuntu-22.04"
if ($ubuntuCheck) {
    Write-Host "✓ Ubuntu 22.04: INSTALLED" -ForegroundColor Green
} else {
    $ubuntuCheck = wsl --list | Select-String "Ubuntu"
    if ($ubuntuCheck) {
        Write-Host "✓ Ubuntu: INSTALLED (may have different version)" -ForegroundColor Green
    } else {
        Write-Host "✗ Ubuntu: NOT FOUND" -ForegroundColor Red
        $allInstalled = $false
    }
}

# Check Kali
$kaliCheck = wsl --list | Select-String "kali"
if ($kaliCheck) {
    Write-Host "✓ Kali Linux: INSTALLED" -ForegroundColor Green
} else {
    Write-Host "✗ Kali Linux: NOT FOUND" -ForegroundColor Red
    $allInstalled = $false
}

# Check Arch
$archCheck = wsl --list | Select-String "Arch"
if ($archCheck) {
    Write-Host "✓ Arch Linux: INSTALLED" -ForegroundColor Green
} else {
    Write-Host "✗ Arch Linux: NOT FOUND" -ForegroundColor Red
    $allInstalled = $false
}

Write-Host ""
Write-Host "All installed WSL distributions:" -ForegroundColor Yellow
wsl --list --verbose
Write-Host ""

if (-not $allInstalled) {
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "Some Distributions Missing" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Yellow
    Write-Host "Try these manual installation links:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ubuntu 22.04:" -ForegroundColor Cyan
    Write-Host "  ms-windows-store://pdp/?ProductId=9PN20MSR04DW" -ForegroundColor White
    Write-Host ""
    Write-Host "Kali Linux:" -ForegroundColor Cyan
    Write-Host "  ms-windows-store://pdp/?ProductId=9PKR34TNCV07" -ForegroundColor White
    Write-Host ""
    Write-Host "Arch Linux:" -ForegroundColor Cyan
    Write-Host "  ms-windows-store://pdp/?ProductId=9MZNMNKSM73X" -ForegroundColor White
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "1. REBOOT your computer (recommended)" -ForegroundColor White
Write-Host "2. Run: configure-wsl-distros.ps1" -ForegroundColor White
Write-Host ""
Write-Host "The configuration script will set up users for each distro." -ForegroundColor Cyan
Write-Host ""

pause
