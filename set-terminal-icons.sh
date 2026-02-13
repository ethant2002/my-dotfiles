#!/bin/bash

# Script to set custom icons for Windows Terminal profiles
# Icons are sourced from: https://github.com/ethant2002/icons

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Windows Terminal Icon Configurator${NC}"
echo "================================================"

# Determine Windows Terminal settings path
SETTINGS_PATH=""

# Try LocalState path first (typical for stable release)
LOCALSTATE_PATH="/mnt/c/Users/$USER/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
# Preview version path
PREVIEW_PATH="/mnt/c/Users/$USER/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json"

if [ -f "$LOCALSTATE_PATH" ]; then
    SETTINGS_PATH="$LOCALSTATE_PATH"
    echo -e "${GREEN}✓${NC} Found Windows Terminal settings (Stable)"
elif [ -f "$PREVIEW_PATH" ]; then
    SETTINGS_PATH="$PREVIEW_PATH"
    echo -e "${GREEN}✓${NC} Found Windows Terminal settings (Preview)"
else
    echo -e "${RED}✗${NC} Windows Terminal settings.json not found!"
    echo "Please ensure Windows Terminal is installed."
    exit 1
fi

echo "Settings path: $SETTINGS_PATH"
echo ""

# GitHub repository base URL for raw icons
GITHUB_RAW_BASE="https://raw.githubusercontent.com/ethant2002/icons/main"

# Icon mappings: Profile name -> Icon filename
declare -A ICON_MAP=(
    ["Ubuntu-22.04"]="icons8-ubuntu-20.png"
    ["Arch"]="icons8-arch-linux-24.png"
    ["Kali"]="icons8-fsociety-mask-19.png"
    ["cmd"]="icons8-cmd-20.png"
    ["PowerShell"]="icons8-powershell-17.png"
    ["Azure"]="icons8-azure-20.png"
)

# Backup original settings
BACKUP_PATH="${SETTINGS_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}Creating backup...${NC}"
cp "$SETTINGS_PATH" "$BACKUP_PATH"
echo -e "${GREEN}✓${NC} Backup created: $BACKUP_PATH"
echo ""

# Read the settings file
SETTINGS_CONTENT=$(cat "$SETTINGS_PATH")

# Function to update icon for a profile
update_profile_icon() {
    local profile_name="$1"
    local icon_filename="$2"
    local icon_url="${GITHUB_RAW_BASE}/${icon_filename}"
    
    echo -e "${YELLOW}Updating icon for: ${profile_name}${NC}"
    echo "  Icon: ${icon_filename}"
    echo "  URL: ${icon_url}"
    
    # Use jq to update the icon property for matching profile
    # This preserves all other settings including theme
    SETTINGS_CONTENT=$(echo "$SETTINGS_CONTENT" | jq --arg name "$profile_name" --arg icon "$icon_url" '
        (.profiles.list[] | select(.name == $name) | .icon) = $icon
    ')
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Updated successfully"
    else
        echo -e "${RED}✗${NC} Failed to update"
    fi
    echo ""
}

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗${NC} jq is not installed. Installing jq..."
    sudo apt-get update && sudo apt-get install -y jq
fi

# Update icons for each profile
for profile in "${!ICON_MAP[@]}"; do
    update_profile_icon "$profile" "${ICON_MAP[$profile]}"
done

# Write the updated settings back to file
echo "$SETTINGS_CONTENT" > "$SETTINGS_PATH"

echo "================================================"
echo -e "${GREEN}✓ Icon configuration complete!${NC}"
echo ""
echo "Changes applied:"
echo "  • Ubuntu-22.04 → icons8-ubuntu-20.png"
echo "  • Arch → icons8-arch-linux-24.png"
echo "  • Kali → icons8-fsociety-mask-19.png (fsociety)"
echo "  • cmd → icons8-cmd-20.png"
echo "  • PowerShell → icons8-powershell-17.png"
echo "  • Azure → icons8-azure-20.png"
echo ""
echo -e "${YELLOW}Note:${NC} Your theme and other settings have been preserved."
echo -e "${YELLOW}Note:${NC} Restart Windows Terminal to see the changes."
echo ""
echo "To restore original settings, use:"
echo "  cp $BACKUP_PATH $SETTINGS_PATH"
