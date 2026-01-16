#!/usr/bin/env bash
#
# Stow helper script for dotfiles management
#

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Available packages
PACKAGES=(bash zsh vim nvim tmux omp wsl git starship pwsh)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# XDG directories
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Backup directory
BACKUP_DIR="$HOME/.dotfiles-backup"

usage() {
    echo "Usage: ./stow.sh [command] [packages...]"
    echo ""
    echo "Commands:"
    echo "  add, -a           Stow (link) packages"
    echo "  remove, -d        Unstow (unlink) packages"
    echo "  restow, -r        Restow (relink) packages"
    echo "  list, -l          List available packages"
    echo "  status, -s        Show stow status"
    echo "  backup, -b        Backup all current settings"
    echo "  reset             Remove all symlinks and restore to default"
    echo "  restore [TIME]    Restore from a specific backup"
    echo "  list-backups      List available backups"
    echo ""
    echo "Packages: ${PACKAGES[*]}"
    echo ""
    echo "Examples:"
    echo "  ./stow.sh add zsh vim      # Link zsh and vim configs"
    echo "  ./stow.sh remove bash      # Unlink bash config"
    echo "  ./stow.sh restow all       # Relink all packages"
    echo "  ./stow.sh add all          # Link all packages"
    echo "  ./stow.sh backup           # Backup current settings"
    echo "  ./stow.sh reset            # Remove all symlinks, restore defaults"
    echo "  ./stow.sh restore          # List available backups"
    echo "  ./stow.sh restore 20240115 # Restore from specific backup"
    echo ""
}

list_packages() {
    echo "Available packages:"
    for pkg in "${PACKAGES[@]}"; do
        if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
            echo "  - $pkg"
        fi
    done
}

get_packages() {
    local pkgs=()
    for arg in "$@"; do
        if [[ "$arg" == "all" ]]; then
            pkgs=("${PACKAGES[@]}")
            break
        else
            pkgs+=("$arg")
        fi
    done
    echo "${pkgs[@]}"
}

stow_add() {
    local pkgs
    read -ra pkgs <<< "$(get_packages "$@")"
    cd "$DOTFILES_DIR"
    for pkg in "${pkgs[@]}"; do
        if [[ -d "$pkg" ]]; then
            echo "Stowing $pkg..."
            stow -v -t "$HOME" "$pkg"
        else
            echo "Package not found: $pkg"
        fi
    done
}

stow_remove() {
    local pkgs
    read -ra pkgs <<< "$(get_packages "$@")"
    cd "$DOTFILES_DIR"
    for pkg in "${pkgs[@]}"; do
        if [[ -d "$pkg" ]]; then
            echo "Unstowing $pkg..."
            stow -v -D -t "$HOME" "$pkg"
        else
            echo "Package not found: $pkg"
        fi
    done
}

stow_restow() {
    local pkgs
    read -ra pkgs <<< "$(get_packages "$@")"
    cd "$DOTFILES_DIR"
    for pkg in "${pkgs[@]}"; do
        if [[ -d "$pkg" ]]; then
            echo "Restowing $pkg..."
            stow -v -R -t "$HOME" "$pkg"
        else
            echo "Package not found: $pkg"
        fi
    done
}

stow_status() {
    echo "Stow status:"
    for pkg in "${PACKAGES[@]}"; do
        if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
            # Check if any file from this package is linked
            local linked=false
            while IFS= read -r -d '' file; do
                local rel_path="${file#$DOTFILES_DIR/$pkg/}"
                local target="$HOME/$rel_path"
                if [[ -L "$target" ]]; then
                    linked=true
                    break
                fi
            done < <(find "$DOTFILES_DIR/$pkg" -type f -print0 2>/dev/null)

            if $linked; then
                echo "  [x] $pkg (linked)"
            else
                echo "  [ ] $pkg (not linked)"
            fi
        fi
    done
}

# Backup all current settings
backup_all() {
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_path="$BACKUP_DIR/$timestamp"

    info "Backing up current settings to $backup_path..."
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

    # Backup home dotfiles (both real files and symlinks)
    for file in "${home_files[@]}"; do
        if [[ -e "$HOME/$file" || -L "$HOME/$file" ]]; then
            if [[ -L "$HOME/$file" ]]; then
                # For symlinks, save the link target info
                info "  Backing up ~/$file (symlink -> $(readlink "$HOME/$file"))"
                echo "symlink:$(readlink "$HOME/$file")" > "$backup_path/${file}.linkinfo"
            else
                info "  Backing up ~/$file"
                cp -a "$HOME/$file" "$backup_path/"
            fi
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
        starship.toml
    )

    # Backup XDG config directories
    if [[ -d "$XDG_CONFIG_HOME" ]]; then
        mkdir -p "$backup_path/.config"
        for item in "${xdg_dirs[@]}"; do
            local src="$XDG_CONFIG_HOME/$item"
            if [[ -e "$src" || -L "$src" ]]; then
                if [[ -L "$src" ]]; then
                    info "  Backing up ~/.config/$item (symlink)"
                    echo "symlink:$(readlink "$src")" > "$backup_path/.config/${item}.linkinfo"
                else
                    info "  Backing up ~/.config/$item"
                    cp -a "$src" "$backup_path/.config/"
                fi
            fi
        done
    fi

    # Backup oh-my-zsh custom directory
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

Stow status at backup time:
$(stow_status 2>/dev/null | grep -E "^\s+\[")

Backed up items:
$(find "$backup_path" -type f ! -name MANIFEST | sed "s|$backup_path/||" | sort)

To restore:
  ./stow.sh restore $timestamp
EOF

    success "Backup complete: $backup_path"

    # Keep only last 5 backups
    local backup_count
    backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" 2>/dev/null | wc -l)
    if [[ $backup_count -gt 5 ]]; then
        info "Cleaning old backups (keeping last 5)..."
        find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" | sort | head -n -5 | xargs rm -rf
    fi
}

# List available backups
list_backups() {
    echo "Available backups in $BACKUP_DIR:"
    echo ""
    if [[ -d "$BACKUP_DIR" ]]; then
        local found=false
        for dir in "$BACKUP_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                found=true
                local name
                name=$(basename "$dir")
                echo "  $name"
                if [[ -f "$dir/MANIFEST" ]]; then
                    echo "    $(head -3 "$dir/MANIFEST" | tail -1)"
                fi
            fi
        done
        if ! $found; then
            echo "  No backups found"
        fi
    else
        echo "  No backups found"
    fi
    echo ""
    echo "Usage: ./stow.sh restore <timestamp>"
}

# Restore from backup
restore_backup() {
    local timestamp="$1"

    if [[ -z "$timestamp" ]]; then
        list_backups
        return 0
    fi

    local backup_path="$BACKUP_DIR/$timestamp"

    if [[ ! -d "$backup_path" ]]; then
        error "Backup not found: $backup_path"
    fi

    info "Restoring from backup: $backup_path"

    # First, remove all stowed symlinks
    info "Removing current dotfiles symlinks..."
    cd "$DOTFILES_DIR"
    for pkg in "${PACKAGES[@]}"; do
        if [[ -d "$pkg" ]]; then
            stow -D -t "$HOME" "$pkg" 2>/dev/null || true
        fi
    done

    # Restore home dotfiles
    for file in "$backup_path"/.*; do
        if [[ -f "$file" ]]; then
            local filename
            filename=$(basename "$file")
            if [[ "$filename" == *.linkinfo ]]; then
                continue
            fi
            info "  Restoring ~/$filename"
            rm -f "$HOME/$filename"
            cp -a "$file" "$HOME/"
        fi
    done

    # Restore from .linkinfo files (recreate symlinks)
    for linkinfo in "$backup_path"/*.linkinfo; do
        if [[ -f "$linkinfo" ]]; then
            local filename
            filename=$(basename "$linkinfo" .linkinfo)
            local target
            target=$(cut -d: -f2 "$linkinfo")
            info "  Restoring ~/$filename (symlink)"
            rm -f "$HOME/$filename"
            ln -s "$target" "$HOME/$filename"
        fi
    done

    # Restore .config directories
    if [[ -d "$backup_path/.config" ]]; then
        for item in "$backup_path/.config"/*; do
            if [[ -e "$item" ]]; then
                local itemname
                itemname=$(basename "$item")
                if [[ "$itemname" == *.linkinfo ]]; then
                    local realname="${itemname%.linkinfo}"
                    local target
                    target=$(cut -d: -f2 "$item")
                    info "  Restoring ~/.config/$realname (symlink)"
                    rm -rf "$XDG_CONFIG_HOME/$realname"
                    ln -s "$target" "$XDG_CONFIG_HOME/$realname"
                else
                    info "  Restoring ~/.config/$itemname"
                    rm -rf "$XDG_CONFIG_HOME/$itemname"
                    cp -a "$item" "$XDG_CONFIG_HOME/"
                fi
            fi
        done
    fi

    # Restore oh-my-zsh custom
    if [[ -d "$backup_path/.local/share/oh-my-zsh/custom" ]]; then
        info "  Restoring oh-my-zsh custom directory"
        mkdir -p "$XDG_DATA_HOME/oh-my-zsh"
        cp -a "$backup_path/.local/share/oh-my-zsh/custom" "$XDG_DATA_HOME/oh-my-zsh/"
    fi

    success "Restore complete from $timestamp"
}

# Reset to default - remove all symlinks and restore original files
reset_to_default() {
    echo ""
    warn "This will remove ALL dotfiles symlinks and restore to default state."
    echo "Any backed up original files will be restored."
    echo ""
    read -p "Continue? [y/N] " -n 1 -r
    echo ""

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Aborted."
        return 0
    fi

    # Create a backup first
    info "Creating backup before reset..."
    backup_all

    # Remove all stowed symlinks
    info "Removing all dotfiles symlinks..."
    cd "$DOTFILES_DIR"
    for pkg in "${PACKAGES[@]}"; do
        if [[ -d "$pkg" ]]; then
            echo "  Unstowing $pkg..."
            stow -D -t "$HOME" "$pkg" 2>/dev/null || true
        fi
    done

    # Find the most recent backup that has real files (not just symlinks)
    local restore_backup=""
    if [[ -d "$BACKUP_DIR" ]]; then
        for dir in $(find "$BACKUP_DIR" -maxdepth 1 -type d ! -path "$BACKUP_DIR" | sort -r); do
            # Check if this backup has any real files (not just .linkinfo)
            if find "$dir" -type f ! -name "*.linkinfo" ! -name "MANIFEST" | grep -q .; then
                restore_backup="$dir"
                break
            fi
        done
    fi

    if [[ -n "$restore_backup" ]]; then
        local backup_name
        backup_name=$(basename "$restore_backup")
        info "Restoring original files from backup: $backup_name"

        # Restore only real files (not symlinks)
        for file in "$restore_backup"/.*; do
            if [[ -f "$file" ]]; then
                local filename
                filename=$(basename "$file")
                if [[ "$filename" != *.linkinfo && "$filename" != "MANIFEST" ]]; then
                    info "  Restoring ~/$filename"
                    cp -a "$file" "$HOME/"
                fi
            fi
        done

        # Restore .config directories (only real directories)
        if [[ -d "$restore_backup/.config" ]]; then
            for item in "$restore_backup/.config"/*; do
                if [[ -d "$item" && ! "$item" == *.linkinfo ]]; then
                    local itemname
                    itemname=$(basename "$item")
                    info "  Restoring ~/.config/$itemname"
                    rm -rf "$XDG_CONFIG_HOME/$itemname"
                    cp -a "$item" "$XDG_CONFIG_HOME/"
                fi
            done
        fi
    else
        warn "No backup with original files found. Symlinks removed but no files restored."
    fi

    success "Reset complete. Your environment has been restored to default."
    echo ""
    echo "To re-deploy dotfiles, run:"
    echo "  ./stow.sh add all"
}

case "${1:-}" in
    add|-a)
        shift
        stow_add "$@"
        ;;
    remove|-d)
        shift
        stow_remove "$@"
        ;;
    restow|-r)
        shift
        stow_restow "$@"
        ;;
    list|-l)
        list_packages
        ;;
    status|-s)
        stow_status
        ;;
    backup|-b)
        backup_all
        ;;
    reset)
        reset_to_default
        ;;
    restore)
        shift
        restore_backup "$1"
        ;;
    list-backups)
        list_backups
        ;;
    *)
        usage
        ;;
esac
