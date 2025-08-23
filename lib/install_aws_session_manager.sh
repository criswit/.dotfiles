#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logger.sh"

install_aws_session_manager() {
	log_section "installing AWS Session Manager plugin"
	log_debug "entering install_aws_session_manager function"

	# Check if AWS CLI is installed first
	if ! command -v aws >/dev/null 2>&1; then
		log_error "AWS CLI is not installed. Please install AWS CLI first."
		return 1
	fi

	# Check if Session Manager plugin is already installed
	if command -v session-manager-plugin >/dev/null 2>&1; then
		local plugin_version
		plugin_version=$(session-manager-plugin --version 2>/dev/null | head -n1)
		log_info "AWS Session Manager plugin is already installed: $plugin_version"
		log_debug "exiting install_aws_session_manager - already installed"
		return 0
	fi

	# Detect system architecture
	local arch
	arch=$(uname -m)
	log_info "detected system architecture: $arch"

	# Set appropriate download URL based on architecture
	local download_url=""
	local plugin_name=""
	
	case "$arch" in
		"x86_64"|"amd64")
			download_url="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm"
			plugin_name="session-manager-plugin.rpm"
			log_debug "using x86_64 plugin: $plugin_name"
			;;
		"aarch64"|"arm64")
			download_url="https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_arm64/session-manager-plugin.rpm"
			plugin_name="session-manager-plugin.rpm"
			log_debug "using ARM64 plugin: $plugin_name"
			;;
		*)
			log_error "unsupported architecture: $arch"
			log_error "AWS Session Manager plugin installation is only supported on x86_64 and ARM64 systems"
			return 1
			;;
	esac

	# Create temporary directory for installation
	local temp_dir="/tmp/aws-session-manager-$$"
	local download_path="$temp_dir/$plugin_name"
	
	log_info "creating temporary directory: $temp_dir"
	mkdir -p "$temp_dir"
	
	# Download Session Manager plugin
	log_info "downloading AWS Session Manager plugin"
	log_debug "download URL: $download_url"
	
	if command -v curl >/dev/null 2>&1; then
		log_debug "using curl for download"
		if ! curl -sL -o "$download_path" "$download_url"; then
			log_error "failed to download Session Manager plugin using curl"
			rm -rf "$temp_dir"
			return 1
		fi
	elif command -v wget >/dev/null 2>&1; then
		log_debug "using wget for download"
		if ! wget -q -O "$download_path" "$download_url"; then
			log_error "failed to download Session Manager plugin using wget"
			rm -rf "$temp_dir"
			return 1
		fi
	else
		log_error "neither curl nor wget found - cannot download Session Manager plugin"
		rm -rf "$temp_dir"
		return 1
	fi

	# Verify download
	if [[ ! -f "$download_path" ]] || [[ ! -s "$download_path" ]]; then
		log_error "downloaded file is missing or empty"
		rm -rf "$temp_dir"
		return 1
	fi
	
	local file_size
	file_size=$(stat -c%s "$download_path" 2>/dev/null || stat -f%z "$download_path" 2>/dev/null || echo "unknown")
	log_info "downloaded plugin: $file_size bytes"

	# Install plugin using package manager
	log_info "installing AWS Session Manager plugin"
	
	# Try to install using the appropriate package manager
	local install_success=false
	
	# Try dnf first (Fedora/RHEL 8+)
	if command -v dnf >/dev/null 2>&1; then
		log_debug "using dnf to install plugin"
		if sudo dnf install -y "$download_path"; then
			install_success=true
		fi
	# Try yum (older RHEL/CentOS)
	elif command -v yum >/dev/null 2>&1; then
		log_debug "using yum to install plugin"
		if sudo yum install -y "$download_path"; then
			install_success=true
		fi
	# Try apt (Ubuntu/Debian) - convert RPM to DEB
	elif command -v apt >/dev/null 2>&1; then
		log_debug "using apt with alien to install plugin"
		if command -v alien >/dev/null 2>&1; then
			# Convert RPM to DEB
			cd "$temp_dir"
			if alien -d "$plugin_name"; then
				local deb_file
				deb_file=$(ls -1 *.deb 2>/dev/null | head -n1)
				if [[ -n "$deb_file" ]] && sudo apt install -y "./$deb_file"; then
					install_success=true
				fi
			fi
		else
			log_warning "alien not found - cannot convert RPM to DEB"
			log_info "you can install alien with: sudo apt install alien"
		fi
	fi

	if [[ "$install_success" == false ]]; then
		log_error "failed to install Session Manager plugin using package manager"
		log_info "you may need to install it manually or install alien for RPM to DEB conversion"
		rm -rf "$temp_dir"
		return 1
	fi

	# Verify installation
	log_info "verifying Session Manager plugin installation"
	if ! command -v session-manager-plugin >/dev/null 2>&1; then
		log_error "Session Manager plugin installation verification failed"
		rm -rf "$temp_dir"
		return 1
	fi

	# Get installed version
	local installed_version
	installed_version=$(session-manager-plugin --version 2>/dev/null | head -n1)
	log_info "AWS Session Manager plugin successfully installed: $installed_version"

	# Clean up temporary files
	log_debug "cleaning up temporary files"
	rm -rf "$temp_dir"
	
	log_info "AWS Session Manager plugin installation complete!"
	log_debug "exiting install_aws_session_manager - success"
	return 0
}

# Main execution if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	install_aws_session_manager
fi





