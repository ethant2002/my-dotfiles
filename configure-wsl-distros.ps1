# WSL Distribution Configuration Script
# Run this AFTER rebooting and installing the distributions
# This will configure each distro with a regular user account

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL Distribution Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will configure each distribution separately." -ForegroundColor Yellow
Write-Host "You'll create a username and password for each one." -ForegroundColor Yellow
Write-Host ""

# Check installed distributions
Write-Host "Checking installed distributions..." -ForegroundColor Cyan
$distros = wsl --list --quiet
Write-Host ""

# Configuration functions for each distro
function Configure-Ubuntu {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Configuring Ubuntu 22.04" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ubuntu will now open in a new window." -ForegroundColor Yellow
    Write-Host "Please create your username and password when prompted." -ForegroundColor Yellow
    Write-Host ""
    pause
    
    # Launch Ubuntu for first-time setup
    wsl -d Ubuntu-22.04
    
    Write-Host ""
    Write-Host "✓ Ubuntu 22.04 configuration complete!" -ForegroundColor Green
    Write-Host ""
}

function Configure-Kali {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Configuring Kali Linux" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Kali Linux will now open in a new window." -ForegroundColor Yellow
    Write-Host "Please create your username and password when prompted." -ForegroundColor Yellow
    Write-Host ""
    pause
    
    # Launch Kali for first-time setup
    wsl -d kali-linux
    
    Write-Host ""
    Write-Host "✓ Kali Linux configuration complete!" -ForegroundColor Green
    Write-Host ""
}

function Configure-Arch {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Configuring Arch Linux" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "For Arch Linux, we'll create a regular user (no root login)." -ForegroundColor Yellow
    Write-Host ""
    
    # Get username
    $archUser = Read-Host "Enter your desired username for Arch Linux"
    
    Write-Host ""
    Write-Host "Arch Linux will now open to complete setup..." -ForegroundColor Yellow
    Write-Host "Commands will be run automatically to create your user." -ForegroundColor Yellow
    Write-Host ""
    pause
    
    # Create user in Arch
    wsl -d Arch -u root bash -c "useradd -m -G wheel -s /bin/bash $archUser && passwd $archUser"
    
    # Configure sudo for wheel group
    wsl -d Arch -u root bash -c "echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers"
    
    # Set default user
    wsl -d Arch -u root bash -c "echo -e '[user]\ndefault=$archUser' >> /etc/wsl.conf"
    
    Write-Host ""
    Write-Host "✓ Arch Linux user created!" -ForegroundColor Green
    Write-Host "  Username: $archUser" -ForegroundColor White
    Write-Host "  Sudo access: Enabled (wheel group)" -ForegroundColor White
    Write-Host ""
    Write-Host "NOTE: Restart Arch for the default user to take effect:" -ForegroundColor Yellow
    Write-Host "  wsl --terminate Arch" -ForegroundColor White
    Write-Host ""
}

# Check which distros are installed and configure them
$ubuntuInstalled = $distros -match "Ubuntu-22.04"
$kaliInstalled = $distros -match "kali-linux"
$archInstalled = $distros -match "Arch"

if (-not $ubuntuInstalled -and -not $kaliInstalled -and -not $archInstalled) {
    Write-Host "ERROR: No WSL distributions found!" -ForegroundColor Red
    Write-Host "Please run the install-wsl-distros.ps1 script first." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

# Configure Ubuntu
if ($ubuntuInstalled) {
    Configure-Ubuntu
} else {
    Write-Host "Ubuntu 22.04 not found - skipping" -ForegroundColor Yellow
    Write-Host ""
}

# Configure Kali
if ($kaliInstalled) {
    Configure-Kali
} else {
    Write-Host "Kali Linux not found - skipping" -ForegroundColor Yellow
    Write-Host ""
}

# Configure Arch
if ($archInstalled) {
    Configure-Arch
} else {
    Write-Host "Arch Linux not found - skipping" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "All Configurations Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Your WSL distributions are ready to use:" -ForegroundColor Green
Write-Host ""
Write-Host "Launch commands:" -ForegroundColor Yellow
if ($ubuntuInstalled) {
    Write-Host "  wsl -d Ubuntu-22.04" -ForegroundColor White
}
if ($kaliInstalled) {
    Write-Host "  wsl -d kali-linux" -ForegroundColor White
}
if ($archInstalled) {
    Write-Host "  wsl -d Arch" -ForegroundColor White
}
Write-Host ""
Write-Host "Or simply type: wsl" -ForegroundColor White
Write-Host ""
Write-Host "To terminate a distribution:" -ForegroundColor Yellow
Write-Host "  wsl --terminate <distro-name>" -ForegroundColor White
Write-Host ""
Write-Host "To set a default distribution:" -ForegroundColor Yellow
Write-Host "  wsl --set-default <distro-name>" -ForegroundColor White
Write-Host ""

pause
