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
├── omp/.config/omp/          # Oh My Posh themes
│   ├── theme.omp.json
│   └── theme.omp.yaml
├── wsl/.bashrc               # WSL-specific (auto-starts zsh)
├── git/.config/git/          # Git config (placeholder)
├── install.sh                # Bootstrap script
└── stow.sh                   # Stow helper
```

Each top-level directory is a GNU Stow "package" - its contents mirror the structure relative to `$HOME`. Running `stow zsh` creates `~/.zshrc -> dotfiles/zsh/.zshrc`.

## Key Scripts

### install.sh

Bootstrap script that:
1. Detects package manager (apt/dnf/pacman)
2. Installs dependencies (stow, zsh, vim, neovim, tmux, fzf, ripgrep)
3. Installs oh-my-zsh and plugins
4. Installs Oh My Posh
5. Installs vim-plug
6. Deploys configs via stow
7. Sets zsh as default shell

Options:
- `--wsl`: Uses `wsl` package instead of `bash`
- `--packages`: Only install dependencies
- `--stow`: Only deploy configs

### stow.sh

Helper for managing stow packages:
- `./stow.sh add <packages>`: Link packages
- `./stow.sh remove <packages>`: Unlink packages
- `./stow.sh restow <packages>`: Relink packages
- `./stow.sh status`: Show linked status
- Use `all` to operate on all packages

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

### wsl/.bashrc

- Sets TERM for color support
- Auto-execs zsh when in interactive terminal
- Use this instead of `bash` package in WSL

## XDG Paths Reference

The zshrc configures these XDG-compliant paths:

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

## Adding New Configurations

1. Create package directory: `mkdir -p newpkg/.config/newpkg`
2. Add config file: `newpkg/.config/newpkg/config`
3. Deploy: `./stow.sh add newpkg`

## Testing Changes

After editing configs:
- Zsh: `source ~/.zshrc` or restart terminal
- Vim: `:source $MYVIMRC` or restart vim
- Tmux: `tmux source ~/.config/tmux/tmux.conf`
