# Dotfiles

Personal configuration files for Linux and WSL development environments, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
git clone https://github.com/irasychan/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

For WSL environments:

```bash
./install.sh --wsl
```

## Structure

This repository uses GNU Stow for symlink management. Each directory is a "package" that mirrors the structure relative to `$HOME`:

```
dotfiles/
├── bash/                 # Bash configuration
│   └── .bashrc
├── zsh/                  # Zsh + oh-my-zsh configuration
│   └── .zshrc
├── vim/                  # Vim/Neovim configuration
│   └── .config/vim/vimrc
├── tmux/                 # Tmux configuration
│   └── .config/tmux/tmux.conf
├── omp/                  # Oh My Posh theme (for zsh)
│   └── .config/omp/
│       ├── theme.omp.json
│       └── theme.omp.yaml
├── starship/             # Starship prompt (for pwsh)
│   └── .config/starship.toml
├── pwsh/                 # PowerShell profile
│   └── .config/powershell/
│       └── Microsoft.PowerShell_profile.ps1
├── wsl/                  # WSL-specific bash (auto-starts zsh)
│   └── .bashrc
├── git/                  # Git configuration (placeholder)
│   └── .config/git/
├── install.sh            # Bootstrap script
└── stow.sh               # Stow helper script
```

## Installation Options

### Full Installation

Installs all dependencies and deploys configurations:

```bash
./install.sh        # Standard Linux
./install.sh --wsl  # WSL environment
./install.sh --pwsh # PowerShell with Starship prompt
```

### Partial Installation

```bash
./install.sh --packages  # Only install dependencies
./install.sh --stow      # Only deploy configs (assumes deps installed)
```

### Manual Stow

Use the helper script or stow directly:

```bash
# Using helper script
./stow.sh add zsh vim omp    # Link specific packages
./stow.sh add all            # Link all packages
./stow.sh remove bash        # Unlink a package
./stow.sh restow all         # Relink all packages
./stow.sh status             # Show what's linked

# Using stow directly
stow -t ~ zsh vim omp        # Link packages
stow -D -t ~ bash            # Unlink package
```

## Packages

| Package | Description | Files |
|---------|-------------|-------|
| `bash`  | Bash shell config | `.bashrc` |
| `zsh`   | Zsh + oh-my-zsh | `.zshrc` |
| `vim`   | Vim/Neovim config | `.config/vim/vimrc` |
| `tmux`  | Tmux config | `.config/tmux/tmux.conf` |
| `omp`   | Oh My Posh theme (zsh) | `.config/omp/theme.omp.*` |
| `starship` | Starship prompt config | `.config/starship.toml` |
| `pwsh`  | PowerShell profile | `.config/powershell/...` |
| `wsl`   | WSL bash (starts zsh) | `.bashrc` |
| `git`   | Git configuration | `.config/git/` |

## Features

### XDG Base Directory

All configurations follow the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html):

- Config: `~/.config/`
- Data: `~/.local/share/`
- State: `~/.local/state/`
- Cache: `~/.cache/`

### Zsh Configuration

- **oh-my-zsh** framework with curated plugins
- Plugins: git, docker, kubectl, fzf, z, autosuggestions, syntax-highlighting
- **Oh My Posh** prompt with Tokyo Night theme
- GPG agent as SSH agent
- XDG-compliant tool paths

### Vim Configuration

- **vim-plug** plugin manager
- Plugins: ALE, NERDTree, fzf, easymotion, vim-surround
- Full XDG directory support
- WSL cursor fixes

### Oh My Posh Theme (Zsh)

- Multi-line prompt
- Git status with color-coded changes
- Language version display (Node, Python, Go, Ruby, PHP, Julia)
- Tokyo Night color palette

### PowerShell + Starship

- **Starship** cross-shell prompt with matching Tokyo Night theme
- PSReadLine with predictive IntelliSense and Tokyo Night colors
- Emacs-style keybindings (like zsh)
- Git shortcuts and navigation functions
- Completions for kubectl, Azure CLI

## Post-Installation

After running `install.sh`, you may want to install additional tools:

```bash
# NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

# SDKMAN (Java/JVM tools)
curl -s https://get.sdkman.io | bash

# lazygit
# See: https://github.com/jesseduffield/lazygit#installation
```

## Updating

Pull changes and restow:

```bash
cd ~/dotfiles
git pull
./stow.sh restow all
```

## Customization

### Adding a New Package

1. Create a directory with the package name
2. Add files mirroring their location relative to `$HOME`
3. Run `./stow.sh add <package>`

Example for adding a custom script:

```bash
mkdir -p scripts/.local/bin
cp my-script.sh scripts/.local/bin/
./stow.sh add scripts
```

### Modifying Configurations

Edit files directly in the dotfiles directory - changes apply immediately since they're symlinked.

## Requirements

Installed automatically by `install.sh`:

- git, curl, wget
- stow
- zsh, vim/neovim, tmux
- fzf, ripgrep

## License

MIT
