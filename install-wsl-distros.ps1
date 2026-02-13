# WSL Multi-Distro Installer Script
# Run this script in PowerShell as Administrator

Write-Host "WSL Multi-Distribution Installer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Enable WSL if not already enabled
Write-Host "Checking WSL status..." -ForegroundColor Yellow
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

if ($wslFeature.State -ne "Enabled") {
    Write-Host "Enabling WSL feature..." -ForegroundColor Yellow
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    Write-Host "WSL features enabled. A restart may be required." -ForegroundColor Green
}

# Set WSL 2 as default
Write-Host "Setting WSL 2 as default version..." -ForegroundColor Yellow
wsl --set-default-version 2

# Define distributions to install
$distros = @(
    @{Name = "Ubuntu-22.04"; DisplayName = "Ubuntu 22.04 LTS"},
    @{Name = "kali-linux"; DisplayName = "Kali Linux"},
    @{Name = "Arch"; DisplayName = "Arch Linux"}
)

# Install each distribution
foreach ($distro in $distros) {
    Write-Host ""
    Write-Host "Installing $($distro.DisplayName)..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Gray
    
    try {
        wsl --install -d $distro.Name
        Write-Host "$($distro.DisplayName) installation initiated successfully!" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install $($distro.DisplayName): $_" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Installation Process Complete!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Each distribution will open a window for initial setup" -ForegroundColor White
Write-Host "2. Create a username and password for each distro" -ForegroundColor White
Write-Host "3. Wait for all installations to complete" -ForegroundColor White
Write-Host ""
Write-Host "To list installed distributions, run: wsl --list --verbose" -ForegroundColor Cyan
Write-Host "To set a default distribution, run: wsl --set-default <DistroName>" -ForegroundColor Cyan
Write-Host ""

pause
