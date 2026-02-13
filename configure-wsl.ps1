# WSL Configuration Script
# Run AFTER installing and rebooting
# Sets up user accounts for each distribution

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL Configuration" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get all installed distros
Write-Host "Installed distributions:" -ForegroundColor Yellow
wsl --list --verbose
Write-Host ""

# Find distro names
$distros = wsl --list --quiet
$ubuntu = $distros | Where-Object { $_ -match "Ubuntu" } | Select-Object -First 1
$kali = $distros | Where-Object { $_ -match "kali" } | Select-Object -First 1
$arch = $distros | Where-Object { $_ -match "Arch" } | Select-Object -First 1

if (-not $ubuntu -and -not $kali -and -not $arch) {
    Write-Host "ERROR: No distributions found!" -ForegroundColor Red
    Write-Host "Run install-wsl.ps1 first and reboot." -ForegroundColor Yellow
    pause
    exit 1
}

# Configure Ubuntu
if ($ubuntu) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Configure Ubuntu" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ubuntu will open - create your username and password" -ForegroundColor Yellow
    Write-Host ""
    pause
    
    Start-Process wsl -ArgumentList "-d $ubuntu" -Wait
    
    Write-Host ""
    Write-Host "Ubuntu configured!" -ForegroundColor Green
    Write-Host ""
}

# Configure Kali
if ($kali) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Configure Kali Linux" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Kali will open - create your username and password" -ForegroundColor Yellow
    Write-Host ""
    pause
    
    Start-Process wsl -ArgumentList "-d $kali" -Wait
    
    Write-Host ""
    Write-Host "Kali configured!" -ForegroundColor Green
    Write-Host ""
}

# Configure Arch
if ($arch) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Configure Arch Linux" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    $username = Read-Host "Enter username for Arch Linux"
    
    Write-Host ""
    Write-Host "Creating user account..." -ForegroundColor Yellow
    
    # Create user
    wsl -d $arch -u root useradd -m -G wheel -s /bin/bash $username
    
    Write-Host "Set password for $username" -ForegroundColor Yellow
    wsl -d $arch -u root passwd $username
    
    # Enable sudo for wheel group
    wsl -d $arch -u root sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    
    # Set default user
    wsl -d $arch -u root bash -c "echo -e '[user]\ndefault=$username' > /etc/wsl.conf"
    
    # Restart Arch
    wsl --terminate $arch
    Start-Sleep -Seconds 2
    
    Write-Host ""
    Write-Host "Arch configured!" -ForegroundColor Green
    Write-Host "  User: $username (with sudo access)" -ForegroundColor White
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Launch your distributions:" -ForegroundColor Yellow
if ($ubuntu) { Write-Host "  wsl -d $ubuntu" -ForegroundColor White }
if ($kali) { Write-Host "  wsl -d $kali" -ForegroundColor White }
if ($arch) { Write-Host "  wsl -d $arch" -ForegroundColor White }
Write-Host ""
Write-Host "Or just type: wsl" -ForegroundColor White
Write-Host ""

pause
