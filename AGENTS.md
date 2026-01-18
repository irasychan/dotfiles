# AGENTS.md

Guidance for agentic tooling working in this dotfiles repository.

## Repository Summary

- Personal dotfiles for Linux/WSL/Windows, managed with GNU Stow.
- Each top-level directory is a stow package that mirrors $HOME paths.
- Edit files in this repo only; stow handles symlinks into $HOME.
- XDG Base Directory conventions are used for config/data/state.

## Agent Rules

- No Cursor rules found in `.cursor/rules/` or `.cursorrules`.
- No Copilot rules found in `.github/copilot-instructions.md`.
- Prefer editing existing files; avoid adding new files unless requested.
- Avoid destructive git actions (reset --hard, checkout --) unless asked.
- Do not rewrite user files outside the repo; only edit tracked files.

## Core Commands

- Install (Linux/WSL default): `./install.sh`
- Install system packages + default shell: `./install.sh --system`
- Install for WSL: `./install.sh --wsl`
- Stow packages: `./stow.sh add <package>`
- Unstow packages: `./stow.sh remove <package>`
- Restow packages: `./stow.sh restow <package>`
- Show stow status: `./stow.sh status`
- Backups: `./install.sh --backup` or `./stow.sh backup`
- Restore backup: `./install.sh --restore <timestamp>` or `./stow.sh restore <timestamp>`

## Build / Lint / Test

This repo is configuration-centric; no dedicated build/lint/test runner exists.

- Build: not applicable (no build pipeline).
- Lint: not configured.
- Tests: not configured.
- Single test: not applicable.

If adding automation, document new commands here and in README.md.

## File Layout Cheatsheet

- Shell: `bash/.bashrc`, `zsh/.zshrc`, `wsl/.bashrc`
- Neovim: `nvim/.config/nvim/`
- Tmux: `tmux/.config/tmux/tmux.conf`
- Starship: `starship/.config/starship.toml`
- PowerShell: `pwsh/.config/powershell/`
- Windows setup: `windows/install.ps1`
- WezTerm: `wezterm/.config/wezterm/wezterm.lua`

## Style Guidelines (General)

- Keep diffs minimal and aligned with existing patterns.
- Use ASCII by default; avoid introducing new Unicode unless present.
- Prefer explicit, descriptive names over clever abbreviations.
- Keep comments short and only when behavior is non-obvious.
- Preserve the Tokyo Night palette and theme consistency.
- Honor XDG paths; avoid hardcoding non-XDG locations.

## Shell Scripts (bash)

- Shebang: `#!/usr/bin/env bash`.
- Use `set -e` and early exits; prefer `error()` helper for failures.
- Indentation: 4 spaces; align with current scripts.
- Strings: double quotes for variables; single quotes for literals.
- Functions: lower_snake_case; verbs for actions (`install_starship`).
- Globals: uppercase constants for colors or config vars.
- Avoid unguarded `rm -rf`; confirm or back up first.
- Use `command -v` checks before invoking tools.

## Zsh Config

- Keep plugin list minimal and ordered by relevance.
- Add aliases in grouped sections with short labels.
- Prefer XDG-aware env vars (see top of `.zshrc`).
- Lazy-load heavy tooling (e.g., nvm) when possible.

## Lua Config (Neovim / WezTerm)

- Two-space indentation.
- Use single quotes for strings unless interpolation is required.
- Keep config blocks grouped with section headers.
- Names: snake_case for locals; avoid globals.
- Return config tables at the end of modules.

## PowerShell

- Follow existing style in `Microsoft.PowerShell_profile.ps1`.
- Use PascalCase for function names if adding new ones.
- Prefer `Set-`/`Get-`/`New-` verb prefixes for cmdlets.
- Keep profile changes minimal and cross-shell consistent.

## JSON / TOML

- Preserve existing formatting and key ordering.
- Use two-space indentation where applicable.
- Keep theme-related values aligned with Tokyo Night palette.

## Error Handling and Safety

- Check for existing files and symlinks before overwriting.
- Back up user files when replacing, following install script patterns.
- Avoid modifying `.git` content, backups, or generated files.
- Do not add secrets or personal credentials.

## Stow Package Guidance

- New package layout: `<pkg>/.config/<pkg>/...`.
- If a file should live in $HOME root, mirror that path directly.
- Update README.md and this file when adding packages.
- Use `./stow.sh add <pkg>` to verify symlink behavior.

## Review Checklist

- Edits target the repo files, not symlinked targets in $HOME.
- XDG paths remain consistent.
- Shell scripts remain executable (`chmod +x` if new).
- Windows paths use backslashes; Linux paths use forward slashes.
- No new automation commands without documentation updates.

## Notes for Agents

- This repo has no CI; avoid suggesting test runs unless added.
- Prefer small, reversible changes; config changes affect user env.
- If uncertain about a shell change, ask before modifying.
