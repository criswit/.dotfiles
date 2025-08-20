#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logger.sh"
source "${SCRIPT_DIR}/installer_functions.sh"

configure_gnome_dark_mode() {
	log_section "configuring GNOME dark mode"
	
	# Check if running GNOME
	if [[ ! "$XDG_CURRENT_DESKTOP" =~ GNOME ]] && [[ ! "$DESKTOP_SESSION" =~ gnome ]]; then
		log_warn "not running GNOME desktop, skipping"
		return 0
	fi
	
	# Get dark mode setting from config
	local dark_mode
	dark_mode=$(get_from_config "gnome-settings.appearance.dark-mode") || {
		log_info "no dark mode setting in config, skipping"
		return 0
	}
	
	if [[ "$dark_mode" == "true" ]]; then
		log_info "enabling dark mode"
		gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
		gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
		log_info "dark mode enabled"
	else
		log_info "setting light mode"
		gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
		gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
		log_info "light mode set"
	fi
	
	return 0
}

configure_gnome_wallpaper() {
	log_section "configuring GNOME wallpaper"
	
	# Check if running GNOME
	if [[ ! "$XDG_CURRENT_DESKTOP" =~ GNOME ]] && [[ ! "$DESKTOP_SESSION" =~ gnome ]]; then
		log_warn "not running GNOME desktop, skipping"
		return 0
	fi
	
	# Get wallpaper path from config
	local wallpaper_path
	wallpaper_path=$(get_from_config "gnome-settings.appearance.wallpaper") || {
		log_info "no wallpaper path in config, skipping"
		return 0
	}
	
	# Expand ~ to home directory
	wallpaper_path="${wallpaper_path/#\~/$HOME}"
	
	# Check if wallpaper file exists
	if [[ ! -f "$wallpaper_path" ]]; then
		log_warn "wallpaper file not found: $wallpaper_path"
		return 1
	fi
	
	# Convert to absolute path
	wallpaper_path=$(realpath "$wallpaper_path")
	
	log_info "setting wallpaper to: $wallpaper_path"
	gsettings set org.gnome.desktop.background picture-uri "file://${wallpaper_path}"
	gsettings set org.gnome.desktop.background picture-uri-dark "file://${wallpaper_path}"
	
	# Set wallpaper options
	local wallpaper_mode
	wallpaper_mode=$(get_from_config "gnome-settings.appearance.wallpaper-mode") || wallpaper_mode="zoom"
	gsettings set org.gnome.desktop.background picture-options "$wallpaper_mode"
	
	log_info "wallpaper configured"
	return 0
}

configure_gnome_keyboard_shortcuts() {
	log_section "configuring GNOME keyboard shortcuts"
	
	# Check if running GNOME
	if [[ ! "$XDG_CURRENT_DESKTOP" =~ GNOME ]] && [[ ! "$DESKTOP_SESSION" =~ gnome ]]; then
		log_warn "not running GNOME desktop, skipping"
		return 0
	fi
	
	# Temporarily disable errexit for this function to prevent script termination
	local errexit_state=$(set +o | grep errexit)
	set +e
	
	# Disable conflicting system shortcuts first
	log_info "disabling conflicting system shortcuts"
	
	# Disable Super+L screensaver lock (we use it for custom lock)
	gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "[]"
	
	# Get custom shortcuts from config
	local shortcuts_json
	shortcuts_json=$(get_from_config "gnome-settings.keyboard-shortcuts" "array") || {
		log_info "no keyboard shortcuts in config, skipping"
		return 0
	}
	
	if [[ -z "$shortcuts_json" ]] || [[ "$shortcuts_json" == "[]" ]]; then
		log_info "no keyboard shortcuts configured"
		return 0
	fi
	
	# Clear all existing custom shortcuts first
	log_info "clearing existing custom shortcuts"
	gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[]"
	
	# Build array of custom shortcuts
	local custom_shortcuts_array="["
	local custom_index=0
	
	# Process shortcuts
	local shortcut_count=$(echo "$shortcuts_json" | jq 'length')
	for ((i=0; i<$shortcut_count; i++)); do
		local shortcut=$(echo "$shortcuts_json" | jq -r ".[$i]")
		local name=$(echo "$shortcut" | jq -r '.name')
		local binding=$(echo "$shortcut" | jq -r '.binding')
		local command=$(echo "$shortcut" | jq -r '.command // empty')
		local action=$(echo "$shortcut" | jq -r '.action // empty')
		
		if [[ -n "$action" ]]; then
			# Built-in action shortcut
			log_info "setting shortcut for $name: $binding -> $action"
			
			# Map common actions to their gsettings paths
			case "$action" in
				"terminal")
					gsettings set org.gnome.desktop.default-applications.terminal exec "$command"
					gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['$binding']"
					;;
				"screenshot")
					gsettings set org.gnome.shell.keybindings screenshot "['$binding']"
					;;
				"screenshot-window")
					gsettings set org.gnome.shell.keybindings screenshot-window "['$binding']"
					;;
				"home")
					gsettings set org.gnome.settings-daemon.plugins.media-keys home "['$binding']"
					;;
				"www")
					gsettings set org.gnome.settings-daemon.plugins.media-keys www "['$binding']"
					;;
				"email")
					gsettings set org.gnome.settings-daemon.plugins.media-keys email "['$binding']"
					;;
				*)
					log_warn "unknown action: $action"
					;;
			esac
		elif [[ -n "$command" ]]; then
			# Custom command shortcut
			log_info "setting custom shortcut for $name: $binding -> $command"
			
			# Create custom shortcut
			local custom_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
			local shortcut_id="custom${custom_index}"
			local shortcut_path="${custom_path}/${shortcut_id}/"
			
			# Add to custom shortcuts array
			if [[ $custom_index -gt 0 ]]; then
				custom_shortcuts_array="${custom_shortcuts_array}, '${shortcut_path}'"
			else
				custom_shortcuts_array="${custom_shortcuts_array}'${shortcut_path}'"
			fi
			
			# Set the custom shortcut properties - use gsettings with proper schema path
			local schema_path="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
			
			# Try gsettings first, fall back to dconf, always return success
			if ! gsettings set ${schema_path}:${shortcut_path} name "$name" 2>/dev/null; then
				log_debug "Failed to set name via gsettings for $name, trying dconf"
				dconf write ${shortcut_path}name "'$name'" 2>/dev/null || true
			fi
			
			if ! gsettings set ${schema_path}:${shortcut_path} command "$command" 2>/dev/null; then
				log_debug "Failed to set command via gsettings for $name, trying dconf"
				dconf write ${shortcut_path}command "'$command'" 2>/dev/null || true
			fi
			
			if ! gsettings set ${schema_path}:${shortcut_path} binding "$binding" 2>/dev/null; then
				log_debug "Failed to set binding via gsettings for $name, trying dconf"
				dconf write ${shortcut_path}binding "'$binding'" 2>/dev/null || true
			fi
			
			((custom_index++))
		fi
	done
	
	# Apply all custom shortcuts at once
	custom_shortcuts_array="${custom_shortcuts_array}]"
	if [[ "$custom_shortcuts_array" != "[]" ]]; then
		log_info "applying custom shortcuts: $custom_shortcuts_array"
		gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "$custom_shortcuts_array"
	fi
	
	log_info "keyboard shortcuts configured"
	
	# Restore errexit state
	eval "$errexit_state"
	
	return 0
}

configure_gnome_dock() {
	log_section "configuring GNOME dock/dash"
	
	# Check if running GNOME
	if [[ ! "$XDG_CURRENT_DESKTOP" =~ GNOME ]] && [[ ! "$DESKTOP_SESSION" =~ gnome ]]; then
		log_warn "not running GNOME desktop, skipping"
		return 0
	fi
	
	# Check if dash-to-dock extension is installed
	if ! gnome-extensions list 2>/dev/null | grep -q "dash-to-dock@micxgx.gmail.com"; then
		log_info "dash-to-dock extension not installed, using default Ubuntu dock"
		local dock_schema="org.gnome.shell.extensions.dash-to-dock"
		
		# Check if Ubuntu dock schema exists
		if ! gsettings list-schemas | grep -q "$dock_schema"; then
			dock_schema="org.gnome.shell.extensions.ubuntu-dock"
			if ! gsettings list-schemas | grep -q "$dock_schema"; then
				log_warn "no dock extension found, skipping dock configuration"
				return 0
			fi
		fi
	else
		local dock_schema="org.gnome.shell.extensions.dash-to-dock"
	fi
	
	# Get dock apps from config
	local dock_apps_json
	dock_apps_json=$(get_from_config "gnome-settings.dock.favorite-apps" "array") || {
		log_info "no dock apps in config, skipping"
		return 0
	}
	
	if [[ -z "$dock_apps_json" ]] || [[ "$dock_apps_json" == "[]" ]]; then
		log_info "no dock apps configured"
		return 0
	fi
	
	# Convert JSON array to gsettings format
	local apps_array=""
	local app_count=$(echo "$dock_apps_json" | jq 'length')
	for ((i=0; i<$app_count; i++)); do
		local app=$(echo "$dock_apps_json" | jq -r ".[$i]")
		# Ensure .desktop extension
		if [[ ! "$app" =~ \.desktop$ ]]; then
			app="${app}.desktop"
		fi
		if [[ -n "$apps_array" ]]; then
			apps_array="${apps_array}, '${app}'"
		else
			apps_array="'${app}'"
		fi
	done
	
	log_info "setting dock favorite apps"
	gsettings set org.gnome.shell favorite-apps "[${apps_array}]"
	
	# Configure dock behavior from config
	local dock_position
	dock_position=$(get_from_config "gnome-settings.dock.position") || dock_position="LEFT"
	gsettings set ${dock_schema} dock-position "$dock_position" 2>/dev/null || true
	
	# Hide removable drives/USB sticks from dock
	local show_mounts
	show_mounts=$(get_from_config "gnome-settings.dock.show-mounts") || show_mounts="false"
	if [[ "$show_mounts" == "false" ]]; then
		gsettings set ${dock_schema} show-mounts false 2>/dev/null || true
		gsettings set ${dock_schema} show-mounts-only-mounted false 2>/dev/null || true
		log_info "removable drives hidden from dock"
	else
		gsettings set ${dock_schema} show-mounts true 2>/dev/null || true
	fi
	
	local dock_size
	dock_size=$(get_from_config "gnome-settings.dock.icon-size") || dock_size="48"
	gsettings set ${dock_schema} dash-max-icon-size "$dock_size" 2>/dev/null || true
	
	local auto_hide
	auto_hide=$(get_from_config "gnome-settings.dock.auto-hide") || auto_hide="false"
	if [[ "$auto_hide" == "true" ]]; then
		gsettings set ${dock_schema} dock-fixed false 2>/dev/null || true
		gsettings set ${dock_schema} autohide true 2>/dev/null || true
	else
		gsettings set ${dock_schema} dock-fixed true 2>/dev/null || true
		gsettings set ${dock_schema} autohide false 2>/dev/null || true
	fi
	
	log_info "dock configured"
	return 0
}

configure_gnome_misc() {
	log_section "configuring miscellaneous GNOME settings"
	
	# Check if running GNOME
	if [[ ! "$XDG_CURRENT_DESKTOP" =~ GNOME ]] && [[ ! "$DESKTOP_SESSION" =~ gnome ]]; then
		log_warn "not running GNOME desktop, skipping"
		return 0
	fi
	
	# Show battery percentage
	local show_battery
	show_battery=$(get_from_config "gnome-settings.misc.show-battery-percentage") || show_battery="true"
	if [[ "$show_battery" == "true" ]]; then
		gsettings set org.gnome.desktop.interface show-battery-percentage true
		log_info "battery percentage enabled"
	fi
	
	# Disable Super+P for display switching to allow custom keybinding
	log_info "disabling Super+P system keybinding for display switching"
	gsettings set org.gnome.mutter.keybindings switch-monitor "['XF86Display']"
	
	# Enable night light
	local night_light
	night_light=$(get_from_config "gnome-settings.misc.night-light") || night_light="false"
	if [[ "$night_light" == "true" ]]; then
		gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
		log_info "night light enabled"
		
		# Set night light schedule
		local night_start
		night_start=$(get_from_config "gnome-settings.misc.night-light-start") || night_start="20.0"
		local night_end
		night_end=$(get_from_config "gnome-settings.misc.night-light-end") || night_end="6.0"
		
		gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from "$night_start"
		gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to "$night_end"
	fi
	
	# Set font scaling
	local font_scale
	font_scale=$(get_from_config "gnome-settings.misc.text-scaling-factor") || font_scale="1.0"
	gsettings set org.gnome.desktop.interface text-scaling-factor "$font_scale"
	
	# Enable minimize/maximize buttons
	local window_buttons
	window_buttons=$(get_from_config "gnome-settings.misc.show-minimize-maximize") || window_buttons="true"
	if [[ "$window_buttons" == "true" ]]; then
		gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
		log_info "window buttons configured"
	fi
	
	# Set workspace behavior
	local dynamic_workspaces
	dynamic_workspaces=$(get_from_config "gnome-settings.misc.dynamic-workspaces") || dynamic_workspaces="true"
	if [[ "$dynamic_workspaces" == "true" ]]; then
		gsettings set org.gnome.mutter dynamic-workspaces true
	else
		gsettings set org.gnome.mutter dynamic-workspaces false
		local num_workspaces
		num_workspaces=$(get_from_config "gnome-settings.misc.num-workspaces") || num_workspaces="4"
		gsettings set org.gnome.desktop.wm.preferences num-workspaces "$num_workspaces"
	fi
	
	log_info "miscellaneous settings configured"
	return 0
}

configure_gnome_all() {
	log_header "configuring GNOME desktop settings"
	
	# Check if running GNOME
	if [[ ! "$XDG_CURRENT_DESKTOP" =~ GNOME ]] && [[ ! "$DESKTOP_SESSION" =~ gnome ]]; then
		log_warn "not running GNOME desktop, skipping all GNOME configuration"
		return 0
	fi
	
	configure_gnome_dark_mode
	configure_gnome_wallpaper
	configure_gnome_keyboard_shortcuts
	configure_gnome_dock
	configure_gnome_misc
	
	log_info "GNOME configuration complete"
	return 0
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	configure_gnome_all
fi
