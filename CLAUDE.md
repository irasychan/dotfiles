# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles for Linux/WSL development environments, managed with GNU Stow. Configurations follow the XDG Base Directory Specification.

## Directory Structure

```
dotfiles/
├── bash/.bashrc              # Standard Linux bash
├── zsh/.zshrc                # Zsh + oh-my-zsh configuration
├── vim/.config/vim/vimrc     # Vim with XDG support
├── tmux/.config/tmux/tmux.conf
├── omp/.config/omp/          # Oh My Posh themes (for zsh)
│   ├── theme.omp.json
│   └── theme.omp.yaml
├── starship/.config/starship.toml  # Starship prompt (for pwsh)
├── pwsh/.config/powershell/  # PowerShell profile
│   └── Microsoft.PowerShell_profile.ps1
├── wsl/.bashrc               # WSL-specific (auto-starts zsh)
├── git/.config/git/          # Git config (placeholder)
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
3. Installs dependencies (stow, zsh, vim, neovim, tmux, fzf, ripgrep)
4. Installs oh-my-zsh and plugins
5. Installs Oh My Posh and/or Starship
6. Installs vim-plug
7. Deploys configs via stow
8. Sets zsh as default shell

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

Available packages: bash, zsh, vim, tmux, omp, starship, pwsh, wsl, git

### windows/install.ps1

Windows 11 installer (PowerShell):
- Installs Starship via winget/scoop/chocolatey
- Deploys PowerShell profile to both PS 5.x and 7+
- Creates symlinks (requires admin) or copies files
- Backup/restore functionality like Linux version

Options: `-Help`, `-Backup`, `-Restore <timestamp>`, `-SkipStarship`

Windows profile locations:
- PowerShell 7+: `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
- PowerShell 5.x: `$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

## Configuration Details

### zsh/.zshrc

- Sets XDG environment variables at top
- oh-my-zsh installed to `$XDG_DATA_HOME/oh-my-zsh`
- Plugins: git, docker, kubectl, fzf, z, zsh-autosuggestions, zsh-completions, zsh-syntax-highlighting
- Oh My Posh theme loaded from `$XDG_CONFIG_HOME/omp/theme.omp.json`
- GPG agent configured as SSH agent
- Aliases: `vim`→`nvim`, `nv`, `nvc`, `lg`→`lazygit`, `pn`→`pnpm`

### vim/.config/vim/vimrc

- Full XDG support for vim directories (backup, swap, undo, viminfo)
- vim-plug with plugins stored in `$XDG_DATA_HOME/vim/plugged`
- Plugins: ALE (linting), NERDTree, fzf, vim-easymotion, vim-surround, vim-markdown, vim-vue
- WSL cursor shape fixes
- `<C-n>` toggles NERDTree

### omp/.config/omp/theme.omp.*

- Multi-line prompt with Tokyo Night colors
- Shows: path, git branch/status, language versions
- JSON and YAML versions (JSON is active)
- Used by zsh via Oh My Posh

### starship/.config/starship.toml

- Cross-shell prompt matching Tokyo Night theme from Oh My Posh
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

## Theme Alignment

Both Oh My Posh (zsh) and Starship (pwsh) use the same Tokyo Night color palette:

| Color | Hex | Usage |
|-------|-----|-------|
| terminal-blue | `#7aa2f7` | Prompt arrow, PHP |
| terminal-magenta | `#bb9af7` | Path, .NET |
| light-sky-blue | `#7dcfff` | Git branch clean, Go |
| terminal-red | `#f7768e` | Errors, git dirty, Ruby |
| pistachio-green | `#9ece6a` | Success char, Node |
| terminal-yellow | `#e0af68` | Python |
| white-blue | `#a9b1d6` | Command duration |
| blue-black | `#565f89` | Comments, predictions |

## XDG Paths Reference

| Tool | Path |
|------|------|
| oh-my-zsh | `$XDG_DATA_HOME/oh-my-zsh` |
| NVM | `$XDG_DATA_HOME/nvm` |
| Cargo | `$XDG_DATA_HOME/cargo` |
| Go | `$XDG_DATA_HOME/go` |
| SDKMan | `$XDG_DATA_HOME/sdkman` |
| GPG | `$XDG_DATA_HOME/gnupg` |
| Vim plugins | `$XDG_DATA_HOME/vim/plugged` |
| Zsh history | `$XDG_STATE_HOME/zsh/history` |
| Starship config | `$XDG_CONFIG_HOME/starship.toml` |
| PowerShell profile | `$XDG_CONFIG_HOME/powershell/` |

## Adding New Configurations

1. Create package directory: `mkdir -p newpkg/.config/newpkg`
2. Add config file: `newpkg/.config/newpkg/config`
3. Deploy: `./stow.sh add newpkg`

## Testing Changes

After editing configs:
- Zsh: `source ~/.zshrc` or restart terminal
- Vim: `:source $MYVIMRC` or restart vim
- Tmux: `tmux source ~/.config/tmux/tmux.conf`
- PowerShell: `. $PROFILE` or `reload`
