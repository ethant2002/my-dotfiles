# WSL Multi-Distro Installer
# Installs Ubuntu 22.04, Kali Linux, and Arch Linux using winget
# Run as Administrator

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL Distribution Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Run as Administrator!" -ForegroundColor Red
    pause
    exit 1
}

# Step 1: Enable WSL and Virtual Machine Platform
Write-Host "[1/5] Enabling WSL features..." -ForegroundColor Yellow
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
Write-Host ""

# Step 2: Install WSL2 kernel update
Write-Host "[2/5] Installing WSL2 kernel..." -ForegroundColor Yellow
wsl --update
wsl --set-default-version 2
Write-Host ""

# Step 3: Install Ubuntu 22.04
Write-Host "[3/5] Installing Ubuntu 22.04..." -ForegroundColor Yellow
winget install -e --id Canonical.Ubuntu.2204 --accept-package-agreements --accept-source-agreements
Write-Host ""

# Step 4: Install Kali Linux
Write-Host "[4/5] Installing Kali Linux..." -ForegroundColor Yellow
winget install -e --id KaliLinux.KaliLinux --accept-package-agreements --accept-source-agreements
Write-Host ""

# Step 5: Install Arch Linux
Write-Host "[5/5] Installing Arch Linux..." -ForegroundColor Yellow
winget install -e --id 9MZNMNKSM73X --accept-package-agreements --accept-source-agreements
Write-Host ""

# Verify installations
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Installed Distributions:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
wsl --list --verbose
Write-Host ""

Write-Host "========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT: REBOOT NOW" -ForegroundColor Yellow
Write-Host ""
Write-Host "After reboot, run: configure-wsl.ps1" -ForegroundColor White
Write-Host "to set up your user accounts" -ForegroundColor White
Write-Host ""

pause
