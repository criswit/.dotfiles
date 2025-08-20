#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logger.sh"

install_nerd_font() {
	log_section "installing Nerd Font (JetBrains Mono)"
	
	local font_dir="$HOME/.local/share/fonts"
	local font_name="JetBrainsMono"
	local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip"
	
	# Create fonts directory if it doesn't exist
	if [[ ! -d "$font_dir" ]]; then
		log_info "creating font directory: $font_dir"
		mkdir -p "$font_dir"
	fi
	
	# Check if font is already installed
	if fc-list | grep -q "JetBrainsMono Nerd Font"; then
		log_info "JetBrains Mono Nerd Font is already installed"
		return 0
	fi
	
	log_info "downloading JetBrains Mono Nerd Font"
	
	# Download and install font
	local temp_dir=$(mktemp -d)
	trap "rm -rf $temp_dir" EXIT
	
	if command -v wget >/dev/null 2>&1; then
		wget -q "$font_url" -O "$temp_dir/${font_name}.zip"
	elif command -v curl >/dev/null 2>&1; then
		curl -sL "$font_url" -o "$temp_dir/${font_name}.zip"
	else
		log_error "neither wget nor curl found - cannot download font"
		return 1
	fi
	
	log_info "extracting font files"
	unzip -q "$temp_dir/${font_name}.zip" -d "$temp_dir"
	
	log_info "installing font files"
	find "$temp_dir" -name "*.ttf" -o -name "*.otf" | while read -r font_file; do
		cp "$font_file" "$font_dir/"
	done
	
	log_info "updating font cache"
	fc-cache -f "$font_dir"
	
	log_info "JetBrains Mono Nerd Font installed successfully"
	log_info "you may need to configure your terminal to use 'JetBrainsMono Nerd Font'"
	
	return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	install_nerd_font
fi