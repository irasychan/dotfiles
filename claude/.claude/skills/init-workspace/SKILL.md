---
name: init-workspace
description: Analyze a project directory and set up a VS Code workspace with language-specific profiles. Use when setting up a new project, initializing workspace settings, or when the user asks to configure VS Code for a project.
argument-hint: "[project-directory]"
disable-model-invocation: true
---

# Initialize VS Code Workspace

Set up a VS Code `.code-workspace` file for a project by detecting its languages and applying the appropriate profile templates.

## Locate profiles directory

The profiles and scripts live in the dotfiles repo. Resolve the path:

- **Windows**: `$HOME/dotfiles/vscode/.config/vscode/profiles/`
- **Linux/macOS/WSL**: `$HOME/dotfiles/vscode/.config/vscode/profiles/`

Verify the directory exists with `Glob` on `$HOME/dotfiles/vscode/.config/vscode/profiles/*.code-workspace` before proceeding.

## Available profiles

| Profile  | Indicators                                                                |
| -------- | ------------------------------------------------------------------------- |
| `node`   | `package.json`, `tsconfig.json`, `.js`/`.ts`/`.tsx`/`.jsx` files          |
| `python` | `requirements.txt`, `pyproject.toml`, `setup.py`, `Pipfile`, `*.py` files |
| `dotnet` | `*.csproj`, `*.sln`, `*.fsproj` files                                     |
| `go`     | `go.mod`, `*.go` files                                                    |
| `rust`   | `Cargo.toml`, `*.rs` files                                                |

## Steps

1. **Resolve target directory** from `$ARGUMENTS` (default: current working directory).

2. **Detect languages** by scanning the project root for the indicators above. Use `Glob` to check for each pattern (e.g. `<project-dir>/package.json`, `<project-dir>/**/*.py`). Only scan top-level and one level deep to avoid slow searches in large trees. Report findings to the user.

3. **Check for existing workspace** — use `Glob` for `<project-dir>/*.code-workspace`. If one exists, warn the user and ask before overwriting.

4. **Determine platform**:
   - Check if running on Windows (win32 platform) → use `Init-Workspace.ps1`
   - Otherwise (Linux/macOS/WSL) → use `init-workspace.sh`

5. **Run the script** via `Bash`:
   - **Windows (PowerShell)**:
     ```
     powershell.exe -ExecutionPolicy Bypass -File "<profiles-dir>/Init-Workspace.ps1" "<project-dir>" <profile1> [profile2 ...] -InstallExtensions
     ```
   - **Bash**:
     ```
     echo y | "<profiles-dir>/init-workspace.sh" "<project-dir>" <profile1> [profile2 ...]
     ```

6. **Report results**: show the created workspace file path, which profiles were applied, and which extensions were installed.

## Notes

- If no languages are detected, list the available profiles and ask the user which to apply.
- When multiple languages are detected, all matching profiles are passed to the script which merges them into a single workspace file.
- The scripts handle extension installation — do not install extensions separately.
