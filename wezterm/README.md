# WezTerm Configuration

GPU-accelerated terminal emulator with Tokyo Night theme, matching your Windows Terminal and VS Code setup.

## Installation

### Windows

1. **Install WezTerm:**
   ```powershell
   # Using winget (recommended)
   winget install wez.wezterm

   # Or using Scoop
   scoop install wezterm

   # Or using Chocolatey
   choco install wezterm
   ```

2. **Deploy configuration:**
   ```bash
   # Using stow (from WSL/Git Bash)
   ./stow.sh add wezterm

   # Or manually create symlink (PowerShell as Admin)
   New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\wezterm" -Target "$PWD\wezterm\.config\wezterm"

   # Or copy files
   Copy-Item -Recurse "wezterm\.config\wezterm" "$env:USERPROFILE\.config\"
   ```

### Linux/WSL

1. **Install WezTerm:**
   ```bash
   # Ubuntu/Debian
   curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
   echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
   sudo apt update
   sudo apt install wezterm

   # Fedora
   sudo dnf copr enable wezfurlong/wezterm
   sudo dnf install wezterm

   # Arch
   yay -S wezterm
   ```

2. **Deploy configuration:**
   ```bash
   ./stow.sh add wezterm
   ```

### macOS

1. **Install WezTerm:**
   ```bash
   brew install --cask wezterm
   ```

2. **Deploy configuration:**
   ```bash
   ./stow.sh add wezterm
   ```

## Features

- **Tokyo Night Color Scheme**: Matches your Windows Terminal, VS Code, and Starship themes
- **CaskaydiaCove Nerd Font**: 10pt with ligature support
- **GPU Acceleration**: WebGPU rendering for smooth performance
- **Multi-Shell Support**: PowerShell, Git Bash, WSL, CMD
- **Pane Splitting**: Work with multiple panes in one window
- **Hyperlink Detection**: Auto-detect URLs and GitHub paths
- **10,000 Line Scrollback**: Extensive command history
- **Auto-Reload**: Config changes apply immediately

## Key Bindings

### Tabs
- `Ctrl+Shift+T` - New tab
- `Ctrl+Shift+W` - Close tab
- `Ctrl+Tab` - Next tab
- `Ctrl+Shift+Tab` - Previous tab

### Panes
- `Ctrl+Shift+D` - Split horizontal
- `Ctrl+Shift+E` - Split vertical
- `Ctrl+Shift+W+Alt` - Close pane
- `Ctrl+Shift+Arrow Keys` - Navigate panes
- `Ctrl+Shift+Alt+Arrow Keys` - Resize panes

### Other
- `Ctrl+Shift+C` - Copy
- `Ctrl+Shift+V` - Paste
- `Ctrl+Shift+F` - Search
- `Ctrl+Shift+P` - Command palette
- `Ctrl++` / `Ctrl+-` - Adjust font size
- `Ctrl+0` - Reset font size
- `F11` - Fullscreen

## Launch Menu

Right-click the new tab button or use the command palette to access:
- PowerShell Core (default)
- Windows PowerShell
- Command Prompt
- Git Bash
- Ubuntu (WSL)

## Configuration Location

The config file is located at:
- **Windows**: `%USERPROFILE%\.config\wezterm\wezterm.lua`
- **Linux/macOS**: `~/.config/wezterm/wezterm.lua`

## Customization

Edit `wezterm.lua` to customize:
- Colors (line 18-76)
- Font (line 81-92)
- Window settings (line 97-111)
- Key bindings (line 143-181)
- Launch menu (line 187-211)

Changes auto-reload when you save the file.

## Testing

After deployment, launch WezTerm and verify:
1. Tokyo Night colors are applied
2. CaskaydiaCove Nerd Font is rendering correctly
3. Starship prompt displays properly (if using PowerShell)
4. Tab bar matches theme
5. Pane splitting works

## Troubleshooting

### Font not found
Install CaskaydiaCove Nerd Font:
```powershell
# Windows
scoop bucket add nerd-fonts
scoop install CascadiaCode-NF
```

### Config not loading
Check config syntax:
```bash
wezterm --config-file ~/.config/wezterm/wezterm.lua start
```

### Colors incorrect
Ensure `color_scheme = 'Tokyo Night'` is set and custom colors are defined.

## Comparison with Windows Terminal

| Feature | WezTerm | Windows Terminal |
|---------|---------|------------------|
| Platform | Cross-platform | Windows only |
| GPU | WebGPU/OpenGL | DirectX |
| Config | Lua file | JSON file |
| Reload | Auto | Manual/Auto |
| Splits | Native | Native |
| Tabs | Native | Native |
| Themes | Custom colors | Built-in schemes |

Both are excellent choices. Use WezTerm if you want cross-platform consistency or prefer Lua configuration.
