# Worklog

Development notes and changelog for dotfiles repository.

## 2026-01-17

### PowerShell Completions

- Added Starship CLI completion script for PowerShell
- Updated Windows installer to deploy PowerShell completions
- Updated docs to reference new completion support

### Repository Cleanup

- Removed SDKMAN init from WSL bashrc
- Updated docs to drop vim/omp references and align with current packages
- Expanded .gitignore for local/editor files


### Added Neovim Configuration with LazyVim

Created a new `nvim` stow package with LazyVim starter configuration.

**Files created:**
- `nvim/.config/nvim/init.lua` - Entry point
- `nvim/.config/nvim/lua/config/lazy.lua` - lazy.nvim bootstrap + LazyVim setup
- `nvim/.config/nvim/lua/config/options.lua` - Vim options with WSL clipboard fix
- `nvim/.config/nvim/lua/config/keymaps.lua` - Custom keymaps (jk/jj escape, etc.)
- `nvim/.config/nvim/lua/config/autocmds.lua` - Autocommands
- `nvim/.config/nvim/lua/plugins/editor.lua` - Neo-tree and Telescope config
- `nvim/.config/nvim/lua/plugins/colorscheme.lua` - Tokyo Night theme

**Key features:**
- LazyVim framework with lazy.nvim plugin manager
- Tokyo Night colorscheme (matches Starship shell theme)
- Hidden files visible by default in Neo-tree and Telescope
- WSL clipboard integration
- Space as leader key

**Key bindings:**
| Binding | Action |
|---------|--------|
| `<Space>e` | Toggle file explorer (Neo-tree) |
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep |
| `<Space>/` | Search in buffer |
| `jk` / `jj` | Exit insert mode |
| `:Lazy` | Plugin manager UI |

### Updated Scripts

**install.sh:**
- Added nvim to XDG directories creation
- Added nvim config to conflict detection
- Added nvim to default stow packages
- Added nvim to WSL mode installation
- Updated print_summary with nvim quick reference

**stow.sh:**
- Added nvim to available packages
- Added backup/restore/reset functionality
- Added color-coded output
- Added list-backups command

### Updated Documentation

- CLAUDE.md: Added nvim configuration section, updated directory structure, XDG paths, and testing instructions
- README.md: (needs update for nvim package)

---

## Configuration Notes

### Theme Alignment

All prompt tools use the Tokyo Night color palette for consistency:

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

### XDG Paths

| Tool | Config | Data | State |
|------|--------|------|-------|
| Neovim | `$XDG_CONFIG_HOME/nvim` | `$XDG_DATA_HOME/nvim` | `$XDG_STATE_HOME/nvim` |
| Zsh | - | `$XDG_DATA_HOME/oh-my-zsh` | `$XDG_STATE_HOME/zsh` |
| Starship | `$XDG_CONFIG_HOME/starship.toml` | - | - |
| PowerShell | `$XDG_CONFIG_HOME/powershell` | - | - |
