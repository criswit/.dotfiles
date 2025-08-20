#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logger.sh"
source "${SCRIPT_DIR}/installer_functions.sh"

install_extension() {
	local uuid="$1"
	
	# Skip if already installed
	if gnome-extensions list 2>/dev/null | grep -q "$uuid"; then
		log_info "extension already installed: $uuid"
		gnome-extensions enable "$uuid" 2>/dev/null || true
		return 0
	fi
	
	# Get GNOME Shell version
	local gnome_version=$(gnome-shell --version | awk '{print $3}' | cut -d'.' -f1-2)
	
	# Build the API URL
	local api_url="https://extensions.gnome.org/extension-info/?uuid=${uuid}&shell_version=${gnome_version}"
	
	# Get extension info
	local ext_info=$(curl -s "$api_url" 2>/dev/null || wget -qO- "$api_url" 2>/dev/null || echo "")
	
	if [[ -z "$ext_info" ]] || [[ "$ext_info" == *"\"error\""* ]]; then
		log_warn "could not fetch info for $uuid"
		return 1
	fi
	
	# Extract download URL
	local download_path=$(echo "$ext_info" | grep -oP '"download_url":\s*"\K[^"]+' | head -1)
	
	if [[ -z "$download_path" ]]; then
		log_warn "no download URL found for $uuid"
		return 1
	fi
	
	# Download and install
	local temp_file="/tmp/${uuid}.zip"
	curl -sL "https://extensions.gnome.org${download_path}" -o "$temp_file" 2>/dev/null || \
		wget -q "https://extensions.gnome.org${download_path}" -O "$temp_file" 2>/dev/null
	
	if [[ ! -f "$temp_file" ]]; then
		log_error "failed to download $uuid"
		return 1
	fi
	
	# Install the extension
	gnome-extensions install --force "$temp_file" 2>/dev/null
	rm -f "$temp_file"
	
	# Enable it
	gnome-extensions enable "$uuid" 2>/dev/null || true
	log_info "installed and enabled: $uuid"
	return 0
}

install_gnome_extensions() {
	log_section "installing GNOME Shell extensions"
	
	# Check if running GNOME
	if [[ ! "$XDG_CURRENT_DESKTOP" =~ GNOME ]] && [[ ! "$DESKTOP_SESSION" =~ gnome ]]; then
		log_warn "not running GNOME desktop, skipping"
		return 0
	fi
	
	# Check dependencies
	if ! command -v gnome-extensions >/dev/null 2>&1; then
		log_info "installing gnome-shell-extensions package"
		sudo apt install -y gnome-shell-extensions
	fi
	
	# Get extensions from config
	local extensions
	extensions=$(get_from_config "gnome-extensions" "elements") || {
		log_error "failed to get extensions from config"
		return 1
	}
	
	[[ -z "$extensions" ]] && {
		log_info "no extensions configured"
		return 0
	}
	
	# Process each extension
	while IFS= read -r uuid; do
		[[ -z "$uuid" ]] && continue
		install_extension "$uuid" || log_warn "failed to install $uuid"
	done <<< "$extensions"
	
	log_info "GNOME extensions installation complete"
	log_info "restart GNOME Shell with Alt+F2 -> 'r' -> Enter"
	return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	install_gnome_extensions
fi