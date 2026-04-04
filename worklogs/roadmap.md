# Roadmap

Future work and improvements for the dotfiles repository.

## High Priority

### [ ] Add `wezterm` and `prettier` to stow.sh

`stow.sh` lists available packages on line 9 but is missing `wezterm` and `prettier`, which both exist as stow packages
in the repo.

### [ ] Update install.sh default stow packages

Default stow list (`bash zsh nvim tmux starship`) is missing `git` and `pwsh`. WSL mode (`wsl zsh nvim tmux starship`)
is also missing `git`.

### [ ] Fix CRLF line endings in VS Code extensions.json

`vscode/.config/vscode/extensions.json` has CRLF endings (git warns on checkout). Normalize to LF.

## Medium Priority

### [ ] Implement git config management

`git/.config/git/` is a placeholder (only `.gitkeep`). Add a real git config with aliases, signing, diff/merge tool
settings, etc.

### [ ] Sync VS Code errorLens setting

`errorLens.enabledDiagnosticLevels` is configured on the machine but missing from `vscode/.config/vscode/settings.json`.
See `docs/vscode-setup-summary.md` for details.

### [ ] Expand VS Code keybindings and snippets

Only 2 custom keybindings defined. `docs/vscode-setup-summary.md` has TODOs for more productivity shortcuts and snippet
definitions.

### [ ] Align docs with stow.sh package list

CLAUDE.md lists `wezterm` as available but stow.sh doesn't include it. Ensure CLAUDE.md, README.md, and stow.sh all
agree on available packages.

## Low Priority

### [ ] Expand Neovim language extras

Clojure extra added (2026-03-13). Consider which other LazyVim language extras are worth enabling by default.

### [ ] Cross-distro install.sh testing

install.sh supports apt/dnf/pacman but only apt (WSL/Ubuntu) is regularly tested. Validate on Fedora and Arch.

### [ ] Document platform-specific vs cross-platform packages

Clarify in README which packages are Linux-only, Windows-only, or cross-platform (`vscode`, `windowsterminal` are
Windows-only; `wsl` is WSL-only).
