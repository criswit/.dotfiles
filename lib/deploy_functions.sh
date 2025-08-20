#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
FILES_DIR="${DOTFILES_ROOT}/files"
COPY_MAP_FILE="${FILES_DIR}/copy/copy.map"
TEMPLATE_MAP_FILE="${FILES_DIR}/templates/templates.map"

source "${SCRIPT_DIR}/logger.sh"

# Deploy all stow packages
deploy_stow_packages() {
	log_section "deploying stow packages"
	
	local stow_dir="${FILES_DIR}/stow"
	
	if [[ ! -d "$stow_dir" ]]; then
		log_warn "stow directory not found: $stow_dir"
		return 0
	fi
	
	# Check if stow is installed
	if ! command -v stow >/dev/null 2>&1; then
		log_error "stow is not installed - cannot deploy packages"
		return 1
	fi
	
	# Get list of packages
	local packages=()
	for package_dir in "$stow_dir"/*; do
		[[ -d "$package_dir" ]] || continue
		packages+=("$(basename "$package_dir")")
	done
	
	if [[ ${#packages[@]} -eq 0 ]]; then
		log_info "no stow packages found"
		return 0
	fi
	
	log_info "found ${#packages[@]} stow packages: ${packages[*]}"
	
	# Deploy each package
	local failed_packages=()
	local deployed_count=0
	
	cd "$stow_dir"
	for package in "${packages[@]}"; do
		log_info "deploying stow package: $package"
		
		if stow -v -t "$HOME" "$package"; then
			log_info "successfully deployed: $package"
			((deployed_count++))
		else
			log_error "failed to deploy: $package"
			failed_packages+=("$package")
		fi
	done
	
	# Report results
	log_info "deployment summary: $deployed_count/${#packages[@]} packages deployed"
	
	if [[ ${#failed_packages[@]} -gt 0 ]]; then
		log_error "failed packages: ${failed_packages[*]}"
		return 1
	fi
	
	return 0
}

# Deploy a single stow package
deploy_stow_package() {
	local package="$1"
	
	if [[ -z "$package" ]]; then
		log_error "package name is required"
		return 1
	fi
	
	local stow_dir="${FILES_DIR}/stow"
	local package_dir="${stow_dir}/${package}"
	
	if [[ ! -d "$package_dir" ]]; then
		log_error "package directory not found: $package_dir"
		return 1
	fi
	
	log_info "deploying stow package: $package"
	
	cd "$stow_dir"
	if stow -v -t "$HOME" "$package"; then
		log_info "successfully deployed: $package"
		return 0
	else
		log_error "failed to deploy: $package"
		return 1
	fi
}

# Remove a stow package
remove_stow_package() {
	local package="$1"
	
	if [[ -z "$package" ]]; then
		log_error "package name is required"
		return 1
	fi
	
	local stow_dir="${FILES_DIR}/stow"
	
	log_info "removing stow package: $package"
	
	cd "$stow_dir"
	if stow -v -D -t "$HOME" "$package"; then
		log_info "successfully removed: $package"
		return 0
	else
		log_error "failed to remove: $package"
		return 1
	fi
}

# Deploy files using copy mapping
deploy_copy_files() {
	log_section "deploying copy files"
	
	local copy_dir="${FILES_DIR}/copy"
	local map_file="${copy_dir}/copy.map"
	
	if [[ ! -d "$copy_dir" ]]; then
		log_warn "copy directory not found: $copy_dir"
		return 0
	fi
	
	if [[ ! -f "$map_file" ]]; then
		log_info "no copy.map file found - skipping copy deployment"
		return 0
	fi
	
	local line_count=0
	local success_count=0
	local failed_files=()
	
	while IFS=: read -r source dest perms; do
		# Skip empty lines and comments
		[[ -z "$source" ]] && continue
		[[ "$source" =~ ^[[:space:]]*# ]] && continue
		
		((line_count++))
		
		# Expand tilde in destination
		dest="${dest/#\~/$HOME}"
		
		local source_path="${copy_dir}/${source}"
		
		# Check if source exists
		if [[ ! -e "$source_path" ]]; then
			log_error "source not found: $source_path"
			failed_files+=("$source")
			continue
		fi
		
		# Create destination directory if needed
		local dest_dir
		dest_dir="$(dirname "$dest")"
		if [[ ! -d "$dest_dir" ]]; then
			log_info "creating directory: $dest_dir"
			mkdir -p "$dest_dir"
		fi
		
		# Check if destination requires sudo
		local use_sudo=""
		if [[ "$dest" == /etc/* ]] || [[ "$dest" == /usr/* ]] || [[ "$dest" == /opt/* ]]; then
			use_sudo="sudo"
			log_info "system directory detected - using sudo"
		fi
		
		# Backup existing file if it exists
		if [[ -e "$dest" ]]; then
			# Create .backups directory in the destination directory
			local backup_dir="${dest_dir}/.backups"
			if [[ ! -d "$backup_dir" ]]; then
				log_info "creating backup directory: $backup_dir"
				$use_sudo mkdir -p "$backup_dir"
			fi
			
			local backup_filename="$(basename "$dest").backup.$(date +%Y%m%d_%H%M%S)"
			local backup_path="${backup_dir}/${backup_filename}"
			log_info "backing up existing file to: $backup_path"
			$use_sudo cp -a "$dest" "$backup_path"
		fi
		
		# Copy file(s)
		log_info "copying: $source → $dest"
		if $use_sudo cp -r "$source_path" "$dest"; then
			# Set permissions if specified
			if [[ -n "$perms" ]]; then
				log_info "setting permissions: $perms on $dest"
				$use_sudo chmod "$perms" "$dest"
			fi
			((success_count++))
		else
			log_error "failed to copy: $source"
			failed_files+=("$source")
		fi
	done < "$map_file"
	
	log_info "copy summary: $success_count/$line_count files deployed"
	
	if [[ ${#failed_files[@]} -gt 0 ]]; then
		log_error "failed files: ${failed_files[*]}"
		return 1
	fi
	
	return 0
}

# Deploy template files with variable substitution
deploy_templates() {
	log_section "deploying template files"
	
	local templates_dir="${FILES_DIR}/templates"
	local map_file="${templates_dir}/templates.map"
	
	if [[ ! -d "$templates_dir" ]]; then
		log_warn "templates directory not found: $templates_dir"
		return 0
	fi
	
	if [[ ! -f "$map_file" ]]; then
		log_info "no templates.map file found - skipping template deployment"
		return 0
	fi
	
	local line_count=0
	local success_count=0
	local failed_templates=()
	
	while IFS=: read -r template dest vars; do
		# Skip empty lines and comments
		[[ -z "$template" ]] && continue
		[[ "$template" =~ ^[[:space:]]*# ]] && continue
		
		((line_count++))
		
		# Expand tilde in destination
		dest="${dest/#\~/$HOME}"
		
		local template_path="${templates_dir}/${template}"
		
		# Check if template exists
		if [[ ! -f "$template_path" ]]; then
			log_error "template not found: $template_path"
			failed_templates+=("$template")
			continue
		fi
		
		# Create destination directory if needed
		local dest_dir
		dest_dir="$(dirname "$dest")"
		if [[ ! -d "$dest_dir" ]]; then
			log_info "creating directory: $dest_dir"
			mkdir -p "$dest_dir"
		fi
		
		# Check if destination requires sudo
		local use_sudo=""
		if [[ "$dest" == /etc/* ]] || [[ "$dest" == /usr/* ]] || [[ "$dest" == /opt/* ]]; then
			use_sudo="sudo"
			log_info "system directory detected - using sudo"
		fi
		
		# Backup existing file if it exists
		if [[ -f "$dest" ]]; then
			# Create .backups directory in the destination directory
			local backup_dir="${dest_dir}/.backups"
			if [[ ! -d "$backup_dir" ]]; then
				log_info "creating backup directory: $backup_dir"
				$use_sudo mkdir -p "$backup_dir"
			fi
			
			local backup_filename="$(basename "$dest").backup.$(date +%Y%m%d_%H%M%S)"
			local backup_path="${backup_dir}/${backup_filename}"
			log_info "backing up existing file to: $backup_path"
			$use_sudo cp "$dest" "$backup_path"
		fi
		
		# Process template
		log_info "processing template: $template → $dest"
		local content
		content=$(<"$template_path")
		
		# Replace variables
		if [[ -n "$vars" ]]; then
			IFS=',' read -ra var_pairs <<< "$vars"
			for var_pair in "${var_pairs[@]}"; do
				IFS='=' read -r var_name var_value <<< "$var_pair"
				log_info "  replacing {{$var_name}} with $var_value"
				content="${content//\{\{$var_name\}\}/$var_value}"
			done
		fi
		
		# Write processed content
		if [[ -n "$use_sudo" ]]; then
			if echo "$content" | $use_sudo tee "$dest" > /dev/null; then
				log_info "successfully deployed template: $template"
				((success_count++))
			else
				log_error "failed to deploy template: $template"
				failed_templates+=("$template")
			fi
		else
			if echo "$content" > "$dest"; then
				log_info "successfully deployed template: $template"
				((success_count++))
			else
				log_error "failed to deploy template: $template"
				failed_templates+=("$template")
			fi
		fi
	done < "$map_file"
	
	log_info "template summary: $success_count/$line_count templates deployed"
	
	if [[ ${#failed_templates[@]} -gt 0 ]]; then
		log_error "failed templates: ${failed_templates[*]}"
		return 1
	fi
	
	return 0
}

# Check if system files need deployment
check_system_files_needed() {
	local needs_sudo=false
	
	# Check copy.map for system destinations
	if [[ -f "$COPY_MAP_FILE" ]]; then
		while IFS=: read -r source dest perms; do
			[[ -z "$source" || "$source" == \#* ]] && continue
			dest="${dest/#\~/$HOME}"
			if [[ "$dest" == /etc/* ]] || [[ "$dest" == /usr/* ]] || [[ "$dest" == /opt/* ]]; then
				needs_sudo=true
				break
			fi
		done < "$COPY_MAP_FILE"
	fi
	
	# Check templates.map for system destinations
	if [[ ! "$needs_sudo" == true && -f "$TEMPLATE_MAP_FILE" ]]; then
		while IFS=: read -r template dest vars; do
			[[ -z "$template" || "$template" == \#* ]] && continue
			dest="${dest/#\~/$HOME}"
			if [[ "$dest" == /etc/* ]] || [[ "$dest" == /usr/* ]] || [[ "$dest" == /opt/* ]]; then
				needs_sudo=true
				break
			fi
		done < "$TEMPLATE_MAP_FILE"
	fi
	
	echo "$needs_sudo"
}

# Deploy system files with sudo
deploy_system_files() {
	log_header "deploying system files (requires sudo)"
	
	# Run the deployment functions with sudo
	sudo bash -c "
		source '$DOTFILES_DIR/lib/logger.sh'
		source '$DOTFILES_DIR/lib/deploy_functions.sh'
		deploy_copy_files
		deploy_templates
	"
}

# Deploy all files (stow, copy, and templates)
deploy_all() {
	log_header "deploying all dotfiles"
	
	local overall_success=true
	
	# Deploy stow packages (no sudo needed)
	if ! deploy_stow_packages; then
		overall_success=false
	fi
	
	# Check if system files need deployment
	if [[ "$(check_system_files_needed)" == "true" ]]; then
		log_info "system files detected - will require sudo for deployment"
		if ! deploy_system_files; then
			overall_success=false
		fi
	else
		# Deploy copy files
		if ! deploy_copy_files; then
			overall_success=false
		fi
		
		# Deploy templates
		if ! deploy_templates; then
			overall_success=false
		fi
	fi
	
	if [[ "$overall_success" == true ]]; then
		log_info "all deployments completed successfully"
		return 0
	else
		log_error "some deployments failed - check logs above"
		return 1
	fi
}