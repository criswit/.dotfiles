#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/../config.json"

source "${SCRIPT_DIR}/logger.sh"
source "${SCRIPT_DIR}/installer_functions.sh"

# Setup all enabled services
setup_all_services() {
	log_section "setting up services"
	log_debug "entering setup_all_services function"
	
	# Check if jq is available
	if ! command -v jq >/dev/null 2>&1; then
		log_warn "jq is not installed - cannot parse service configuration"
		return 0
	fi
	
	# Setup Jellyfin if enabled
	local jellyfin_enabled
	jellyfin_enabled=$(jq -r '.services.jellyfin.enabled // false' "$CONFIG_FILE" 2>/dev/null) || jellyfin_enabled="false"
	
	if [[ "$jellyfin_enabled" == "true" ]]; then
		log_info "jellyfin service is enabled in config"
		setup_jellyfin
	else
		log_info "jellyfin service is disabled in config"
	fi
	
	log_debug "exiting setup_all_services"
	return 0
}

# Setup Jellyfin media server
setup_jellyfin() {
	log_section "setting up jellyfin"
	log_debug "entering setup_jellyfin function"
	
	# Check if Jellyfin is installed (check for either package or service)
	if ! dpkg -l jellyfin-server 2>/dev/null | grep -q "^ii"; then
		if ! systemctl list-unit-files 2>/dev/null | grep -q "jellyfin.service"; then
			log_error "Jellyfin is not installed. Please run the install script to install it from external repos"
			return 1
		fi
	fi
	
	log_info "configuring Jellyfin service"
	
	# Get configuration from config.json
	local auto_start media_dirs
	auto_start=$(jq -r '.services.jellyfin.auto_start // true' "$CONFIG_FILE" 2>/dev/null) || auto_start="true"
	media_dirs=$(jq -r '.services.jellyfin.system.media_dirs[]?' "$CONFIG_FILE" 2>/dev/null) || media_dirs=""
	
	# Create media directories if they don't exist
	if [[ -n "$media_dirs" ]]; then
		log_info "creating media directories"
		while IFS= read -r dir; do
			if [[ -n "$dir" ]]; then
				# Expand ~ to home directory
				dir="${dir/#\~/$HOME}"
				if [[ ! -d "$dir" ]]; then
					log_info "creating directory: $dir"
					mkdir -p "$dir"
					# Set permissions for jellyfin user (if it exists)
					if id "jellyfin" &>/dev/null; then
						sudo chown -R jellyfin:jellyfin "$dir" 2>/dev/null || true
						sudo chmod -R 755 "$dir"
					fi
				else
					log_info "directory already exists: $dir"
				fi
			fi
		done <<< "$media_dirs"
	fi
	
	# Add current user to jellyfin group for media access
	if getent group jellyfin >/dev/null 2>&1; then
		if ! groups "$USER" | grep -q '\bjellyfin\b'; then
			log_info "adding user $USER to jellyfin group"
			sudo usermod -aG jellyfin "$USER"
			log_info "user added to jellyfin group - you may need to log out and back in"
		else
			log_info "user $USER is already in jellyfin group"
		fi
	fi
	
	# Enable/disable auto-start based on configuration
	if [[ "$auto_start" == "true" ]]; then
		log_info "enabling Jellyfin to start on boot"
		sudo systemctl enable jellyfin.service 2>/dev/null || true
		
		# Start the service if not running
		if ! systemctl is-active --quiet jellyfin; then
			log_info "starting Jellyfin service"
			sudo systemctl start jellyfin.service
		else
			log_info "Jellyfin service is already running"
		fi
	else
		log_info "auto-start is disabled for Jellyfin"
		sudo systemctl disable jellyfin.service 2>/dev/null || true
	fi
	
	# Get configured port
	local port
	port=$(jq -r '.services.jellyfin.system.port // 8096' "$CONFIG_FILE" 2>/dev/null) || port="8096"
	
	# Wait for service to be ready
	log_info "waiting for Jellyfin to be ready..."
	local counter=0
	while [ $counter -lt 30 ]; do
		if curl -s "http://localhost:$port/health" >/dev/null 2>&1; then
			log_info "Jellyfin is ready and accessible at http://localhost:$port"
			break
		fi
		sleep 1
		counter=$((counter + 1))
	done
	
	if [ $counter -eq 30 ]; then
		log_warn "Jellyfin may not be fully ready yet. Please check http://localhost:$port"
	fi
	
	log_info "Jellyfin setup complete"
	log_debug "exiting setup_jellyfin"
	return 0
}

# Manage systemd service
manage_systemd_service() {
	local action="$1"
	local service="$2"
	
	log_info "performing systemd action: $action on $service"
	
	case "$action" in
		start|stop|restart|status|enable|disable)
			sudo systemctl "$action" "$service"
			;;
		*)
			log_error "unknown systemd action: $action"
			return 1
			;;
	esac
	
	return 0
}

# Verify service health
verify_service_health() {
	local service="$1"
	local port="${2:-}"
	
	log_info "verifying health of service: $service"
	
	# Check if service is running
	if systemctl is-active --quiet "$service"; then
		log_info "service $service is running"
		
		# Check port if provided
		if [[ -n "$port" ]]; then
			if netstat -tln | grep -q ":$port "; then
				log_info "service is listening on port $port"
			else
				log_warn "service is not listening on expected port $port"
			fi
		fi
		
		return 0
	else
		log_error "service $service is not running"
		return 1
	fi
}