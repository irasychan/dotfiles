# VS Code Setup Summary

Working document for reviewing and improving the VS Code configuration.

## Settings & Keybindings

Live settings (`%APPDATA%\Code\User\`) match the dotfiles exactly - no drift.

### Theme & Appearance
- **Color theme**: Tokyo Night (`enkia.tokyo-night`)
- **Icon theme**: Material Icon Theme (`pkief.material-icon-theme`)
- **Font**: CaskaydiaCove Nerd Font (fallbacks: Cascadia Code, Fira Code, Consolas)
- **Font size**: 12 (terminal: 14)
- **Ligatures**: enabled
- **Line height**: 1.6
- **Minimap**: disabled
- **Sticky scroll**: enabled
- **Rulers**: 80, 120

### Editor Behavior
- **Format on save**: yes (default formatter: Prettier)
- **Tab size**: 2 spaces
- **Word wrap**: off
- **Bracket pair colorization**: enabled
- **Linked editing**: enabled (auto-rename matching HTML tags)
- **Cursor**: smooth blinking + smooth caret animation
- **Whitespace rendering**: on selection only

### File Handling
- **Auto save**: on focus change
- **Trim trailing whitespace**: yes
- **Insert final newline**: yes
- **Trim final newlines**: yes
- **Hidden from explorer**: `.git`, `.DS_Store`, `node_modules`, `__pycache__`, `.pytest_cache`

### Search Exclusions
- `node_modules`, `bower_components`, `*.code-search`, `dist`, `build`

### Git
- Auto fetch, smart commit, no sync confirmation

### Terminal
- Custom Tokyo Night ANSI color palette (matches other dotfiles)
- Cursor: line, blinking

### Copilot
- Enabled everywhere except markdown and SCM input

### Language Overrides
- JSON/JSONC: uses built-in VS Code formatter instead of Prettier

## Keybindings (2 custom)

| Shortcut | Action | Context |
|----------|--------|---------|
| `Shift+Enter` | Send `ESC` then `Enter` to terminal | Terminal focused |
| `Ctrl+Shift+Alt+.` | Toggle Vim mode | Global |

## Extensions

### In dotfiles (20 recommended)

| Extension | Description |
|-----------|-------------|
| `enkia.tokyo-night` | Tokyo Night theme |
| `pkief.material-icon-theme` | Material file icons |
| `esbenp.prettier-vscode` | Prettier formatter |
| `dbaeumer.vscode-eslint` | ESLint integration |
| `eamodio.gitlens` | Git blame, history |
| `editorconfig.editorconfig` | EditorConfig support |
| `usernamehw.errorlens` | Inline error/warning display |
| `christian-kohler.path-intellisense` | Path autocompletion |
| `christian-kohler.npm-intellisense` | npm module autocomplete in imports |
| `formulahendry.auto-rename-tag` | Auto-rename paired HTML tags |
| `aaron-bond.better-comments` | Colored comment annotations |
| `adpyke.codesnap` | Code screenshots |
| `vscodevim.vim` | Vim emulation |
| `tamasfe.even-better-toml` | TOML support |
| `bierner.markdown-mermaid` | Mermaid diagrams in markdown |
| `mechatroner.rainbow-csv` | CSV column coloring |
| `humao.rest-client` | HTTP request testing |
| `ms-vscode-remote.remote-wsl` | WSL integration |
| `ms-vscode-remote.remote-containers` | Dev containers |
| `ms-azuretools.vscode-docker` | Docker support |

### Installed but not in dotfiles (3 machine-specific)

| Extension | Reason |
|-----------|--------|
| `anthropic.claude-code` | CLI tool, not portable via dotfiles |
| `github.copilot-chat` | AI assistant, requires subscription |
| `firefox-devtools.vscode-firefox-debug` | Debugger, install as needed |

### Auto-installed dependency (1)

| Extension | Reason |
|-----------|--------|
| `ms-azuretools.vscode-containers` | Required by `vscode-docker`, cannot be removed independently |

## Workspace Profiles

Language-specific workspace templates in `vscode/.config/vscode/profiles/`.

| Profile | Formatter | Tab Size | Indent | Extensions | Key Settings |
|---------|-----------|----------|--------|------------|--------------|
| `node` | Prettier | 2 | spaces | ESLint, npm-intellisense, path-intellisense, auto-rename-tag | Excludes `node_modules`, `.next`, `coverage` |
| `python` | Black | 4 | spaces | Python, Pylance, Black, isort | Rulers 79/120, basic type checking, excludes `venv`, `__pycache__` |
| `dotnet` | OmniSharp | 4 | spaces | C# Dev Kit, C# | Roslyn analyzers, excludes `bin`, `obj` |
| `go` | goimports | 4 | tabs | Go | golangci-lint, language server, excludes `vendor` |
| `rust` | rust-analyzer | 4 | spaces | rust-analyzer, even-better-toml | Clippy on check, inlay hints, ruler 100, excludes `target` |

Each profile inherits your global user settings and overrides only language-specific behavior.

### Init scripts

Two scripts to install profiles into any project directory. Single profile copies the template; multiple profiles merge settings and deduplicate extensions.

| Script | Platform | Usage |
|--------|----------|-------|
| `Init-Workspace.ps1` | Windows/PowerShell | `.\Init-Workspace.ps1 <dir> <profile...> [-InstallExtensions]` |
| `init-workspace.sh` | Linux/macOS/WSL | `./init-workspace.sh <dir> <profile...>` |

Both scripts support `--list` / `-List` to show available profiles.

### Claude Code skill

The `/init-workspace` skill (`.claude/skills/init-workspace/SKILL.md`) automates the full workflow:

1. Scans a project directory for language indicators
2. Detects which profiles to apply
3. Picks the right script for the current platform
4. Creates the merged `.code-workspace` file
5. Installs recommended extensions

Usage: `/init-workspace <project-directory>` or `/init-workspace` for current directory.

## Ideas / TODO

- [ ] Review keybindings - add more productivity shortcuts?
- [ ] Consider snippet definitions
- [ ] Sync live `errorLens.enabledDiagnosticLevels` setting to dotfiles (present on machine, missing from repo)
