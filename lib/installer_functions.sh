#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config.json"

source "${SCRIPT_DIR}/logger.sh"

get_from_config() {
	local simple_path="$1"
	local return_format="${2:-elements}"  # "elements" (default) or "array"
	
	log_debug "retrieving config for path: $simple_path (format: $return_format)" >&2
	
	if [[ -z "$simple_path" ]]; then
		log_error "JSON path is required" >&2
		return 1
	fi
	
	if [[ ! -f "$CONFIG_FILE" ]]; then
		log_error "config file not found: $CONFIG_FILE" >&2
		return 1
	fi
	
	# Check if jq is available
	if ! command -v jq >/dev/null 2>&1; then
		log_error "jq is required but not installed" >&2
		return 1
	fi
	
	# Convert simple dot notation to proper jq syntax
	local jq_path=""
	IFS='.' read -ra PARTS <<< "$simple_path"
	
	for i in "${!PARTS[@]}"; do
		local part="${PARTS[$i]}"
		if [[ -n "$part" ]]; then
			# Quote parts that contain hyphens or other special characters
			if [[ "$part" =~ [^a-zA-Z0-9_] ]]; then
				if [[ $i -eq 0 ]]; then
					# First element needs leading dot
					jq_path=".[\"$part\"]"
				else
					jq_path="${jq_path}[\"$part\"]"
				fi
			else
				if [[ -z "$jq_path" ]]; then
					jq_path=".$part"
				else
					jq_path="${jq_path}.$part"
				fi
			fi
		fi
	done
	
	# Check if the result is an array and if so, extract all elements
	log_debug "executing jq query: $jq_path" >&2
	local result
	result=$(jq -r "$jq_path" "$CONFIG_FILE" 2>/dev/null)
	local exit_code=$?
	
	if [[ $exit_code -ne 0 ]]; then
		log_error "failed to query JSON path: $simple_path" >&2
		return 1
	fi
	
	if [[ "$result" == "null" ]]; then
		log_error "JSON path not found: $simple_path" >&2
		return 1
	fi
	
	# Handle array extraction based on return_format
	if [[ "$result" =~ ^\[.*\]$ ]]; then
		if [[ "$return_format" == "elements" ]]; then
			# Extract individual elements (default behavior)
			jq_path="${jq_path}[]"
			result=$(jq -r "$jq_path" "$CONFIG_FILE" 2>/dev/null)
		elif [[ "$return_format" == "array" ]]; then
			# Return the raw JSON array (use -c for compact output)
			result=$(jq -c "$jq_path" "$CONFIG_FILE" 2>/dev/null)
		fi
	fi

	log_debug "config query returned: $(echo "$result" | head -1)$([ $(echo "$result" | wc -l) -gt 1 ] && echo "...")" >&2
	echo "$result"
	return 0
}

is_package_installed() {
	log_debug "checking if package $1 is installed"
	if command -v "$1" >/dev/null 2>&1; then
		log_info "package $1 is installed at $(which "$1")"
		return 0
	fi
	log_debug "package $1 is not installed"
	return 1
}

install_deb_get() {
	log_section "installing deb-get"
	log_debug "entering install_deb_get function"

	if is_package_installed "deb-get"; then
		log_info "deb-get is already installed"
		log_debug "exiting install_deb_get - already installed"
		return 0
	fi
	
	log_info "installing deb-get package manager"
	
	# Download and install deb-get
	if command -v curl >/dev/null 2>&1; then
		log_info "downloading deb-get using curl"
		curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get
	elif command -v wget >/dev/null 2>&1; then
		log_info "downloading deb-get using wget"
		wget -qO- https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get
	else
		log_error "neither curl nor wget found - cannot download deb-get"
		return 1
	fi
	
	# Verify installation
	if is_package_installed "deb-get"; then
		log_info "deb-get successfully installed"
		log_debug "exiting install_deb_get - success"
		return 0
	else
		log_error "deb-get installation failed"
		log_debug "exiting install_deb_get - failed"
		return 1
	fi
}

install_deb_get_packages() {
	log_section "installing deb-get packages"
	log_debug "entering install_deb_get_packages function"
	
	# Ensure deb-get is installed first
	if ! is_package_installed "deb-get"; then
		log_info "deb-get not found, installing it first"
		if ! install_deb_get; then
			log_error "failed to install deb-get, cannot proceed with package installation"
			return 1
		fi
	fi
	
	# Get package list from config
	local packages
	packages=$(get_from_config "packages.deb-get" "elements")
	local get_config_exit_code=$?
	
	if [[ $get_config_exit_code -ne 0 ]]; then
		log_error "failed to get deb-get packages from config"
		return 1
	fi
	
	if [[ -z "$packages" ]]; then
		log_info "no deb-get packages found in config"
		return 0
	fi
	
	# Install each package
	local failed_packages=()
	local installed_count=0
	local total_count=0
	local package_array=()
	
	# Count total packages first
	while IFS= read -r package; do
		[[ -z "$package" ]] && continue
		package_array+=("$package")
	done <<< "$packages"
	
	total_count=${#package_array[@]}
	log_info "found $total_count deb-get packages to process"
	
	# Install each package
	for package in "${package_array[@]}"; do
		local current=$((installed_count + ${#failed_packages[@]} + 1))
		log_info "[$current/$total_count] installing package: $package"
		
		# deb-get may return non-zero for already installed packages
		# so we capture the output and check for success patterns
		local install_output
		install_output=$(sudo deb-get install "$package" 2>&1) || true
		local exit_code=$?
		
		echo "$install_output"
		
		if [[ "$install_output" == *"is up to date"* ]] || [[ "$install_output" == *"successfully installed"* ]] || [[ $exit_code -eq 0 ]]; then
			log_info "[$current/$total_count] successfully installed: $package"
			installed_count=$((installed_count + 1))
		else
			log_error "[$current/$total_count] failed to install: $package"
			failed_packages+=("$package")
		fi
	done
	
	# Report results
	log_info "installation summary: $installed_count/$total_count packages installed successfully"
	
	if [[ ${#failed_packages[@]} -gt 0 ]]; then
		log_error "failed packages: ${failed_packages[*]}"
		return 1
	fi
	
	log_info "all deb-get packages installed successfully"
	log_debug "exiting install_deb_get_packages - success"
	return 0
}

install_apt_package() {
	local package="$1"
	
	log_debug "entering install_apt_package for: $package"
	
	if [[ -z "$package" ]]; then
		log_error "package name is required"
		return 1
	fi
	
	log_info "checking apt package: $package"
	
	# Check if package is already installed
	log_debug "checking dpkg status for $package"
	if dpkg -l | grep -q "^ii[[:space:]]\+${package}[[:space:]]"; then
		log_info "package $package is already installed"
		log_debug "exiting install_apt_package - already installed"
		return 0
	fi
	
	log_info "package $package needs to be installed"
	
	# Update package list if it's been more than a day since last update
	local apt_cache_time
	if [[ -f /var/cache/apt/pkgcache.bin ]]; then
		apt_cache_time=$(stat -c %Y /var/cache/apt/pkgcache.bin)
		local current_time=$(date +%s)
		local time_diff=$((current_time - apt_cache_time))
		
		# Update if cache is older than 24 hours (86400 seconds)
		if [[ $time_diff -gt 86400 ]]; then
			log_info "apt cache is $((time_diff / 3600)) hours old, updating..."
			if ! sudo apt update; then
				log_error "failed to update apt package cache"
				return 1
			fi
			log_info "apt cache updated successfully"
		else
			log_debug "apt cache is $((time_diff / 3600)) hours old, skipping update"
		fi
	else
		# No cache file exists, update
		log_info "updating apt package cache"
		if ! sudo apt update; then
			log_error "failed to update apt package cache"
			return 1
		fi
	fi
	
	# Install the package
	log_info "installing $package via apt..."
	if sudo apt install -y "$package"; then
		log_info "successfully installed apt package: $package"
		log_debug "exiting install_apt_package - success"
		return 0
	else
		log_error "failed to install apt package: $package"
		log_debug "exiting install_apt_package - failed"
		return 1
	fi
}

install_apt_packages() {
	local package_group="$1"
	
	[[ -z "$package_group" ]] && { log_error "package group required"; return 1; }
	
	log_section "installing $package_group packages"
	
	# Get packages from config
	local packages
	packages=$(get_from_config "packages.$package_group" "elements") || return 1
	[[ -z "$packages" ]] && { log_info "no $package_group packages found"; return 0; }
	
	# Convert to array and install
	local failed=()
	while IFS= read -r pkg; do
		[[ -z "$pkg" ]] && continue
		log_info "installing: $pkg"
		install_apt_package "$pkg" || failed+=("$pkg")
	done <<< "$packages"
	
	# Report results
	if [[ ${#failed[@]} -gt 0 ]]; then
		log_error "failed packages: ${failed[*]}"
		return 1
	fi
	
	log_info "all $package_group packages installed"
	return 0
}

install_essential_packages() {
	log_debug "calling install_apt_packages for essential packages"
	install_apt_packages "essential"
}

install_general_packages() {
	log_debug "calling install_apt_packages for general packages"
	install_apt_packages "general"
}

install_desktop_packages() {
	log_debug "calling install_apt_packages for desktop packages"
	install_apt_packages "desktop"
}

add_ppa_repositories() {
	log_section "adding PPA repositories"
	log_debug "entering add_ppa_repositories function"
	
	# Check if software-properties-common is installed (for add-apt-repository command)
	if ! command -v add-apt-repository >/dev/null 2>&1; then
		log_info "installing software-properties-common for PPA support"
		sudo apt update
		sudo apt install -y software-properties-common
	fi
	
	# Get PPAs from config
	local ppas
	ppas=$(get_from_config "ppas" "elements") || {
		log_info "no PPAs configured"
		return 0
	}
	
	[[ -z "$ppas" ]] && {
		log_info "no PPAs to add"
		return 0
	}
	
	# Process each PPA
	while IFS= read -r ppa; do
		[[ -z "$ppa" ]] && continue
		
		# Check if PPA is already added by looking in sources.list.d
		local ppa_name=$(echo "$ppa" | sed 's/ppa://' | sed 's/\//-/g')
		if ls /etc/apt/sources.list.d/ | grep -q "$ppa_name"; then
			log_info "PPA already added: $ppa"
		else
			log_info "adding PPA: $ppa"
			sudo add-apt-repository -y "$ppa"
		fi
	done <<< "$ppas"
	
	# Update package list after adding PPAs
	log_info "updating package list"
	sudo apt update
	
	log_info "PPA repositories added"
	log_debug "exiting add_ppa_repositories"
	return 0
}

install_ppa_packages() {
	log_section "installing PPA packages"
	log_debug "entering install_ppa_packages function"
	
	# Get PPA packages from config
	local packages
	packages=$(get_from_config "packages.ppa" "elements") || {
		log_info "no PPA packages configured"
		return 0
	}
	
	[[ -z "$packages" ]] && {
		log_info "no PPA packages to install"
		return 0
	}
	
	# Install each package
	while IFS= read -r package; do
		[[ -z "$package" ]] && continue
		install_apt_package "$package"
	done <<< "$packages"
	
	log_info "PPA packages installation complete"
	log_debug "exiting install_ppa_packages"
	return 0
}

install_mise() {
	log_section "installing mise"
	log_debug "entering install_mise function"
	
	if is_package_installed "mise"; then
		log_info "mise is already installed"
		log_debug "exiting install_mise - already installed"
		return 0
	fi
	
	log_info "downloading and installing mise"
	
	# Install mise using the official installation script
	if command -v curl >/dev/null 2>&1; then
		log_info "downloading mise installer via curl"
		curl https://mise.run | sh
	elif command -v wget >/dev/null 2>&1; then
		log_info "downloading mise installer via wget"
		wget -qO- https://mise.run | sh
	else
		log_error "neither curl nor wget found - cannot download mise"
		log_debug "exiting install_mise - missing dependencies"
		return 1
	fi
	
	# Add mise to PATH for current session
	export PATH="$HOME/.local/bin:$PATH"
	
	# Verify installation
	if command -v mise >/dev/null 2>&1; then
		log_info "mise successfully installed at $(which mise)"
		log_info "mise version: $(mise --version)"
		
		# Activate mise for current shell
		eval "$(mise activate bash)"
		
		# Add shell integration instructions
		log_info "add the following to your shell rc file:"
		log_info '  eval "$(mise activate bash)"  # for bash'
		log_info '  eval "$(mise activate zsh)"   # for zsh'
		
		log_debug "exiting install_mise - success"
		return 0
	else
		log_error "mise installation failed"
		log_debug "exiting install_mise - failed"
		return 1
	fi
}

install_vscode_extensions() {
	log_section "installing vscode extensions"
	log_debug "entering install_vscode_extensions function"
	
	# Check if VSCode is installed
	if ! command -v code >/dev/null 2>&1; then
		log_warning "vscode (code) is not installed - skipping extension installation"
		log_info "install vscode first using: install_deb_get_packages"
		log_debug "exiting install_vscode_extensions - vscode not found"
		return 1
	fi
	
	log_info "vscode found at: $(which code)"
	
	# Get extensions from config
	local extensions
	log_debug "calling get_from_config for vscode-extensions"
	extensions=$(get_from_config "packages.vscode-extensions" "elements" 2>/dev/null) || {
		log_info "no vscode extensions configured"
		return 0
	}
	log_debug "get_from_config returned successfully"
	
	[[ -z "$extensions" ]] && {
		log_info "no vscode extensions found in config"
		return 0
	}
	
	# Count extensions for progress tracking
	local total_count=0
	local installed_count=0
	local failed_extensions=()
	
	# Count total extensions
	while IFS= read -r ext; do
		[[ -z "$ext" ]] && continue
		((total_count++)) || true
	done <<< "$extensions"
	
	log_info "found $total_count extensions to install"
	
	# Install each extension
	while IFS= read -r extension; do
		[[ -z "$extension" ]] && continue
		
		log_info "installing extension: $extension"
		
		# Check if already installed
		if code --list-extensions 2>/dev/null | grep -qi "^${extension}$"; then
			log_info "extension $extension is already installed"
			((installed_count++)) || true
			continue
		fi
		
		# Install the extension
		if code --install-extension "$extension" --force 2>&1 | while read -r line; do
			log_debug "  $line"
		done; then
			log_info "successfully installed: $extension"
			((installed_count++)) || true
		else
			log_error "failed to install: $extension"
			failed_extensions+=("$extension")
		fi
	done <<< "$extensions"
	
	# Report results
	log_info "installation summary: $installed_count/$total_count extensions installed successfully"
	
	if [[ ${#failed_extensions[@]} -gt 0 ]]; then
		log_error "failed extensions: ${failed_extensions[*]}"
		return 1
	fi
	
	log_info "all vscode extensions installed successfully"
	log_debug "exiting install_vscode_extensions - success"
	return 0
}

install_uv() {
	log_section "installing uv"
	log_debug "entering install_uv function"
	
	if is_package_installed "uv"; then
		log_info "uv is already installed"
		log_debug "exiting install_uv - already installed"
		return 0
	fi
	
	log_info "downloading and installing uv"
	
	# Install uv using the official installation script
	if command -v curl >/dev/null 2>&1; then
		log_info "downloading uv installer via curl"
		curl -LsSf https://astral.sh/uv/install.sh | sh
	elif command -v wget >/dev/null 2>&1; then
		log_info "downloading uv installer via wget"
		wget -qO- https://astral.sh/uv/install.sh | sh
	else
		log_error "neither curl nor wget found - cannot download uv"
		log_debug "exiting install_uv - missing dependencies"
		return 1
	fi
	
	# Add uv to PATH for current session
	export PATH="$HOME/.local/bin:$PATH"
	
	# Verify installation
	if command -v uv >/dev/null 2>&1; then
		log_info "uv successfully installed at $(which uv)"
		log_info "uv version: $(uv --version)"
		
		# Generate shell completions if directories exist
		local bash_completion_dir="$HOME/.local/share/bash-completion/completions"
		local zsh_completion_dir="$HOME/.local/share/zsh/site-functions"
		
		if [[ -d "$bash_completion_dir" ]]; then
			log_info "generating bash completions"
			uv generate-shell-completion bash > "$bash_completion_dir/uv" 2>/dev/null || true
		fi
		
		if [[ -d "$zsh_completion_dir" ]]; then
			log_info "generating zsh completions"
			uv generate-shell-completion zsh > "$zsh_completion_dir/_uv" 2>/dev/null || true
		fi
		
		log_info "uv has been installed successfully"
		log_info "configuration will be deployed via stow"
		
		log_debug "exiting install_uv - success"
		return 0
	else
		log_error "uv installation failed"
		log_debug "exiting install_uv - failed"
		return 1
	fi
}

install_wezterm() {
	log_section "installing WezTerm"
	log_debug "entering install_wezterm function"
	
	if is_package_installed "wezterm"; then
		log_info "WezTerm is already installed"
		log_debug "exiting install_wezterm - already installed"
		return 0
	fi
	
	log_info "installing WezTerm terminal emulator"
	
	# Add WezTerm repository
	log_info "adding WezTerm GPG key and repository"
	
	# Download and add GPG key
	curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
	
	# Add repository
	echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" | sudo tee /etc/apt/sources.list.d/wezterm.list
	
	# Update package list
	log_info "updating package list"
	sudo apt update
	
	# Install WezTerm
	log_info "installing wezterm package"
	sudo apt install -y wezterm
	
	# Verify installation
	if command -v wezterm >/dev/null 2>&1; then
		log_info "WezTerm successfully installed at $(which wezterm)"
		log_info "WezTerm version: $(wezterm --version)"
		log_debug "exiting install_wezterm - success"
		return 0
	else
		log_error "WezTerm installation failed"
		log_debug "exiting install_wezterm - failed"
		return 1
	fi
}


install_npm_global_packages() {
	log_section "installing global npm packages"
	log_debug "entering install_npm_global_packages function"
	
	# Check if npm is installed
	if ! command -v npm >/dev/null 2>&1; then
		log_error "npm is not installed - please install Node.js first"
		log_info "Node.js can be installed via mise after deployment"
		log_debug "exiting install_npm_global_packages - npm not found"
		return 1
	fi
	
	# Get npm global packages from config
	local packages
	packages=$(get_from_config "packages.npm-global" "elements" 2>/dev/null) || {
		log_info "no npm global packages configured"
		return 0
	}
	
	[[ -z "$packages" ]] && {
		log_info "no npm global packages to install"
		return 0
	}
	
	# Count packages for progress tracking
	local package_array=()
	while IFS= read -r package; do
		[[ -z "$package" ]] && continue
		package_array+=("$package")
	done <<< "$packages"
	
	local total_count=${#package_array[@]}
	log_info "found $total_count npm global packages to install"
	
	# Install each package
	local failed_packages=()
	local installed_count=0
	local current=0
	
	for package in "${package_array[@]}"; do
		current=$((current + 1))
		log_info "[$current/$total_count] checking npm package: $package"
		
		# Check if package is already installed
		if npm list -g --depth=0 2>/dev/null | grep -q " $package@"; then
			log_info "[$current/$total_count] package $package is already installed globally"
			installed_count=$((installed_count + 1))
		else
			log_info "[$current/$total_count] installing npm package globally: $package"
			
			if npm install -g "$package"; then
				log_info "[$current/$total_count] successfully installed: $package"
				installed_count=$((installed_count + 1))
			else
				log_error "[$current/$total_count] failed to install: $package"
				failed_packages+=("$package")
			fi
		fi
	done
	
	# Report results
	log_info "installation summary: $installed_count/$total_count packages installed successfully"
	
	if [[ ${#failed_packages[@]} -gt 0 ]]; then
		log_error "failed packages: ${failed_packages[*]}"
		return 1
	fi
	
	log_info "all npm global packages installed successfully"
	log_debug "exiting install_npm_global_packages - success"
	return 0
}

install_external_repos() {
	log_section "installing external repositories"
	log_debug "entering install_external_repos function"
	
	# Check for jq
	if ! command -v jq >/dev/null 2>&1; then
		log_error "jq is required to parse config.json"
		return 1
	fi
	
	# Get external repos from config
	local repos
	repos=$(jq -r '.["external-repos"] | keys[]' "${CONFIG_FILE}" 2>/dev/null) || {
		log_info "no external repositories configured"
		return 0
	}
	
	if [[ -z "$repos" ]]; then
		log_info "no external repositories configured"
		return 0
	fi
	
	# Process each repository
	while IFS= read -r repo_name; do
		log_info "processing external repository: $repo_name"
		
		# Get repository configuration
		local gpg_key_url keyring_path repo_line packages
		gpg_key_url=$(jq -r ".\"external-repos\".\"$repo_name\".\"gpg-key-url\"" "${CONFIG_FILE}")
		keyring_path=$(jq -r ".\"external-repos\".\"$repo_name\".\"keyring-path\"" "${CONFIG_FILE}")
		repo_line=$(jq -r ".\"external-repos\".\"$repo_name\".\"repo-line\"" "${CONFIG_FILE}")
		packages=$(jq -r ".\"external-repos\".\"$repo_name\".packages[]" "${CONFIG_FILE}" 2>/dev/null)
		
		log_debug "gpg_key_url: $gpg_key_url"
		log_debug "keyring_path: $keyring_path"
		log_debug "repo_line: $repo_line"
		
		# Download and add GPG key
		log_info "downloading GPG key for $repo_name"
		if ! curl -fsSL "$gpg_key_url" | sudo gpg --yes --dearmor -o "$keyring_path" 2>/dev/null; then
			log_error "failed to download or add GPG key for $repo_name"
			continue
		fi
		log_info "GPG key added for $repo_name"
		
		# Add repository to sources list
		local sources_file="/etc/apt/sources.list.d/${repo_name}.list"
		log_info "adding repository to $sources_file"
		echo "$repo_line" | sudo tee "$sources_file" > /dev/null
		log_info "repository added for $repo_name"
		
		# Update package index
		log_info "updating package index"
		if ! sudo apt-get update -qq 2>/dev/null; then
			log_error "failed to update package index after adding $repo_name"
			continue
		fi
		
		# Install packages from this repository
		if [[ -n "$packages" ]]; then
			log_info "installing packages from $repo_name: $packages"
			while IFS= read -r package; do
				if dpkg -l | grep -q "^ii  $package "; then
					log_debug "$package is already installed"
				else
					log_info "installing $package"
					if sudo apt-get install -y "$package" >/dev/null 2>&1; then
						log_info "installed $package"
					else
						log_error "failed to install $package"
					fi
				fi
			done <<< "$packages"
		fi
	done <<< "$repos"
	
	log_info "external repositories setup complete"
	log_debug "exiting install_external_repos - success"
	return 0
}

install_jetbrains_toolbox() {
	log_section "installing JetBrains Toolbox"
	log_debug "entering install_jetbrains_toolbox function"
	
	local install_dir="/opt/jetbrains-toolbox"
	local temp_dir=$(mktemp -d)
	
	# Check if already installed
	if [[ -f "$install_dir/jetbrains-toolbox" ]]; then
		log_info "JetBrains Toolbox is already installed at $install_dir"
		log_debug "exiting install_jetbrains_toolbox - already installed"
		return 0
	fi
	
	log_info "fetching latest JetBrains Toolbox version"
	
	# Fetch the latest version URL (replicating the GitHub script logic)
	local download_url
	download_url=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | \
		jq -r '.TBA[0].downloads.linux.link')
	
	if [[ -z "$download_url" || "$download_url" == "null" ]]; then
		log_error "failed to fetch JetBrains Toolbox download URL"
		rm -rf "$temp_dir"
		return 1
	fi
	
	log_info "downloading JetBrains Toolbox from: $download_url"
	
	# Download the tarball
	if ! wget -q --show-progress "$download_url" -O "$temp_dir/jetbrains-toolbox.tar.gz"; then
		log_error "failed to download JetBrains Toolbox"
		rm -rf "$temp_dir"
		return 1
	fi
	
	log_info "extracting JetBrains Toolbox"
	
	# Extract the archive
	if ! tar -xzf "$temp_dir/jetbrains-toolbox.tar.gz" -C "$temp_dir"; then
		log_error "failed to extract JetBrains Toolbox archive"
		rm -rf "$temp_dir"
		return 1
	fi
	
	# Find the extracted directory (it includes version in the name)
	local extracted_dir
	extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "jetbrains-toolbox-*" | head -n1)
	
	if [[ -z "$extracted_dir" ]]; then
		log_error "could not find extracted JetBrains Toolbox directory"
		rm -rf "$temp_dir"
		return 1
	fi
	
	log_info "installing JetBrains Toolbox to $install_dir"
	
	# Create installation directory and move all files from bin directory
	sudo mkdir -p "$install_dir"
	
	# Move all contents from the bin directory
	if [[ -d "$extracted_dir/bin" ]] && [[ -f "$extracted_dir/bin/jetbrains-toolbox" ]]; then
		log_info "moving JetBrains Toolbox files to $install_dir"
		sudo cp -r "$extracted_dir/bin/"* "$install_dir/"
		sudo chmod +x "$install_dir/jetbrains-toolbox"
	else
		log_error "jetbrains-toolbox binary not found in extracted files"
		rm -rf "$temp_dir"
		return 1
	fi
	
	# Clean up
	rm -rf "$temp_dir"
	
	log_info "JetBrains Toolbox successfully installed to $install_dir"
	log_info "creating symlink for command-line access"
	
	# Create symlink in /usr/local/bin for system-wide access
	if [[ ! -L "/usr/local/bin/jetbrains-toolbox" ]]; then
		sudo ln -sf "$install_dir/jetbrains-toolbox" "/usr/local/bin/jetbrains-toolbox"
		log_info "symlink created at /usr/local/bin/jetbrains-toolbox"
	fi
	
	log_debug "exiting install_jetbrains_toolbox - success"
	return 0
}

install_yubico_authenticator() {
	log_section "installing Yubico Authenticator"
	log_debug "entering install_yubico_authenticator function"
	
	local install_dir="/opt/yubico-authenticator"
	local download_url="https://developers.yubico.com/yubioath-flutter/Releases/yubico-authenticator-latest-linux.tar.gz"
	local temp_dir=$(mktemp -d)
	
	# Check if already installed
	if [[ -f "$install_dir/authenticator" ]]; then
		log_info "Yubico Authenticator is already installed"
		log_debug "exiting install_yubico_authenticator - already installed"
		return 0
	fi
	
	log_info "downloading Yubico Authenticator"
	
	# Download the tarball
	if ! wget -q "$download_url" -O "$temp_dir/yubico-authenticator.tar.gz"; then
		log_error "failed to download Yubico Authenticator"
		rm -rf "$temp_dir"
		return 1
	fi
	
	log_info "extracting Yubico Authenticator"
	
	# Extract the tarball
	if ! tar -xzf "$temp_dir/yubico-authenticator.tar.gz" -C "$temp_dir"; then
		log_error "failed to extract Yubico Authenticator"
		rm -rf "$temp_dir"
		return 1
	fi
	
	# Find the extracted directory
	local extracted_dir=$(find "$temp_dir" -maxdepth 1 -type d -name "yubico-authenticator-*" | head -n1)
	
	if [[ -z "$extracted_dir" ]]; then
		log_error "could not find extracted Yubico Authenticator directory"
		rm -rf "$temp_dir"
		return 1
	fi
	
	log_info "installing Yubico Authenticator to $install_dir"
	
	# Create installation directory and move files
	sudo mkdir -p "$install_dir"
	sudo cp -r "$extracted_dir"/* "$install_dir/"
	
	# Make the authenticator executable
	sudo chmod +x "$install_dir/authenticator"
	
	log_info "running desktop integration script"
	
	# Run the desktop integration script
	if [[ -f "$install_dir/desktop_integration.sh" ]]; then
		sudo chmod +x "$install_dir/desktop_integration.sh"
		(cd "$install_dir" && sudo ./desktop_integration.sh)
	else
		log_warning "desktop_integration.sh not found, skipping desktop integration"
	fi
	
	# Clean up
	rm -rf "$temp_dir"
	
	# Verify installation
	if [[ -f "$install_dir/authenticator" ]]; then
		log_info "Yubico Authenticator successfully installed"
		log_debug "exiting install_yubico_authenticator - success"
		return 0
	else
		log_error "Yubico Authenticator installation failed"
		log_debug "exiting install_yubico_authenticator - failed"
		return 1
	fi
}

install_docker() {
	log_section "installing Docker"
	log_debug "entering install_docker function"
	
	# Check if Docker is already installed
	if command -v docker >/dev/null 2>&1; then
		log_info "Docker is already installed at $(which docker)"
		log_info "Docker version: $(docker --version)"
		
		# Still ensure user is in docker group
		if ! groups "$USER" | grep -q '\bdocker\b'; then
			log_info "adding user $USER to docker group"
			sudo usermod -aG docker "$USER"
			log_info "user added to docker group - you may need to log out and back in for this to take effect"
		else
			log_info "user $USER is already in docker group"
		fi
		
		log_debug "exiting install_docker - already installed"
		return 0
	fi
	
	log_info "Docker not found, installing Docker from official repository"
	
	# Install Docker using the official Docker repository
	# This bypasses the generic install_external_repos to handle Docker's specific requirements
	
	# Remove any old Docker packages
	log_info "removing any old Docker packages"
	for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
		if dpkg -l | grep -q "^ii  $pkg "; then
			log_info "removing old package: $pkg"
			sudo apt-get remove -y "$pkg" >/dev/null 2>&1 || true
		fi
	done
	
	# Install prerequisites
	log_info "installing prerequisites for Docker"
	sudo apt-get update
	sudo apt-get install -y ca-certificates curl gnupg
	
	# Add Docker's official GPG key
	log_info "adding Docker GPG key"
	sudo install -m 0755 -d /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
	sudo chmod a+r /etc/apt/keyrings/docker.gpg
	
	# Add Docker repository
	log_info "adding Docker repository"
	echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	
	# Update package index
	log_info "updating package index"
	sudo apt-get update
	
	# Install Docker packages
	log_info "installing Docker packages"
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
	
	# Post-installation configuration
	log_info "configuring Docker post-installation"
	
	# Create docker group if it doesn't exist
	if ! getent group docker >/dev/null 2>&1; then
		log_info "creating docker group"
		sudo groupadd docker
	fi
	
	# Add current user to docker group
	log_info "adding user $USER to docker group"
	sudo usermod -aG docker "$USER"
	log_info "user added to docker group - you may need to log out and back in for this to take effect"
	
	# Enable Docker service to start on boot
	log_info "enabling Docker service to start on boot"
	sudo systemctl enable docker.service
	sudo systemctl enable containerd.service
	
	# Start Docker service if not running
	if ! sudo systemctl is-active --quiet docker; then
		log_info "starting Docker service"
		sudo systemctl start docker
		sudo systemctl start containerd
	else
		log_info "Docker service is already running"
	fi
	
	# Verify Docker installation
	log_info "verifying Docker installation"
	if docker --version >/dev/null 2>&1; then
		log_info "Docker successfully installed: $(docker --version)"
	else
		log_error "Docker installation verification failed"
		return 1
	fi
	
	# Verify Docker Compose
	if docker compose version >/dev/null 2>&1; then
		log_info "Docker Compose successfully installed: $(docker compose version)"
	else
		log_warning "Docker Compose not found - it should have been installed with docker-compose-plugin"
	fi
	
	# Test Docker functionality (will only work if user is in docker group and session reloaded)
	log_info "testing Docker functionality (may require logout/login if permission denied)"
	if sudo docker run --rm hello-world >/dev/null 2>&1; then
		log_info "Docker test successful - hello-world container ran successfully"
	else
		log_warning "Docker test failed - this is normal if you haven't logged out and back in yet"
	fi
	
	log_info "Docker installation and configuration complete"
	log_info "NOTE: You need to log out and log back in for group changes to take effect"
	log_info "After logging back in, you can run 'docker run hello-world' to verify"
	
	log_debug "exiting install_docker - success"
	return 0
}

setup_clipboard_manager() {
	log_section "setting up Rofi Clipboard Manager"
	log_debug "entering setup_clipboard_manager function"
	
	# Check if rofi is installed
	if ! command -v rofi >/dev/null 2>&1; then
		log_error "rofi is not installed. Please install rofi first"
		return 1
	fi
	
	# Check if xclip is installed
	if ! command -v xclip >/dev/null 2>&1; then
		log_info "xclip not found, installing..."
		sudo apt-get update && sudo apt-get install -y xclip
	fi
	
	# Optional: Install xdotool for auto-typing feature
	if ! command -v xdotool >/dev/null 2>&1; then
		log_info "Installing xdotool for auto-type feature (optional)"
		sudo apt-get install -y xdotool || log_warning "xdotool installation failed, auto-type feature won't be available"
	fi
	
	# Create clipboard data directory
	local clipboard_dir="${XDG_DATA_HOME:-$HOME/.local/share}/rofi-clipboard"
	if [[ ! -d "$clipboard_dir" ]]; then
		log_info "Creating clipboard data directory at $clipboard_dir"
		mkdir -p "$clipboard_dir"
	fi
	
	# Check if systemd user directory exists
	local systemd_user_dir="$HOME/.config/systemd/user"
	if [[ ! -d "$systemd_user_dir" ]]; then
		log_info "Creating systemd user directory"
		mkdir -p "$systemd_user_dir"
	fi
	
	# Enable and start the clipboard monitor service
	if [[ -f "$systemd_user_dir/rofi-clipboard.service" ]]; then
		log_info "Enabling rofi-clipboard service"
		systemctl --user daemon-reload
		systemctl --user enable rofi-clipboard.service
		systemctl --user restart rofi-clipboard.service || log_warning "Failed to start service, you can start it manually later"
		
		# Check service status
		if systemctl --user is-active rofi-clipboard.service >/dev/null 2>&1; then
			log_info "Rofi clipboard monitor service is running"
		else
			log_warning "Service is not running. Start it manually with: systemctl --user start rofi-clipboard.service"
		fi
	else
		log_warning "Service file not found at $systemd_user_dir/rofi-clipboard.service"
		log_info "The clipboard monitor won't start automatically. Run 'rofi-clipboard --monitor' manually"
	fi
	
	log_info "Rofi Clipboard Manager setup complete"
	log_info "Usage: rofi-clipboard (or use keyboard shortcut once configured)"
	log_info "Monitor: rofi-clipboard --monitor (or use systemd service)"
	
	log_debug "exiting setup_clipboard_manager - success"
	return 0
}

install_custom_apps() {
	log_header "installing custom applications"
	
	local custom_apps_json
	custom_apps_json=$(get_from_config "custom-apps" "array") || {
		log_info "no custom apps configured in config.json"
		return 0
	}
	
	if [[ -z "$custom_apps_json" ]] || [[ "$custom_apps_json" == "[]" ]]; then
		log_info "no custom apps to install"
		return 0
	fi
	
	local app_count=$(echo "$custom_apps_json" | jq 'length')
	for ((i=0; i<$app_count; i++)); do
		local app=$(echo "$custom_apps_json" | jq -r ".[$i]")
		
		case "$app" in
			"cursor")
				install_cursor
				;;
			*)
				log_warning "unknown custom app: $app"
				;;
		esac
	done
	
	log_info "custom apps installation complete"
	return 0
}

install_cursor() {
	log_header "installing Cursor AI IDE"
	
	# Check if already installed
	if [[ -d "/opt/Cursor" ]] && [[ -f "/opt/Cursor/AppRun" ]]; then
		log_info "Cursor is already installed at /opt/Cursor"
		log_info "to update, run: update_cursor"
		return 0
	fi
	
	# Check Ubuntu version compatibility
	local ubuntu_version=$(lsb_release -r 2>/dev/null | cut -f2)
	if [[ "$ubuntu_version" != "24.04" ]]; then
		log_warning "this installer is optimized for Ubuntu 24.04 (current: $ubuntu_version)"
		log_info "installation will continue but may require adjustments"
	fi
	
	# Install dependencies
	log_info "checking dependencies"
	local deps=("curl" "jq" "wget")
	for dep in "${deps[@]}"; do
		if ! command -v "$dep" &>/dev/null; then
			log_info "installing $dep"
			sudo apt-get update
			sudo apt-get install -y "$dep"
		fi
	done
	
	# Download latest Cursor AppImage
	log_info "downloading latest Cursor AppImage"
	local api_url="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
	local user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
	local download_path="/tmp/cursor-latest.AppImage"
	
	# Get download URL from API
	local final_url=$(curl -sL -A "$user_agent" "$api_url" | jq -r '.url // .downloadUrl')
	if [[ -z "$final_url" ]] || [[ "$final_url" == "null" ]]; then
		log_error "could not retrieve Cursor download URL from API"
		log_info "please download manually from https://cursor.sh and provide the path"
		read -rp "Enter path to downloaded Cursor AppImage: " download_path
		if [[ ! -f "$download_path" ]] || [[ ! "$download_path" =~ \.AppImage$ ]]; then
			log_error "invalid AppImage file: $download_path"
			return 1
		fi
	else
		log_info "downloading from: $final_url"
		if ! wget -q -O "$download_path" "$final_url"; then
			log_error "failed to download Cursor AppImage"
			return 1
		fi
	fi
	
	# Make AppImage executable
	chmod +x "$download_path"
	
	# Extract AppImage
	log_info "extracting AppImage"
	(cd /tmp && "$download_path" --appimage-extract >/dev/null 2>&1)
	if [[ ! -d "/tmp/squashfs-root" ]]; then
		log_error "failed to extract AppImage"
		rm -f "$download_path"
		return 1
	fi
	
	# Create installation directory
	log_info "installing to /opt/Cursor"
	sudo mkdir -p /opt/Cursor
	
	# Move extracted files
	sudo rsync -a --remove-source-files /tmp/squashfs-root/ /opt/Cursor/
	
	# Set permissions
	log_info "setting permissions"
	sudo chmod -R 755 /opt/Cursor
	sudo chmod +x /opt/Cursor/AppRun
	
	# Download icon
	log_info "downloading Cursor icon"
	local icon_url="https://raw.githubusercontent.com/hieutt192/Cursor-ubuntu/Cursor-ubuntu24.04/images/cursor-icon.png"
	sudo curl -sL "$icon_url" -o /opt/Cursor/cursor-icon.png
	
	# Create desktop entry
	log_info "creating desktop entry"
	sudo tee /usr/share/applications/cursor.desktop >/dev/null <<-EOF
	[Desktop Entry]
	Name=Cursor
	Comment=AI-powered Code Editor
	Exec=/opt/Cursor/AppRun --no-sandbox %F
	Icon=/opt/Cursor/cursor-icon.png
	Type=Application
	Categories=Development;IDE;TextEditor;
	MimeType=text/plain;inode/directory;
	Actions=new-window;
	StartupWMClass=Cursor
	
	[Desktop Action new-window]
	Name=New Window
	Exec=/opt/Cursor/AppRun --no-sandbox --new-window %F
	EOF
	
	# Set desktop entry permissions
	sudo chmod 644 /usr/share/applications/cursor.desktop
	
	# Clean up
	rm -f "$download_path"
	rm -rf /tmp/squashfs-root
	
	# Update desktop database
	if command -v update-desktop-database &>/dev/null; then
		sudo update-desktop-database /usr/share/applications/ 2>/dev/null || true
	fi
	
	log_info "Cursor AI IDE installation complete!"
	log_info "you can launch Cursor from the applications menu or run: /opt/Cursor/AppRun"
	
	return 0
}

update_cursor() {
	log_header "updating Cursor AI IDE"
	
	if [[ ! -d "/opt/Cursor" ]] || [[ ! -f "/opt/Cursor/AppRun" ]]; then
		log_warning "Cursor is not installed, installing now"
		install_cursor
		return $?
	fi
	
	# Backup existing icons
	log_info "backing up custom icons"
	local icon_backup_dir="/tmp/cursor_icon_backup_$$"
	mkdir -p "$icon_backup_dir"
	for icon_file in cursor-icon.png cursor-black-icon.png; do
		if [[ -f "/opt/Cursor/$icon_file" ]]; then
			cp "/opt/Cursor/$icon_file" "$icon_backup_dir/"
		fi
	done
	
	# Download latest Cursor AppImage
	log_info "downloading latest Cursor AppImage"
	local api_url="https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
	local user_agent="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
	local download_path="/tmp/cursor-update.AppImage"
	
	# Get download URL from API
	local final_url=$(curl -sL -A "$user_agent" "$api_url" | jq -r '.url // .downloadUrl')
	if [[ -z "$final_url" ]] || [[ "$final_url" == "null" ]]; then
		log_error "could not retrieve Cursor download URL from API"
		return 1
	fi
	
	log_info "downloading from: $final_url"
	if ! wget -q -O "$download_path" "$final_url"; then
		log_error "failed to download Cursor AppImage"
		return 1
	fi
	
	# Make AppImage executable
	chmod +x "$download_path"
	
	# Extract AppImage
	log_info "extracting new version"
	(cd /tmp && "$download_path" --appimage-extract >/dev/null 2>&1)
	if [[ ! -d "/tmp/squashfs-root" ]]; then
		log_error "failed to extract AppImage"
		rm -f "$download_path"
		return 1
	fi
	
	# Remove old version (except configs)
	log_info "removing old version"
	sudo rm -rf /opt/Cursor/*
	
	# Deploy new version
	log_info "deploying new version"
	sudo rsync -a --remove-source-files /tmp/squashfs-root/ /opt/Cursor/
	
	# Restore icons
	log_info "restoring custom icons"
	for icon_file in cursor-icon.png cursor-black-icon.png; do
		if [[ -f "$icon_backup_dir/$icon_file" ]]; then
			sudo mv "$icon_backup_dir/$icon_file" "/opt/Cursor/$icon_file"
		fi
	done
	rm -rf "$icon_backup_dir"
	
	# Set permissions
	log_info "setting permissions"
	sudo chmod -R 755 /opt/Cursor
	sudo chmod +x /opt/Cursor/AppRun
	
	# Clean up
	rm -f "$download_path"
	rm -rf /tmp/squashfs-root
	
	log_info "Cursor AI IDE update complete!"
	
	return 0
}
