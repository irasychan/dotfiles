# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for Linux/WSL development environments, managed with GNU Stow. Configurations follow the XDG Base Directory Specification.

## Directory Structure

```
dotfiles/
├── bash/.bashrc              # Standard Linux bash
├── zsh/.zshrc                # Zsh + oh-my-zsh configuration
├── nvim/.config/nvim/        # Neovim with LazyVim
│   ├── init.lua
│   └── lua/{config,plugins}/
├── tmux/.config/tmux/tmux.conf
├── starship/.config/starship.toml  # Starship prompt (for pwsh)
├── pwsh/.config/powershell/  # PowerShell profile
│   └── Microsoft.PowerShell_profile.ps1
├── vscode/.config/vscode/    # VS Code settings (Windows only)
│   ├── settings.json
│   ├── keybindings.json
│   └── extensions.json
├── windowsterminal/.config/windowsterminal/  # Windows Terminal (Windows only)
│   └── settings.json
├── wsl/.bashrc               # WSL-specific (auto-starts zsh)
├── git/.config/git/          # Git config (placeholder)
├── docs/                     # Documentation and guides
│   └── gpg-key-transfer-windows-wsl.md
├── windows/install.ps1       # Windows 11 installer
├── install.sh                # Bootstrap script (Linux/WSL)
└── stow.sh                   # Stow helper
```

Each top-level directory is a GNU Stow "package" - its contents mirror the structure relative to `$HOME`. Running `stow zsh` creates `~/.zshrc -> dotfiles/zsh/.zshrc`.

## Key Scripts

### install.sh

Bootstrap script that:
1. Backs up existing environment to `~/.dotfiles-backup/`
2. Detects package manager (apt/dnf/pacman)
3. Installs dependencies (stow, zsh, neovim, tmux, fzf, ripgrep)
4. Installs oh-my-zsh and plugins
5. Installs Starship
6. Deploys configs via stow
7. Sets zsh as default shell

Options:
- `--wsl`: Uses `wsl` package instead of `bash`
- `--pwsh`: Installs Starship and deploys PowerShell profile
- `--packages`: Only install dependencies
- `--stow`: Only deploy configs (with backup)
- `--backup`: Only backup existing environment
- `--restore [TIME]`: Restore from backup
- `--list-backups`: List available backups

### stow.sh

Helper for managing stow packages:
- `./stow.sh add <packages>`: Link packages
- `./stow.sh remove <packages>`: Unlink packages
- `./stow.sh restow <packages>`: Relink packages
- `./stow.sh status`: Show linked status
- Use `all` to operate on all packages

Available packages: bash, zsh, nvim, tmux, starship, pwsh, wsl, git

### windows/install.ps1

Windows 11 installer (PowerShell):
- Installs Starship via winget/scoop/chocolatey
- Deploys PowerShell profile to both PS 5.x and 7+
- Deploys VS Code settings, keybindings, and extensions
- Deploys Windows Terminal settings with Tokyo Night color scheme
- Creates symlinks (requires admin) or copies files
- Backup/restore functionality like Linux version

Options: `-Help`, `-Backup`, `-Restore <timestamp>`, `-SkipStarship`, `-SkipVSCode`, `-SkipTerminal`

Windows config locations:
- PowerShell 7+: `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- PowerShell 5.x: `$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
- VS Code: `%APPDATA%\Code\User\settings.json`
- Windows Terminal: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\settings.json`

## Configuration Details

### zsh/.zshrc

- Sets XDG environment variables at top
- oh-my-zsh installed to `$XDG_DATA_HOME/oh-my-zsh`
- Plugins: git, docker, kubectl, fzf, z, zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting
- GPG agent configured as SSH agent
- Aliases: `vim`→`nvim`, `nv`, `nvc`, `lg`→`lazygit`, `pn`→`pnpm`

### nvim/.config/nvim/

LazyVim-based Neovim configuration:

- **Framework**: LazyVim (lazy.nvim plugin manager)
- **Colorscheme**: Tokyo Night (matches shell theme)
- **Leader key**: Space
- **File explorer**: Neo-tree (hidden files visible by default)
- **Fuzzy finder**: Telescope (hidden files included)
- **WSL**: Clipboard integration configured

Structure:
```
nvim/.config/nvim/
├── init.lua                 # Entry point
└── lua/
    ├── config/
    │   ├── lazy.lua         # lazy.nvim bootstrap
    │   ├── options.lua      # Vim options
    │   ├── keymaps.lua      # Custom keymaps
    │   └── autocmds.lua     # Autocommands
    └── plugins/
        ├── editor.lua       # Neo-tree, Telescope config
        └── colorscheme.lua  # Tokyo Night theme
```

Key bindings:
- `<Space>e` - Toggle file explorer (Neo-tree)
- `<Space>ff` - Find files
- `<Space>fg` - Live grep
- `<Space>/` - Search in buffer
- `jk` or `jj` - Exit insert mode
- `:Lazy` - Plugin manager UI

First launch auto-installs all plugins.

### starship/.config/starship.toml

- Cross-shell prompt matching Tokyo Night theme
- Multi-line format: `➜ path ⚡ (branch) \n ▶`
- Right prompt shows language versions (node, python, rust, go, etc.)
- Used by PowerShell profile

### pwsh/.config/powershell/Microsoft.PowerShell_profile.ps1

- Initializes Starship prompt
- PSReadLine with Tokyo Night colors and predictive IntelliSense
- Emacs-style keybindings (consistent with zsh)
- XDG environment variables
- Aliases matching zsh: `vim`, `nv`, `lg`, `g`
- Git shortcuts: `gs`, `ga`, `gc`, `gp`, `gl`, `gd`, `gco`, `gb`, `glog`
- Navigation: `..`, `...`, `....`, `mkcd`
- Completions for kubectl, Azure CLI

### wsl/.bashrc

- Sets TERM for color support
- Auto-execs zsh when in interactive terminal
- Use this instead of `bash` package in WSL

### vscode/.config/vscode/ (Windows only)

- `settings.json`: Editor and terminal settings with Tokyo Night theme
- `keybindings.json`: Custom keyboard shortcuts
- `extensions.json`: Recommended extensions list
- Terminal colors match Tokyo Night palette
- Font: CaskaydiaCove Nerd Font with ligatures
- Recommended theme: Tokyo Night (`enkia.tokyo-night`)
- Deployed via `windows/install.ps1`

### windowsterminal/.config/windowsterminal/ (Windows only)

- Tokyo Night and Tokyo Night Storm color schemes
- Tokyo Night window theme (tab bar, backgrounds)
- Default profile: PowerShell Core
- Profiles: PowerShell 7+, Windows PowerShell 5.x, Ubuntu (WSL), CMD
- Font: CaskaydiaCove Nerd Font, 12pt
- Keyboard shortcuts for pane splitting, tab management
- Deployed via `windows/install.ps1`

## Theme Alignment

All configurations use the Tokyo Night color palette for consistency across shells, editors, and terminals:

| Color | Hex | Usage |
|-------|-----|-------|
| main-bg | `#1a1b26` | Terminal/editor background |
| terminal-blue | `#7aa2f7` | Prompt arrow, commands, PHP |
| terminal-magenta | `#bb9af7` | Path, keywords, .NET |
| light-sky-blue | `#7dcfff` | Git branch clean, operators, Go |
| terminal-red | `#f7768e` | Errors, git dirty, Ruby |
| pistachio-green | `#9ece6a` | Success char, strings, Node |
| terminal-yellow | `#e0af68` | Python, numbers |
| terminal-green | `#73daca` | Variables |
| white-blue | `#a9b1d6` | Command duration, foreground |
| blue-black | `#565f89` | Comments, predictions |
| terminal-black | `#414868` | Selection background |

## XDG Paths Reference

### Linux/WSL

| Tool | Path |
|------|------|
| oh-my-zsh | `$XDG_DATA_HOME/oh-my-zsh` |
| NVM | `$XDG_DATA_HOME/nvm` |
| Cargo | `$XDG_DATA_HOME/cargo` |
| Go | `$XDG_DATA_HOME/go` |
| GPG | `$XDG_DATA_HOME/gnupg` |
| Neovim data | `$XDG_DATA_HOME/nvim` |
| Neovim state | `$XDG_STATE_HOME/nvim` |
| Zsh history | `$XDG_STATE_HOME/zsh/history` |
| Starship config | `$XDG_CONFIG_HOME/starship.toml` |
| PowerShell profile | `$XDG_CONFIG_HOME/powershell/` |

### Windows

| Tool | Path |
|------|------|
| Starship config | `%USERPROFILE%\.config\starship.toml` |
| VS Code settings | `%APPDATA%\Code\User\` |
| Windows Terminal | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\` |
| PowerShell 7+ | `%USERPROFILE%\Documents\PowerShell\` |
| PowerShell 5.x | `%USERPROFILE%\Documents\WindowsPowerShell\` |

## Adding New Configurations

1. Create package directory: `mkdir -p newpkg/.config/newpkg`
2. Add config file: `newpkg/.config/newpkg/config`
3. Deploy: `./stow.sh add newpkg`

## Testing Changes

After editing configs:
- Zsh: `source ~/.zshrc` or restart terminal
- Neovim: `:Lazy sync` to update plugins, or restart nvim
- Tmux: `tmux source ~/.config/tmux/tmux.conf`
- PowerShell: `. $PROFILE` or `reload`
- VS Code: Restart VS Code or `Ctrl+Shift+P` → "Reload Window"
- Windows Terminal: Changes apply immediately (no restart needed)

## Documentation

The `docs/` directory contains guides and references:

- **gpg-key-transfer-windows-wsl.md**: Step-by-step guide for transferring GPG signing keys from Windows to WSL Ubuntu
