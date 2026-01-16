#!/usr/bin/env bash
#
# Dotfiles Bootstrap Script
# Installs dependencies and deploys configuration files using GNU Stow
#

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check if command exists
has() { command -v "$1" &>/dev/null; }

# Backup directory
BACKUP_DIR="$HOME/.dotfiles-backup"

# Backup existing environment
backup_existing() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/$timestamp"

    info "Backing up existing environment to $backup_path..."
    mkdir -p "$backup_path"

    # Files to backup (dotfiles in home)
    local home_files=(
        .bashrc
        .bash_profile
        .bash_logout
        .profile
        .zshrc
        .zshenv
        .zprofile
        .vimrc
        .gvimrc
        .tmux.conf
        .gitconfig
        .gitignore_global
    )

    # Backup home dotfiles
    for file in "${home_files[@]}"; do
        if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
            info "  Backing up ~/$file"
            cp -a "$HOME/$file" "$backup_path/"
        fi
    done

    # XDG config directories to backup
    local xdg_dirs=(
        vim
        nvim
        tmux
        omp
        zsh
        git
        powershell
    )

    # Backup XDG config directories
    if [[ -d "$XDG_CONFIG_HOME" ]]; then
        mkdir -p "$backup_path/.config"
        for dir in "${xdg_dirs[@]}"; do
            if [[ -d "$XDG_CONFIG_HOME/$dir" && ! -L "$XDG_CONFIG_HOME/$dir" ]]; then
                info "  Backing up ~/.config/$dir"
                cp -a "$XDG_CONFIG_HOME/$dir" "$backup_path/.config/"
            fi
        done
    fi

    # Backup oh-my-zsh custom directory (preserves user customizations)
    if [[ -d "$XDG_DATA_HOME/oh-my-zsh/custom" && ! -L "$XDG_DATA_HOME/oh-my-zsh/custom" ]]; then
        mkdir -p "$backup_path/.local/share/oh-my-zsh"
        info "  Backing up oh-my-zsh custom directory"
        cp -a "$XDG_DATA_HOME/oh-my-zsh/custom" "$backup_path/.local/share/oh-my-zsh/"
    fi

    # Save backup manifest
    cat > "$backup_path/MANIFEST" << EOF
Dotfiles Backup
===============
Date: $(date)
Host: $(hostname)
User: $USER

Backed up files:
$(find "$backup_path" -type f ! -name MANIFEST | sed "s|$backup_path/||")

To restore:
  ./install.sh --restore $timestamp
EOF

    success "Backup complete: $backup_path"
    echo ""

    # Keep only last 5 backups
    local backup_count
    backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" | wc -l)
    if [[ $backup_count -gt 5 ]]; then
        info "Cleaning old backups (keeping last 5)..."
        find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" | sort | head -n -5 | xargs rm -rf
    fi
}

# Restore from backup
restore_backup() {
    local timestamp="$1"
    local backup_path="$BACKUP_DIR/$timestamp"

    if [[ -z "$timestamp" ]]; then
        # List available backups
        echo "Available backups:"
        if [[ -d "$BACKUP_DIR" ]]; then
            for dir in "$BACKUP_DIR"/*/; do
                if [[ -d "$dir" ]]; then
                    local name
                    name=$(basename "$dir")
                    echo "  - $name"
                fi
            done
        else
            echo "  No backups found"
        fi
        echo ""
        echo "Usage: ./install.sh --restore <timestamp>"
        return 1
    fi

    if [[ ! -d "$backup_path" ]]; then
        error "Backup not found: $backup_path"
    fi

    info "Restoring from backup: $backup_path"

    # Restore home dotfiles
    for file in "$backup_path"/.*; do
        if [[ -f "$file" ]]; then
            local filename
            filename=$(basename "$file")
            info "  Restoring ~/$filename"
            cp -a "$file" "$HOME/"
        fi
    done

    # Restore .config directories
    if [[ -d "$backup_path/.config" ]]; then
        for dir in "$backup_path/.config"/*/; do
            if [[ -d "$dir" ]]; then
                local dirname
                dirname=$(basename "$dir")
                info "  Restoring ~/.config/$dirname"
                rm -rf "$XDG_CONFIG_HOME/$dirname"
                cp -a "$dir" "$XDG_CONFIG_HOME/"
            fi
        done
    fi

    # Restore oh-my-zsh custom
    if [[ -d "$backup_path/.local/share/oh-my-zsh/custom" ]]; then
        info "  Restoring oh-my-zsh custom directory"
        cp -a "$backup_path/.local/share/oh-my-zsh/custom" "$XDG_DATA_HOME/oh-my-zsh/"
    fi

    success "Restore complete from $timestamp"
}

# List available backups
list_backups() {
    echo "Available backups in $BACKUP_DIR:"
    echo ""
    if [[ -d "$BACKUP_DIR" ]]; then
        for dir in "$BACKUP_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                local name
                name=$(basename "$dir")
                local date_str
                date_str=$(echo "$name" | sed 's/_/ /' | sed 's/\([0-9]\{4\}\)\([0-9]\{2\}\)\([0-9]\{2\}\)/\1-\2-\3/')
                echo "  $name"
                if [[ -f "$dir/MANIFEST" ]]; then
                    grep -A1 "Backed up files:" "$dir/MANIFEST" | tail -1 | head -c 60
                    echo "..."
                fi
                echo ""
            fi
        done
    else
        echo "  No backups found"
    fi
}

# Detect package manager
detect_pkg_manager() {
    if has apt-get; then
        PKG_MANAGER="apt"
        PKG_INSTALL="sudo apt-get install -y"
        PKG_UPDATE="sudo apt-get update"
    elif has dnf; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="sudo dnf install -y"
        PKG_UPDATE="sudo dnf check-update || true"
    elif has pacman; then
        PKG_MANAGER="pacman"
        PKG_INSTALL="sudo pacman -S --noconfirm"
        PKG_UPDATE="sudo pacman -Sy"
    else
        error "Unsupported package manager. Please install packages manually."
    fi
    info "Detected package manager: $PKG_MANAGER"
}

# Create XDG directories
create_xdg_dirs() {
    info "Creating XDG directories..."
    mkdir -p "$XDG_CONFIG_HOME"/{zsh,vim,nvim,omp,aws,docker,npm,git,powershell}
    mkdir -p "$XDG_DATA_HOME"/{vim/plugged,vim/spell,nvim,oh-my-zsh,nvm,cargo,go,gnupg,sdkman}
    mkdir -p "$XDG_STATE_HOME"/{vim/{backup,swap,view,undo},nvim,zsh,less}
    mkdir -p "$XDG_CACHE_HOME"/zsh
    mkdir -p "$HOME/.local/bin"
    success "XDG directories created"
}

# Install base packages
install_base_packages() {
    info "Installing base packages..."
    $PKG_UPDATE

    local packages=(
        git
        curl
        wget
        stow
        zsh
        vim
        neovim
        tmux
        fzf
        ripgrep
        unzip
    )

    $PKG_INSTALL "${packages[@]}"
    success "Base packages installed"
}

# Install oh-my-zsh
install_ohmyzsh() {
    if [[ -d "$XDG_DATA_HOME/oh-my-zsh" ]]; then
        warn "oh-my-zsh already installed, skipping..."
        return
    fi

    info "Installing oh-my-zsh..."
    export ZSH="$XDG_DATA_HOME/oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "oh-my-zsh installed"
}

# Install oh-my-zsh plugins
install_zsh_plugins() {
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$XDG_DATA_HOME/oh-my-zsh/custom}"

    info "Installing zsh plugins..."

    # zsh-autosuggestions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    # zsh-completions
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
        git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
    fi

    # zsh-syntax-highlighting
    if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    success "zsh plugins installed"
}

# Install Oh My Posh
install_ohmyposh() {
    if has oh-my-posh; then
        warn "Oh My Posh already installed, skipping..."
        return
    fi

    info "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
    success "Oh My Posh installed"
}

# Install Starship prompt
install_starship() {
    if has starship; then
        warn "Starship already installed, skipping..."
        return
    fi

    info "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
    success "Starship installed"
}

# Install vim-plug
install_vimplug() {
    local plug_vim="$XDG_DATA_HOME/vim/autoload/plug.vim"

    if [[ -f "$plug_vim" ]]; then
        warn "vim-plug already installed, skipping..."
        return
    fi

    info "Installing vim-plug..."
    curl -fLo "$plug_vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    success "vim-plug installed"
}

# Deploy dotfiles with stow
deploy_dotfiles() {
    info "Deploying dotfiles with stow..."
    cd "$DOTFILES_DIR"

    # Remove existing files that would conflict
    local conflicts=(
        "$HOME/.bashrc"
        "$HOME/.zshrc"
        "$HOME/.config/vim/vimrc"
        "$HOME/.config/nvim/init.lua"
        "$HOME/.config/tmux/tmux.conf"
        "$HOME/.config/omp/theme.omp.json"
        "$HOME/.config/omp/theme.omp.yaml"
        "$HOME/.config/starship.toml"
        "$HOME/.config/powershell/Microsoft.PowerShell_profile.ps1"
    )

    for file in "${conflicts[@]}"; do
        if [[ -f "$file" && ! -L "$file" ]]; then
            warn "Backing up existing $file to ${file}.bak"
            mv "$file" "${file}.bak"
        fi
    done

    # Stow packages
    local packages=(bash zsh vim nvim tmux omp)

    for pkg in "${packages[@]}"; do
        if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
            info "Stowing $pkg..."
            stow -v -R -t "$HOME" "$pkg"
        fi
    done

    success "Dotfiles deployed"
}

# Install vim plugins
install_vim_plugins() {
    info "Installing vim plugins..."
    if has nvim; then
        nvim --headless +PlugInstall +qall 2>/dev/null || true
    elif has vim; then
        vim +PlugInstall +qall 2>/dev/null || true
    fi
    success "Vim plugins installed"
}

# Set zsh as default shell
set_default_shell() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        warn "zsh is already the default shell"
        return
    fi

    info "Setting zsh as default shell..."
    local zsh_path
    zsh_path="$(which zsh)"

    if ! grep -q "$zsh_path" /etc/shells; then
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    chsh -s "$zsh_path"
    success "Default shell changed to zsh"
}

# Print summary
print_summary() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    Dotfiles Installation Complete!    ${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "Your previous environment was backed up to:"
    echo "  $BACKUP_DIR"
    echo ""
    echo "To restore: ./install.sh --restore <timestamp>"
    echo "To list:    ./install.sh --list-backups"
    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Install additional tools as needed:"
    echo "     - NVM: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash"
    echo "     - SDKMAN: curl -s https://get.sdkman.io | bash"
    echo "     - lazygit: https://github.com/jesseduffield/lazygit#installation"
    echo ""
    echo "Stow packages available:"
    echo "  bash, zsh, vim, nvim, tmux, omp, wsl, git, starship, pwsh"
    echo ""
    echo "Neovim (LazyVim):"
    echo "  First launch will auto-install plugins."
    echo "  <Space>e  - File explorer"
    echo "  <Space>ff - Find files"
    echo "  :Lazy     - Manage plugins"
    echo ""
    echo "To add/remove a package: stow [-D] <package>"
    echo ""
}

# Main installation
main() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}      Dotfiles Bootstrap Script        ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    backup_existing
    detect_pkg_manager
    create_xdg_dirs
    install_base_packages
    install_ohmyzsh
    install_zsh_plugins
    install_ohmyposh
    install_vimplug
    deploy_dotfiles
    install_vim_plugins
    set_default_shell
    print_summary
}

# Run with options
case "${1:-}" in
    --help|-h)
        echo "Usage: ./install.sh [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h           Show this help message"
        echo "  --backup             Only backup existing environment"
        echo "  --restore [TIME]     Restore from backup (lists available if no TIME given)"
        echo "  --list-backups       List available backups"
        echo "  --packages           Only install packages (no stow)"
        echo "  --stow               Only run stow (with backup, no package installation)"
        echo "  --stow-no-backup     Only run stow (without backup)"
        echo "  --wsl                Install for WSL (uses wsl package instead of bash)"
        echo "  --pwsh               Install PowerShell profile with Starship prompt"
        echo ""
        echo "Backups are stored in: $BACKUP_DIR"
        echo ""
        exit 0
        ;;
    --backup)
        backup_existing
        ;;
    --restore)
        restore_backup "$2"
        ;;
    --list-backups)
        list_backups
        ;;
    --packages)
        backup_existing
        detect_pkg_manager
        create_xdg_dirs
        install_base_packages
        install_ohmyzsh
        install_zsh_plugins
        install_ohmyposh
        install_vimplug
        ;;
    --stow)
        backup_existing
        deploy_dotfiles
        ;;
    --stow-no-backup)
        deploy_dotfiles
        ;;
    --wsl)
        backup_existing
        detect_pkg_manager
        create_xdg_dirs
        install_base_packages
        install_ohmyzsh
        install_zsh_plugins
        install_ohmyposh
        install_vimplug

        # For WSL, stow wsl instead of bash
        info "Deploying dotfiles with stow (WSL mode)..."
        cd "$DOTFILES_DIR"
        stow -v -R -t "$HOME" wsl zsh vim nvim tmux omp
        success "Dotfiles deployed (WSL mode)"

        install_vim_plugins
        set_default_shell
        print_summary
        ;;
    --pwsh)
        backup_existing
        install_starship

        info "Deploying PowerShell and Starship configs..."
        cd "$DOTFILES_DIR"
        stow -v -R -t "$HOME" starship pwsh
        success "PowerShell profile and Starship deployed"

        echo ""
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}    PowerShell Setup Complete!         ${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo "Starship prompt installed with Tokyo Night theme."
        echo ""
        echo "To use in PowerShell, ensure pwsh is installed:"
        echo "  # Ubuntu/Debian:"
        echo "  sudo apt-get install -y powershell"
        echo ""
        echo "  # Or download from: https://github.com/PowerShell/PowerShell"
        echo ""
        echo "Start PowerShell with: pwsh"
        echo ""
        ;;
    *)
        main
        ;;
esac
