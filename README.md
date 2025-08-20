# 🚀 Personal Dotfiles & System Configuration

> Automated Ubuntu/GNOME setup with intelligent package management, service orchestration, and AI-powered development tools

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04%2B-E95420?logo=ubuntu&logoColor=white)
![Shell](https://img.shields.io/badge/Shell-Bash-4EAA25?logo=gnubash&logoColor=white)
![Stow](https://img.shields.io/badge/Managed%20with-GNU%20Stow-412991)
![License](https://img.shields.io/badge/License-MIT-blue)

This repository contains my personal dotfiles and system configuration for Ubuntu Linux with GNOME desktop environment. It features an intelligent installation system that automatically configures a complete development environment, manages system services, and integrates modern AI tools through MCP (Model Context Protocol) servers.

## 📑 Table of Contents

- [Quick Start](#quick-start)
- [What Are Dotfiles?](#what-are-dotfiles)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Directory Structure](#directory-structure)
- [Usage](#usage)
- [MCP Commands Reference](#mcp-commands-reference)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [FAQ](#faq)
- [License](#license)

## 🚀 Quick Start

For experienced users who want to get up and running immediately:

```bash
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && ./install
```

⚠️ **Warning**: This will modify your system configuration. Ensure you have backups before proceeding.

## 📖 What Are Dotfiles?

Dotfiles are configuration files in Unix-like systems that begin with a dot (.) and are typically hidden from normal directory listings. They control the behavior and appearance of various applications and shell environments.

This repository takes dotfile management to the next level by:
- **Version controlling** all configurations in Git
- **Automating** the entire system setup process
- **Modularizing** configurations for easy customization
- **Standardizing** development environments across machines
- **Integrating** modern AI and productivity tools

Instead of manually configuring each application, this system allows you to run a single command and have your entire environment configured exactly how you like it.

## ✨ Features

### Core System Components
- **Package Management**: Automated installation of essential, development, and desktop packages
- **Service Orchestration**: Jellyfin media server with automated backup and monitoring
- **Security Tools**: YubiKey support, GPG configuration, and password management
- **System Utilities**: Modern CLI tools (eza, bat, ripgrep, fzf) replacing traditional Unix utilities

### Desktop Environment
- **GNOME Customization**: Extensive theming with Nord color scheme
- **Extensions Management**: Automated installation and configuration of GNOME extensions
- **Keyboard Shortcuts**: Custom key bindings for productivity
- **Wallpaper Management**: Curated collection with automated rotation

### Development Tools
- **IDE Support**: VSCode extensions and configurations
- **Terminal Enhancement**: Zsh with Oh My Zsh, custom themes, and productivity plugins
- **Version Management**: mise (formerly rtx) for managing tool versions
- **Container Tools**: Docker and Podman with compose support
- **Language Support**: Node.js, Python, Rust, Go environments pre-configured

### AI & Productivity Tools
- **MCP Servers**: Integration with Claude AI through multiple specialized servers
  - Task Master AI for project management
  - Context7 for documentation retrieval
  - Notion integration for knowledge management
  - Brave Search for web queries
- **Claude Agents**: Custom AI agents for specific workflows
- **Automation**: Script templates and workflow automation

### Media & Entertainment
- **Jellyfin Server**: Complete media server setup with automated management
- **Multimedia Codecs**: Full codec support for all media formats
- **Streaming Tools**: OBS Studio configuration for content creation

## 📋 Prerequisites

Before installation, ensure your system meets these requirements:

### System Requirements
- **Operating System**: Ubuntu 22.04 LTS or newer (24.04 recommended)
- **Architecture**: x86_64 (AMD64)
- **RAM**: Minimum 4GB (8GB+ recommended)
- **Storage**: 10GB free space for full installation
- **Network**: Active internet connection for package downloads

### User Requirements
- **Permissions**: sudo access required
- **Shell**: Bash (will install Zsh during setup)
- **Git**: Will be installed if not present

### Recommended Backup
Before proceeding, it's recommended to:
1. Backup your existing dotfiles: `cp -r ~/.config ~/.config.backup`
2. Create a system restore point if possible
3. Document any custom configurations you want to preserve

## 📦 Installation

### Step 1: Clone the Repository

```bash
# Clone to ~/.dotfiles (recommended location)
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles

# Navigate to the repository
cd ~/.dotfiles
```

### Step 2: Review Configuration

Before installation, review and customize the configuration:

```bash
# View the configuration file
cat config.json

# Edit if needed (optional)
nano config.json
```

### Step 3: Run the Installer

```bash
# Run the installation script
./install
```

The installer will:
1. Check prerequisites and install missing dependencies
2. Add required PPAs and repositories
3. Install packages in phases (essential → development → desktop)
4. Configure GNOME desktop environment
5. Deploy dotfiles using GNU Stow
6. Set up services (like Jellyfin)
7. Configure development environments
8. Install MCP servers (if API keys are configured)

### Installation Phases

The installation proceeds through several phases:

1. **Initialization** (~1 min)
   - System detection and compatibility checks
   - Dependency installation (git, curl, wget)
   - Repository setup

2. **Essential Packages** (~5 min)
   - Core system utilities
   - Security tools
   - Command-line enhancements

3. **Development Tools** (~10 min)
   - Programming languages and runtimes
   - Version managers
   - Container tools
   - IDEs and editors

4. **Desktop Environment** (~5 min)
   - GNOME extensions
   - Themes and icons
   - Fonts (including Nerd Fonts)
   - Productivity applications

5. **Service Configuration** (~3 min)
   - Jellyfin media server
   - System services
   - Scheduled tasks

6. **Dotfile Deployment** (~1 min)
   - Symlink creation via Stow
   - Configuration file placement
   - Permission settings

### Post-Installation

After installation completes:

1. **Log out and log back in** to ensure all changes take effect
2. **Verify installation**: Run `~/.dotfiles/install --verify`
3. **Configure MCP servers** if you have API keys (see MCP Commands section)
4. **Customize** further using the configuration guide

## ⚙️ Configuration

### Main Configuration File

The `config.json` file controls all aspects of the installation:

```json
{
  "packages": {
    "essential": ["git", "curl", "wget", "build-essential"],
    "development": ["nodejs", "python3", "docker.io"],
    "desktop": ["firefox", "vlc", "gimp"]
  },
  "gnome": {
    "theme": "Nordic",
    "icons": "Papirus-Dark",
    "extensions": ["dash-to-dock", "caffeine"]
  },
  "services": {
    "jellyfin": {
      "enabled": true,
      "backup": true
    }
  }
}
```

### Package Categories

- **essential**: Core system packages, always installed
- **general**: Common utilities and tools
- **development**: Programming languages and dev tools
- **desktop**: GUI applications
- **multimedia**: Codecs and media tools
- **debget_packages**: Packages installed via deb-get
- **npm_globals**: Global npm packages
- **pip_packages**: Python packages
- **snap_packages**: Snap applications

### GNOME Configuration

Customize your desktop environment in the `gnome` section:
- **appearance**: Themes, icons, fonts, wallpapers
- **extensions**: List of GNOME extensions to install
- **keybindings**: Custom keyboard shortcuts
- **dock**: Dash-to-dock configuration

### Service Configuration

Configure system services in the `services` section:
- **jellyfin**: Media server settings
- **backup**: Automated backup configuration
- **monitoring**: System monitoring preferences

## 📁 Directory Structure

```
~/.dotfiles/
├── install                 # Main installation script
├── config.json            # Configuration file
├── README.md              # This file
├── lib/                   # Installation functions
│   ├── installer_functions.sh    # Core installation logic
│   ├── deploy_functions.sh       # Dotfile deployment
│   ├── gnome_config.sh          # GNOME configuration
│   ├── service_manager.sh       # Service management
│   └── logger.sh                # Logging utilities
├── files/                 # Files to be deployed
│   ├── stow/             # Symlinked configurations
│   │   ├── bash/         # Bash configuration
│   │   ├── zsh/          # Zsh configuration
│   │   ├── git/          # Git configuration
│   │   └── ...           # Other app configs
│   ├── copy/             # Files to be copied
│   ├── templates/        # Template files
│   └── claude-agents/    # AI agent configurations
└── wallpapers/           # Desktop wallpapers
```

### File Deployment Methods

1. **Stow** (`files/stow/`): Creates symlinks, ideal for configs you'll modify
2. **Copy** (`files/copy/`): Direct copies, for files that shouldn't be symlinked
3. **Templates** (`files/templates/`): Files with variables that get replaced

## 💻 Usage

### Adding New Packages

To add new packages to your configuration:

```bash
# Edit config.json
nano ~/.dotfiles/config.json

# Add package to appropriate category
# Then re-run specific installation phase
~/.dotfiles/install --packages
```

### Managing Services

Control installed services:

```bash
# Check Jellyfin status
systemctl --user status jellyfin

# Restart Jellyfin
systemctl --user restart jellyfin

# View service logs
journalctl --user -u jellyfin -f
```

### Updating Configurations

When you modify dotfiles:

```bash
# Re-deploy dotfiles
cd ~/.dotfiles
./install --deploy

# Or use stow directly for specific configs
cd ~/.dotfiles/files/stow
stow -R bash  # Reinstall bash configs
```

### Creating Backups

The system includes automated backup functionality:

```bash
# Manual backup of configurations
~/.dotfiles/install --backup

# Restore from backup
~/.dotfiles/install --restore <backup-date>
```

## 🤖 MCP Commands Reference

MCP (Model Context Protocol) servers extend Claude AI's capabilities. Here's how to set them up:

### Task Master AI

Intelligent task and project management:

```bash
# Install with your Anthropic API key
claude mcp add --scope user task-master \
  --env ANTHROPIC_API_KEY=your-key-here \
  -- npx -y --package=task-master-ai task-master-ai
```

**Features**:
- Parse PRDs to generate task lists
- Manage project complexity
- Track task dependencies
- AI-powered task expansion

**Usage Example**:
```bash
# Initialize a project
taskmaster init

# Parse a PRD document
taskmaster parse-prd docs/requirements.txt

# Expand complex tasks
taskmaster expand --task-id 5
```

### Context7 Documentation

Real-time documentation retrieval:

```bash
# Install Context7 (no API key required)
claude mcp add --transport http --scope user context7 \
  https://mcp.context7.com/mcp
```

**Features**:
- Access up-to-date library documentation
- Search across multiple documentation sources
- Get code examples and best practices

### Notion Integration

Connect Claude with your Notion workspace:

```bash
# Install with your Notion integration token
claude mcp add --scope user notion \
  --env NOTION_TOKEN=your-notion-token \
  -- npx -y @notionhq/notion-mcp-server
```

**Features**:
- Query Notion databases
- Create and update pages
- Search across your workspace
- Manage tasks and projects

**Setup**:
1. Create a Notion integration at https://www.notion.so/my-integrations
2. Get your integration token
3. Share relevant pages/databases with your integration

### Brave Search

Web search capabilities:

```bash
# Install with Brave Search API key
claude mcp add-json --scope user brave-search \
  '{"command":"npx","args":["-y","brave-search-mcp"],
    "env":{"BRAVE_API_KEY":"your-api-key"}}'
```

**Features**:
- Web search with privacy focus
- Image search
- News search
- Local business search

**Getting API Key**:
1. Sign up at https://api.search.brave.com
2. Create a new app
3. Copy your API key

## 🎨 Customization

### Modifying Package Lists

Edit `config.json` to customize installed packages:

```json
{
  "packages": {
    "essential": [
      // Add your essential packages here
    ],
    "development": [
      // Add development tools
    ]
  }
}
```

### Changing Themes

Modify GNOME appearance settings:

```json
{
  "gnome": {
    "appearance": {
      "gtk_theme": "Your-Theme",
      "icon_theme": "Your-Icons",
      "cursor_theme": "Your-Cursors"
    }
  }
}
```

### Adding Custom Scripts

Place custom scripts in `files/stow/bin/.local/bin/`:
1. Create your script
2. Make it executable: `chmod +x script.sh`
3. Re-run deployment: `./install --deploy`

### Creating Installation Profiles

For different machine types, create profile-specific configs:

```bash
# Create a work profile
cp config.json config.work.json

# Use specific profile during installation
./install --config config.work.json
```

## 🔧 Troubleshooting

### Installation Issues

**Problem**: Installation fails with permission errors
```bash
# Solution: Ensure you have sudo access
sudo -v

# If sudo timeout, extend it
echo "Defaults timestamp_timeout=60" | sudo tee /etc/sudoers.d/timeout
```

**Problem**: Package installation fails
```bash
# Check and fix broken packages
sudo apt --fix-broken install

# Update package lists
sudo apt update

# Retry installation
./install --packages
```

### Symlink Conflicts

**Problem**: Stow reports conflicts
```bash
# Find conflicting files
stow -n -v -R bash 2>&1 | grep "^LINK"

# Backup and remove conflicts
mv ~/.bashrc ~/.bashrc.backup

# Retry stow
cd ~/.dotfiles/files/stow && stow -R bash
```

### Service Issues

**Problem**: Jellyfin won't start
```bash
# Check service status
systemctl --user status jellyfin

# View detailed logs
journalctl --user -xe -u jellyfin

# Reset service
systemctl --user reset-failed jellyfin
systemctl --user start jellyfin
```

### GNOME Extension Problems

**Problem**: Extensions not working after installation
```bash
# Restart GNOME Shell
Alt+F2, type 'r', press Enter

# Or log out and back in
gnome-session-quit --logout
```

### MCP Server Connection Issues

**Problem**: MCP servers not connecting
```bash
# Check Claude configuration
claude mcp list

# Verify API keys are set
claude mcp show task-master

# Reinstall problematic server
claude mcp remove task-master
claude mcp add ...  # Re-add with correct configuration
```

## 🤝 Contributing

Contributions are welcome! Here's how to contribute:

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/dotfiles.git`
3. Create a feature branch: `git checkout -b feature-name`
4. Make your changes
5. Test thoroughly: `./install --dry-run`
6. Commit with clear messages
7. Push and create a pull request

### Code Style

- Use 2 spaces for indentation in shell scripts
- Follow [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Comment complex logic
- Keep functions small and focused

### Adding New Features

When adding features:
1. Update `config.json` with new options
2. Add installation logic to appropriate lib/ file
3. Document in README
4. Include example configurations
5. Test on fresh Ubuntu installation

## ❓ FAQ

**Q: Can I use this on other Linux distributions?**
A: The system is designed for Ubuntu/Debian. Other distributions would require significant modifications to package management sections.

**Q: How do I uninstall everything?**
A: Run `./install --uninstall` to remove symlinks. Package removal must be done manually to prevent accidental system damage.

**Q: Will this overwrite my existing configurations?**
A: The installer creates backups of existing files before replacing them. Check `~/.dotfiles-backup/` for your original files.

**Q: Can I use only specific parts of this configuration?**
A: Yes! You can run individual installation phases or manually copy specific configurations from the files/ directory.

**Q: How do I keep my fork updated with your changes?**
A: Add the upstream remote and regularly sync:
```bash
git remote add upstream https://github.com/originaluser/dotfiles.git
git fetch upstream
git merge upstream/main
```

**Q: Is this secure to use?**
A: The repository contains no sensitive information. However, always review scripts before running them and never commit API keys or passwords.

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

---

<div align="center">
  
**[⬆ back to top](#-personal-dotfiles--system-configuration)**

Made with ❤️ and lots of ☕

</div>