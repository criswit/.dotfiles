#!/bin/bash

SCRIPT_NAME="$0"
SCRIPT_ABSOLUTE_PATH="$(readlink -f -- "$SCRIPT_NAME")"
DOTFILES_DIR="$(dirname "$SCRIPT_ABSOLUTE_PATH")"

source "$DOTFILES_DIR/lib/logger.sh"

function config_install() {
	jq -r ".$1[] | @sh" "$DOTFILES_DIR/config.json" | while read -r item; do
		pkg=$(echo "$item" | tr -d "'")
		if [ "$1" = "apt" ]; then
			sudo apt install "$pkg" -y
		elif [ "$1" = "deb" ]; then
			sudo deb-get install "$pkg"
		elif [ "$1" = "code" ]; then
			code --install-extension "$pkg"
		elif [ "$1" = "ppa" ]; then
			sudo add-apt-repository "ppa:$pkg"
		elif [ "$1" = "font" ]; then
			install_font "$pkg"
		fi
	done
}

function add_to_apt() {
	# wezterm
	# see https://wezterm.org/install/linux.html#installing-on-ubuntu
	curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /etc/apt/keyrings/wezterm-fury.gpg
	echo 'deb [signed-by=/etc/apt/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
}

function non_pkg_manager_installs() {
	# deb get
	curl -sL https://raw.githubusercontent.com/wimpysworld/deb-get/main/deb-get | sudo -E bash -s install deb-get
	# nvm
	PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash'
	# starship
	curl -sS https://starship.rs/install.sh | sh
}

function install_go() {
	wget "https://dl.google.com/go/$(curl https://go.dev/VERSION?m=text | head -n1).linux-amd64.tar.gz" -O /tmp/go-linux.tar.gz
	sudo tar -C /usr/local -xzf /tmp/go-linux.tar.gz
}

function install_jetbrains_toolbox() {
	TMP_DIR="/tmp"
	INSTALL_DIR="$HOME/.local/share/JetBrains/Toolbox/bin"
	SYMLINK_DIR="$HOME/.local/bin"
	log_info "### INSTALL JETBRAINS TOOLBOX ###"
	log_info "Fetching the URL of the latest version..."
	ARCHIVE_URL=$(curl -s 'https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release' | grep -Po '"linux":.*?[^\\]",' | awk -F ':' '{print $3,":"$4}' | sed 's/[", ]//g')
	ARCHIVE_FILENAME=$(basename "$ARCHIVE_URL")
	log_info "Downloading $ARCHIVE_FILENAME..."
	rm "$TMP_DIR/$ARCHIVE_FILENAME" 2>/dev/null || true
	wget -q --show-progress -cO "$TMP_DIR/$ARCHIVE_FILENAME" "$ARCHIVE_URL"
	log_info "Extracting to $INSTALL_DIR..."
	mkdir -p "$INSTALL_DIR"
	rm "$INSTALL_DIR/jetbrains-toolbox" 2>/dev/null || true
	tar -xzf "$TMP_DIR/$ARCHIVE_FILENAME" -C "$INSTALL_DIR" --strip-components=1
	rm "$TMP_DIR/$ARCHIVE_FILENAME"
	chmod +x "$INSTALL_DIR/jetbrains-toolbox"
	log_info "Symlinking to $SYMLINK_DIR/jetbrains-toolbox..."
	mkdir -p $SYMLINK_DIR
	rm "$SYMLINK_DIR/jetbrains-toolbox" 2>/dev/null || true
	ln -s "$INSTALL_DIR/jetbrains-toolbox" "$SYMLINK_DIR/jetbrains-toolbox"

	if [ -z "$CI" ]; then
		log_info "Running for the first time to set-up..."
		("$INSTALL_DIR/jetbrains-toolbox" &)
		log_info "Done! JetBrains Toolbox should now be running, in your application list, and you can run it in terminal as jetbrains-toolbox (ensure that $SYMLINK_DIR is on your PATH)"
	else
		log_info "Done! Running in a CI -- skipped launching the AppImage."
	fi
}

install_rust() {
	# SEE: https://www.rust-lang.org/tools/install
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
}

#!/bin/bash

### GNOME ###

function setup_gnome() {
	KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

	gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
		"['$KEY_PATH/custom0/', '$KEY_PATH/custom1/']"

	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH/custom0/ name "Toggle Ulauncher"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH/custom0/ command "ulauncher-toggle"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH/custom0/ binding "<Super>space"

	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH/custom1/ name "Lock keyboard"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH/custom1/ command "/usr/bin/xtrlock"
	gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$KEY_PATH/custom1/ binding "<Super><Control>l"

}

function install_font() {
	local version='3.3.0'
	local fonts_dir="${HOME}/.local/share/fonts"
	if [[ ! -d "$fonts_dir" ]]; then
		mkdir -p "$fonts_dir"
	fi
	zip_file="$1".zip
	download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
	log_info "downloading $1 font from $download_url"
	wget "$download_url"
	unzip "$zip_file" -d "$fonts_dir"
	rm "$zip_file"
	find "$fonts_dir" -name '*Windows Compatible*' -delete

	fc-cache -fv
}
