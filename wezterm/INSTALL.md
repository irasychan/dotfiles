# WezTerm Quick Installation Guide

## Windows Installation (Recommended)

### Step 1: Install WezTerm

Choose one method:

```powershell
# Method 1: Winget (Recommended)
winget install wez.wezterm

# Method 2: Scoop
scoop install wezterm

# Method 3: Chocolatey
choco install wezterm
```

### Step 2: Deploy Configuration

**Option A: Using Stow (from WSL/Git Bash)**
```bash
cd ~/dotfiles
./stow.sh add wezterm
```

**Option B: Manual Symlink (PowerShell as Admin)**
```powershell
cd ~\dotfiles
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.config\wezterm" -Target "$PWD\wezterm\.config\wezterm"
```

**Option C: Copy Files (No admin needed)**
```powershell
cd ~\dotfiles
Copy-Item -Recurse "wezterm\.config\wezterm" "$env:USERPROFILE\.config\"
```

### Step 3: Verify Installation

1. Launch WezTerm
2. Check that:
   - Background is dark blue (#1A1B26)
   - Font is CaskaydiaCove Nerd Font
   - Tabs have Tokyo Night colors
   - PowerShell opens by default

### Step 4: Set as Default (Optional)

To make WezTerm your default terminal:

```powershell
# Windows 11 Settings
Start-Process ms-settings:defaultapps
# Then search for "Terminal" and set WezTerm
```

## Linux/WSL Installation

### Ubuntu/Debian

```bash
# Add repository
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list

# Install
sudo apt update
sudo apt install wezterm

# Deploy config
cd ~/dotfiles
./stow.sh add wezterm
```

### Fedora

```bash
# Add repository
sudo dnf copr enable wezfurlong/wezterm

# Install
sudo dnf install wezterm

# Deploy config
cd ~/dotfiles
./stow.sh add wezterm
```

### Arch Linux

```bash
# Install
yay -S wezterm

# Deploy config
cd ~/dotfiles
./stow.sh add wezterm
```

## macOS Installation

```bash
# Install via Homebrew
brew install --cask wezterm

# Deploy config
cd ~/dotfiles
./stow.sh add wezterm
```

## First Launch Checklist

- [ ] WezTerm launches successfully
- [ ] Background color is Tokyo Night (#1A1B26)
- [ ] CaskaydiaCove Nerd Font is rendering
- [ ] Tab bar shows Tokyo Night theme
- [ ] Starship prompt displays correctly (PowerShell)
- [ ] Nerd Font icons appear in prompt
- [ ] Copy/paste works (Ctrl+Shift+C/V)
- [ ] Split panes work (Ctrl+Shift+D/E)

## Troubleshooting

### Font Missing
```powershell
# Windows - Install CaskaydiaCove Nerd Font
scoop bucket add nerd-fonts
scoop install CascadiaCode-NF

# Linux
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip
unzip CascadiaCode.zip
fc-cache -fv
```

### Config Not Loading
```bash
# Test config syntax
wezterm --config-file ~/.config/wezterm/wezterm.lua start

# Check for errors
wezterm ls-fonts
```

### Starship Prompt Not Showing
```powershell
# Ensure Starship is installed
starship --version

# Verify PowerShell profile loads Starship
Test-Path $PROFILE
Get-Content $PROFILE | Select-String "starship"
```

### WSL Profile Not Working
```powershell
# Check WSL installation
wsl --list --verbose

# Update WSL path in wezterm.lua if needed
# Edit: wezterm/.config/wezterm/wezterm.lua
# Find launch_menu section and update WSL path
```

## Next Steps

1. Customize key bindings in `wezterm.lua` (line 143-181)
2. Adjust font size if needed (line 88)
3. Add custom shell profiles to launch menu (line 187-211)
4. Explore WezTerm features: https://wezfurlong.org/wezterm/

## Uninstall

```bash
# Remove symlink
./stow.sh remove wezterm

# Uninstall WezTerm
# Windows
winget uninstall wez.wezterm

# Linux
sudo apt remove wezterm  # Ubuntu/Debian
sudo dnf remove wezterm  # Fedora
yay -R wezterm          # Arch

# macOS
brew uninstall wezterm
```
