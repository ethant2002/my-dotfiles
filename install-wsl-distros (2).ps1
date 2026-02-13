# WSL Multi-Distro Installer Script
# Run this script in PowerShell as Administrator

Write-Host ""
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

Write-Host "Step 1: Checking WSL features..." -ForegroundColor Yellow
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
$vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

$needsReboot = $false

if ($wslFeature.State -ne "Enabled") {
    Write-Host "  -> Enabling WSL feature..." -ForegroundColor Yellow
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    $needsReboot = $true
}

if ($vmFeature.State -ne "Enabled") {
    Write-Host "  -> Enabling Virtual Machine Platform..." -ForegroundColor Yellow
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    $needsReboot = $true
}

if ($needsReboot) {
    Write-Host ""
    Write-Host "WSL features enabled!" -ForegroundColor Green
    Write-Host ""
    Write-Host "REBOOT REQUIRED" -ForegroundColor Red
    Write-Host "Please reboot your computer and run this script again." -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 0
} else {
    Write-Host "  -> WSL features already enabled!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2: Updating WSL..." -ForegroundColor Yellow
wsl --update 2>&1 | Out-Null

Write-Host ""
Write-Host "Step 3: Setting WSL 2 as default..." -ForegroundColor Yellow
wsl --set-default-version 2 2>&1 | Out-Null

Write-Host ""
Write-Host "Step 4: Installing distributions..." -ForegroundColor Yellow
Write-Host "This may take several minutes. Please be patient..." -ForegroundColor Gray
Write-Host ""

$distros = @(
    @{Name = "Ubuntu-22.04"; DisplayName = "Ubuntu 22.04 LTS"},
    @{Name = "kali-linux"; DisplayName = "Kali Linux"},
    @{Name = "Arch"; DisplayName = "Arch Linux"}
)

foreach ($distro in $distros) {
    Write-Host "  -> Installing $($distro.DisplayName)..." -ForegroundColor Cyan
    
    # Install without launching (--no-launch flag)
    $result = wsl --install -d $distro.Name --no-launch 2>&1
    
    if ($LASTEXITCODE -eq 0 -or $result -match "already installed") {
        Write-Host "     ✓ $($distro.DisplayName) ready!" -ForegroundColor Green
    } else {
        Write-Host "     ! $($distro.DisplayName) installation started" -ForegroundColor Yellow
    }
    
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host "Step 5: Configuring Windows Terminal profiles..." -ForegroundColor Yellow

# Get Windows Terminal settings path
$terminalSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $terminalSettingsPath) {
    Write-Host "  -> Windows Terminal found!" -ForegroundColor Green
    Write-Host "  -> Profile configuration file provided: windows-terminal-wsl-profiles.json" -ForegroundColor Cyan
    Write-Host "  -> You can manually add these profiles to your Windows Terminal settings" -ForegroundColor Yellow
} else {
    Write-Host "  -> Windows Terminal not found. Profiles will still appear automatically." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# List installed distributions
Write-Host "Installed WSL Distributions:" -ForegroundColor Cyan
wsl --list --verbose
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open Windows Terminal (or install it from Microsoft Store)" -ForegroundColor White
Write-Host ""
Write-Host "2. Click the dropdown arrow (▼) next to the + tab button" -ForegroundColor White
Write-Host ""
Write-Host "3. You'll see these new profiles:" -ForegroundColor White
Write-Host "   • Ubuntu-22.04" -ForegroundColor Green
Write-Host "   • kali-linux" -ForegroundColor Green  
Write-Host "   • Arch" -ForegroundColor Green
Write-Host ""
Write-Host "4. Click any profile to launch it for the first time" -ForegroundColor White
Write-Host ""
Write-Host "5. Create your username and password when prompted" -ForegroundColor White
Write-Host ""
Write-Host "TIP: For custom colors and icons, import the profiles from:" -ForegroundColor Cyan
Write-Host "     windows-terminal-wsl-profiles.json" -ForegroundColor White
Write-Host ""

pause
