#!/usr/bin/env bash
#
# Stow helper script for dotfiles management
#

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Available packages
PACKAGES=(bash zsh vim tmux omp wsl git)

usage() {
    echo "Usage: ./stow.sh [command] [packages...]"
    echo ""
    echo "Commands:"
    echo "  add, -a      Stow (link) packages"
    echo "  remove, -d   Unstow (unlink) packages"
    echo "  restow, -r   Restow (relink) packages"
    echo "  list, -l     List available packages"
    echo "  status, -s   Show stow status"
    echo ""
    echo "Packages: ${PACKAGES[*]}"
    echo ""
    echo "Examples:"
    echo "  ./stow.sh add zsh vim      # Link zsh and vim configs"
    echo "  ./stow.sh remove bash      # Unlink bash config"
    echo "  ./stow.sh restow all       # Relink all packages"
    echo "  ./stow.sh add all          # Link all packages"
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
    *)
        usage
        ;;
esac
