# WSL Multi-Distro Installer Script - Phase Tracker
# Run this script in PowerShell as Administrator

$flagFile = "$env:TEMP\wsl_install_phase.txt"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

# Check if this is post-reboot
if (Test-Path $flagFile) {
    $phase = Get-Content $flagFile
    
    if ($phase -eq "POST_REBOOT") {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host "WSL Configuration - Post-Reboot Setup" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Now configuring each distribution with username/password..." -ForegroundColor Yellow
        Write-Host ""
        
        # List of distributions to configure
        $distros = @("Ubuntu-22.04", "kali-linux", "Arch")
        
        foreach ($distro in $distros) {
            Write-Host ""
            Write-Host "Opening $distro for configuration..." -ForegroundColor Cyan
            Write-Host "Please create a username and password in the new window." -ForegroundColor Yellow
            Write-Host ""
            
            # Launch distribution in new window for first-time setup
            Start-Process wsl.exe -ArgumentList "-d $distro" -Wait
            
            Write-Host "$distro configuration complete!" -ForegroundColor Green
            Start-Sleep -Seconds 2
        }
        
        # Clean up flag file
        Remove-Item $flagFile -Force
        
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "All Distributions Configured!" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now use WSL with any of these commands:" -ForegroundColor Cyan
        Write-Host "  wsl -d Ubuntu-22.04" -ForegroundColor White
        Write-Host "  wsl -d kali-linux" -ForegroundColor White
        Write-Host "  wsl -d Arch" -ForegroundColor White
        Write-Host ""
        Write-Host "Or open Windows Terminal and select from the dropdown!" -ForegroundColor Yellow
        Write-Host ""
        
        pause
        exit 0
    }
}

# Phase 1: Initial Installation
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WSL Multi-Distribution Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Enable WSL if not already enabled
Write-Host "Step 1: Checking WSL features..." -ForegroundColor Yellow
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
$vmFeature = Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

$needsReboot = $false

if ($wslFeature.State -ne "Enabled") {
    Write-Host "Enabling WSL feature..." -ForegroundColor Yellow
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    $needsReboot = $true
}

if ($vmFeature.State -ne "Enabled") {
    Write-Host "Enabling Virtual Machine Platform..." -ForegroundColor Yellow
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    $needsReboot = $true
}

if (-not $needsReboot) {
    Write-Host "WSL features already enabled!" -ForegroundColor Green
}

Write-Host ""
Write-Host "Step 2: Updating WSL..." -ForegroundColor Yellow
wsl --update

Write-Host ""
Write-Host "Step 3: Setting WSL 2 as default..." -ForegroundColor Yellow
wsl --set-default-version 2

# Download distributions without launching
Write-Host ""
Write-Host "Step 4: Downloading and installing distributions..." -ForegroundColor Yellow
Write-Host "This may take several minutes. Please be patient..." -ForegroundColor Gray
Write-Host ""

$distros = @(
    @{Name = "Ubuntu-22.04"; DisplayName = "Ubuntu 22.04 LTS"},
    @{Name = "kali-linux"; DisplayName = "Kali Linux"},
    @{Name = "Arch"; DisplayName = "Arch Linux"}
)

foreach ($distro in $distros) {
    Write-Host "  -> Downloading $($distro.DisplayName)..." -ForegroundColor Cyan
    
    # Use --no-launch flag to download without opening
    wsl --install -d $distro.Name --no-launch 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "     ✓ $($distro.DisplayName) downloaded successfully!" -ForegroundColor Green
    } else {
        Write-Host "     ! $($distro.DisplayName) may already be installed or download in progress" -ForegroundColor Yellow
    }
    
    Start-Sleep -Seconds 3
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Installation Phase Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

# Set flag for post-reboot configuration
"POST_REBOOT" | Out-File -FilePath $flagFile -Force

# Create scheduled task to run this script after reboot
$taskName = "WSL_PostReboot_Config"
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
$trigger = New-ScheduledTaskTrigger -AtLogOn
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

# Remove existing task if it exists
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

# Register new task
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -Settings $settings | Out-Null

Write-Host "A scheduled task has been created to continue setup after reboot." -ForegroundColor Cyan
Write-Host ""
Write-Host "SYSTEM REBOOT REQUIRED" -ForegroundColor Red
Write-Host ""
Write-Host "After reboot:" -ForegroundColor Yellow
Write-Host "1. The configuration script will run automatically" -ForegroundColor White
Write-Host "2. Each distribution will open in a new window" -ForegroundColor White
Write-Host "3. Create a username and password for each one" -ForegroundColor White
Write-Host ""

$response = Read-Host "Press 'R' to reboot now, or any other key to reboot later"

if ($response -eq 'R' -or $response -eq 'r') {
    Write-Host ""
    Write-Host "Rebooting in 10 seconds..." -ForegroundColor Yellow
    Write-Host "Save any open work now!" -ForegroundColor Red
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host ""
    Write-Host "Please reboot your computer manually to continue setup." -ForegroundColor Yellow
    Write-Host "The configuration will continue automatically after reboot." -ForegroundColor Cyan
    Write-Host ""
    pause
}
