#Requires -Version 5.1
<#
.SYNOPSIS
    Dotfiles installer for Windows 11

.DESCRIPTION
    Installs PowerShell profile and Starship prompt on Windows.
    Supports both Windows PowerShell 5.x and PowerShell 7+.

.PARAMETER Backup
    Only backup existing configuration

.PARAMETER Restore
    Restore from backup (specify timestamp)

.PARAMETER SkipStarship
    Skip Starship installation

.EXAMPLE
    .\install.ps1
    Full installation with Starship

.EXAMPLE
    .\install.ps1 -Backup
    Only backup existing configs

.EXAMPLE
    .\install.ps1 -Restore 20240115_120000
    Restore from specific backup
#>

[CmdletBinding()]
param(
    [switch]$Backup,
    [string]$Restore,
    [switch]$SkipStarship,
    [switch]$SkipVSCode,
    [switch]$SkipTerminal,
    [switch]$Help
)

# Script configuration
$ErrorActionPreference = "Stop"
$Script:DotfilesDir = Split-Path -Parent $PSScriptRoot
$Script:BackupDir = Join-Path $env:USERPROFILE ".dotfiles-backup"

# XDG-style paths for Windows
$Script:ConfigHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $env:USERPROFILE ".config" }

# PowerShell profile paths (use actual Documents location, handles OneDrive redirection)
$Script:DocumentsPath = [Environment]::GetFolderPath('MyDocuments')
$Script:PSCorePath = Join-Path $Script:DocumentsPath "PowerShell"
$Script:PS5Path = Join-Path $Script:DocumentsPath "WindowsPowerShell"

# VS Code paths
$Script:VSCodeUserPath = Join-Path $env:APPDATA "Code\User"

# Windows Terminal path (find dynamically)
function Get-WindowsTerminalPath {
    $localAppData = $env:LOCALAPPDATA
    $wtPackages = Get-ChildItem (Join-Path $localAppData "Packages") -Filter "Microsoft.WindowsTerminal*" -Directory -ErrorAction SilentlyContinue
    if ($wtPackages) {
        return Join-Path $wtPackages[0].FullName "LocalState"
    }
    return $null
}

# Colors
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Blue }
function Write-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Err { Write-Host "[ERROR] $args" -ForegroundColor Red }

function Show-Help {
    Write-Host @"

Dotfiles Windows Installer
==========================

Usage: .\install.ps1 [options]

Options:
    -Help           Show this help message
    -Backup         Only backup existing configuration
    -Restore <TIME> Restore from backup (lists available if no TIME given)
    -SkipStarship   Skip Starship installation
    -SkipVSCode     Skip VS Code settings installation
    -SkipTerminal   Skip Windows Terminal settings installation

Examples:
    .\install.ps1                    # Full installation
    .\install.ps1 -Backup            # Backup only
    .\install.ps1 -Restore           # List backups
    .\install.ps1 -SkipStarship      # Install without Starship
    .\install.ps1 -SkipVSCode        # Install without VS Code settings

Backups are stored in: $Script:BackupDir

"@
}

function Backup-ExistingConfig {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupPath = Join-Path $Script:BackupDir $timestamp

    Write-Info "Backing up existing configuration to $backupPath..."
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

    # Backup PowerShell profiles
    $profilesToBackup = @(
        @{ Path = (Join-Path $Script:PSCorePath "Microsoft.PowerShell_profile.ps1"); Name = "pwsh7_profile.ps1" }
        @{ Path = (Join-Path $Script:PS5Path "Microsoft.PowerShell_profile.ps1"); Name = "ps5_profile.ps1" }
    )

    foreach ($profile in $profilesToBackup) {
        if (Test-Path $profile.Path) {
            $isSymlink = (Get-Item $profile.Path).Attributes -band [System.IO.FileAttributes]::ReparsePoint
            if (-not $isSymlink) {
                Write-Info "  Backing up $($profile.Name)"
                Copy-Item $profile.Path (Join-Path $backupPath $profile.Name) -Force
            }
        }
    }

    # Backup Starship config
    $starshipConfig = Join-Path $Script:ConfigHome "starship.toml"
    if (Test-Path $starshipConfig) {
        $isSymlink = (Get-Item $starshipConfig).Attributes -band [System.IO.FileAttributes]::ReparsePoint
        if (-not $isSymlink) {
            Write-Info "  Backing up starship.toml"
            Copy-Item $starshipConfig (Join-Path $backupPath "starship.toml") -Force
        }
    }

    # Backup VS Code settings
    $vscodeBackupDir = Join-Path $backupPath "vscode"
    $vscodeFiles = @("settings.json", "keybindings.json", "extensions.json")
    foreach ($file in $vscodeFiles) {
        $vscodeFile = Join-Path $Script:VSCodeUserPath $file
        if (Test-Path $vscodeFile) {
            $isSymlink = (Get-Item $vscodeFile).Attributes -band [System.IO.FileAttributes]::ReparsePoint
            if (-not $isSymlink) {
                New-Item -ItemType Directory -Path $vscodeBackupDir -Force | Out-Null
                Write-Info "  Backing up VS Code $file"
                Copy-Item $vscodeFile (Join-Path $vscodeBackupDir $file) -Force
            }
        }
    }

    # Backup Windows Terminal settings
    $wtPath = Get-WindowsTerminalPath
    if ($wtPath) {
        $wtSettings = Join-Path $wtPath "settings.json"
        if (Test-Path $wtSettings) {
            $isSymlink = (Get-Item $wtSettings).Attributes -band [System.IO.FileAttributes]::ReparsePoint
            if (-not $isSymlink) {
                Write-Info "  Backing up Windows Terminal settings.json"
                Copy-Item $wtSettings (Join-Path $backupPath "windowsterminal_settings.json") -Force
            }
        }
    }

    # Create manifest
    $manifest = @"
Dotfiles Backup (Windows)
=========================
Date: $(Get-Date)
Computer: $env:COMPUTERNAME
User: $env:USERNAME

Backed up files:
$(Get-ChildItem $backupPath -File | ForEach-Object { "  - $($_.Name)" })

To restore:
  .\install.ps1 -Restore $timestamp
"@
    $manifest | Out-File (Join-Path $backupPath "MANIFEST.txt") -Encoding UTF8

    Write-Success "Backup complete: $backupPath"

    # Keep only last 5 backups
    $backups = Get-ChildItem $Script:BackupDir -Directory | Sort-Object Name
    if ($backups.Count -gt 5) {
        Write-Info "Cleaning old backups (keeping last 5)..."
        $backups | Select-Object -First ($backups.Count - 5) | Remove-Item -Recurse -Force
    }

    return $backupPath
}

function Restore-FromBackup {
    param([string]$Timestamp)

    if (-not $Timestamp) {
        Write-Host "Available backups in $Script:BackupDir`n"
        if (Test-Path $Script:BackupDir) {
            Get-ChildItem $Script:BackupDir -Directory | ForEach-Object {
                Write-Host "  - $($_.Name)"
            }
        } else {
            Write-Host "  No backups found"
        }
        Write-Host "`nUsage: .\install.ps1 -Restore <timestamp>"
        return
    }

    $backupPath = Join-Path $Script:BackupDir $Timestamp
    if (-not (Test-Path $backupPath)) {
        Write-Err "Backup not found: $backupPath"
        exit 1
    }

    Write-Info "Restoring from backup: $backupPath"

    # Restore PowerShell 7 profile
    $ps7Backup = Join-Path $backupPath "pwsh7_profile.ps1"
    if (Test-Path $ps7Backup) {
        $dest = Join-Path $Script:PSCorePath "Microsoft.PowerShell_profile.ps1"
        New-Item -ItemType Directory -Path $Script:PSCorePath -Force | Out-Null
        Write-Info "  Restoring PowerShell 7 profile"
        Copy-Item $ps7Backup $dest -Force
    }

    # Restore PowerShell 5 profile
    $ps5Backup = Join-Path $backupPath "ps5_profile.ps1"
    if (Test-Path $ps5Backup) {
        $dest = Join-Path $Script:PS5Path "Microsoft.PowerShell_profile.ps1"
        New-Item -ItemType Directory -Path $Script:PS5Path -Force | Out-Null
        Write-Info "  Restoring PowerShell 5 profile"
        Copy-Item $ps5Backup $dest -Force
    }

    # Restore Starship config
    $starshipBackup = Join-Path $backupPath "starship.toml"
    if (Test-Path $starshipBackup) {
        $dest = Join-Path $Script:ConfigHome "starship.toml"
        New-Item -ItemType Directory -Path $Script:ConfigHome -Force | Out-Null
        Write-Info "  Restoring starship.toml"
        Copy-Item $starshipBackup $dest -Force
    }

    # Restore VS Code settings
    $vscodeBackupDir = Join-Path $backupPath "vscode"
    if (Test-Path $vscodeBackupDir) {
        New-Item -ItemType Directory -Path $Script:VSCodeUserPath -Force | Out-Null
        Get-ChildItem $vscodeBackupDir -File | ForEach-Object {
            Write-Info "  Restoring VS Code $($_.Name)"
            Copy-Item $_.FullName (Join-Path $Script:VSCodeUserPath $_.Name) -Force
        }
    }

    # Restore Windows Terminal settings
    $wtBackup = Join-Path $backupPath "windowsterminal_settings.json"
    if (Test-Path $wtBackup) {
        $wtPath = Get-WindowsTerminalPath
        if ($wtPath) {
            Write-Info "  Restoring Windows Terminal settings.json"
            Copy-Item $wtBackup (Join-Path $wtPath "settings.json") -Force
        }
    }

    Write-Success "Restore complete from $Timestamp"
}

function Install-Starship {
    # Check if already installed
    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Write-Warn "Starship already installed, skipping..."
        return
    }

    Write-Info "Installing Starship..."

    # Try winget first (Windows 11 default)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Info "  Using winget..."
        winget install --id Starship.Starship -e --accept-source-agreements --accept-package-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Starship installed via winget"
            return
        }
    }

    # Try scoop
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Info "  Using scoop..."
        scoop install starship
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Starship installed via scoop"
            return
        }
    }

    # Try chocolatey
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Info "  Using chocolatey..."
        choco install starship -y
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Starship installed via chocolatey"
            return
        }
    }

    # Manual install as fallback
    Write-Info "  Using manual installer..."
    $installerUrl = "https://starship.rs/install.ps1"
    Invoke-Expression (Invoke-WebRequest -Uri $installerUrl -UseBasicParsing).Content

    if (Get-Command starship -ErrorAction SilentlyContinue) {
        Write-Success "Starship installed"
    } else {
        Write-Warn "Starship installation may require a new terminal session"
    }
}

function Install-Profile {
    Write-Info "Installing PowerShell profile..."

    $sourceProfile = Join-Path $Script:DotfilesDir "pwsh\.config\powershell\Microsoft.PowerShell_profile.ps1"

    if (-not (Test-Path $sourceProfile)) {
        Write-Err "Source profile not found: $sourceProfile"
        exit 1
    }

    # Install for PowerShell 7+ (pwsh)
    if (Get-Command pwsh -ErrorAction SilentlyContinue) {
        Write-Info "  Installing for PowerShell 7+..."
        New-Item -ItemType Directory -Path $Script:PSCorePath -Force | Out-Null

        $dest = Join-Path $Script:PSCorePath "Microsoft.PowerShell_profile.ps1"

        # Remove existing (file or symlink)
        if (Test-Path $dest) {
            Remove-Item $dest -Force
        }

        # Create symbolic link (requires admin) or copy
        try {
            New-Item -ItemType SymbolicLink -Path $dest -Target $sourceProfile -Force | Out-Null
            Write-Success "  Created symlink for PowerShell 7+"
        } catch {
            Write-Warn "  Cannot create symlink (requires admin), copying instead..."
            Copy-Item $sourceProfile $dest -Force
            Write-Success "  Copied profile for PowerShell 7+"
        }
    }

    # Install for Windows PowerShell 5.x
    Write-Info "  Installing for Windows PowerShell 5.x..."
    New-Item -ItemType Directory -Path $Script:PS5Path -Force | Out-Null

    $dest5 = Join-Path $Script:PS5Path "Microsoft.PowerShell_profile.ps1"

    if (Test-Path $dest5) {
        Remove-Item $dest5 -Force
    }

    try {
        New-Item -ItemType SymbolicLink -Path $dest5 -Target $sourceProfile -Force | Out-Null
        Write-Success "  Created symlink for PowerShell 5.x"
    } catch {
        Copy-Item $sourceProfile $dest5 -Force
        Write-Success "  Copied profile for PowerShell 5.x"
    }
}

function Install-StarshipConfig {
    Write-Info "Installing Starship configuration..."

    $sourceConfig = Join-Path $Script:DotfilesDir "starship\.config\starship.toml"

    if (-not (Test-Path $sourceConfig)) {
        Write-Err "Source config not found: $sourceConfig"
        exit 1
    }

    # Ensure config directory exists
    New-Item -ItemType Directory -Path $Script:ConfigHome -Force | Out-Null

    $dest = Join-Path $Script:ConfigHome "starship.toml"

    if (Test-Path $dest) {
        Remove-Item $dest -Force
    }

    try {
        New-Item -ItemType SymbolicLink -Path $dest -Target $sourceConfig -Force | Out-Null
        Write-Success "Created symlink for starship.toml"
    } catch {
        Copy-Item $sourceConfig $dest -Force
        Write-Success "Copied starship.toml"
    }
}

function Install-VSCodeSettings {
    Write-Info "Installing VS Code settings..."

    $sourceDir = Join-Path $Script:DotfilesDir "vscode\.config\vscode"

    if (-not (Test-Path $sourceDir)) {
        Write-Err "Source VS Code settings not found: $sourceDir"
        return
    }

    # Ensure VS Code User directory exists
    New-Item -ItemType Directory -Path $Script:VSCodeUserPath -Force | Out-Null

    $files = @("settings.json", "keybindings.json", "extensions.json")
    foreach ($file in $files) {
        $sourceFile = Join-Path $sourceDir $file
        if (Test-Path $sourceFile) {
            $dest = Join-Path $Script:VSCodeUserPath $file

            if (Test-Path $dest) {
                Remove-Item $dest -Force
            }

            try {
                New-Item -ItemType SymbolicLink -Path $dest -Target $sourceFile -Force | Out-Null
                Write-Success "  Created symlink for VS Code $file"
            } catch {
                Copy-Item $sourceFile $dest -Force
                Write-Success "  Copied VS Code $file"
            }
        }
    }

    # Remind about extensions
    Write-Info "  To install recommended extensions, run in VS Code:"
    Write-Host "    code --install-extension enkia.tokyo-night"
}

function Install-WindowsTerminalSettings {
    Write-Info "Installing Windows Terminal settings..."

    $sourceFile = Join-Path $Script:DotfilesDir "windowsterminal\.config\windowsterminal\settings.json"

    if (-not (Test-Path $sourceFile)) {
        Write-Err "Source Windows Terminal settings not found: $sourceFile"
        return
    }

    $wtPath = Get-WindowsTerminalPath
    if (-not $wtPath) {
        Write-Warn "Windows Terminal not found, skipping..."
        return
    }

    $dest = Join-Path $wtPath "settings.json"

    if (Test-Path $dest) {
        Remove-Item $dest -Force
    }

    try {
        New-Item -ItemType SymbolicLink -Path $dest -Target $sourceFile -Force | Out-Null
        Write-Success "Created symlink for Windows Terminal settings.json"
    } catch {
        Copy-Item $sourceFile $dest -Force
        Write-Success "Copied Windows Terminal settings.json"
    }
}

function Install-NerdFont {
    Write-Info "Checking for Nerd Fonts..."

    # Check if a common Nerd Font is installed
    $fonts = [System.Drawing.Text.InstalledFontCollection]::new().Families.Name
    $nerdFonts = $fonts | Where-Object { $_ -match "Nerd|NF|Powerline" }

    if ($nerdFonts) {
        Write-Success "Nerd Font detected: $($nerdFonts[0])"
        return
    }

    Write-Warn "No Nerd Font detected. For best experience, install one:"
    Write-Host "  winget install --id=NerdFonts.CascadiaCode -e"
    Write-Host "  Or visit: https://www.nerdfonts.com/"
    Write-Host ""
}

function Show-Summary {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "    Windows Installation Complete!     " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Your previous configuration was backed up to:"
    Write-Host "  $Script:BackupDir"
    Write-Host ""
    Write-Host "Installed components:"
    Write-Host "  - PowerShell profile (PS 5.x and 7+)"
    Write-Host "  - Starship prompt with Tokyo Night theme"
    Write-Host "  - VS Code settings, keybindings, and extensions"
    Write-Host "  - Windows Terminal settings with Tokyo Night color scheme"
    Write-Host ""
    Write-Host "To restore: .\install.ps1 -Restore <timestamp>"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Restart your terminal"
    Write-Host "  2. Install a Nerd Font for icons:"
    Write-Host "     winget install --id=NerdFonts.CascadiaCode -e"
    Write-Host "  3. In VS Code, install the Tokyo Night theme:"
    Write-Host "     code --install-extension enkia.tokyo-night"
    Write-Host ""
}

# Main execution
function Main {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host "    Dotfiles Windows Installer         " -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Blue
    Write-Host ""

    # Backup first
    Backup-ExistingConfig | Out-Null

    # Install Starship
    if (-not $SkipStarship) {
        Install-Starship
    }

    # Install configs
    Install-Profile
    Install-StarshipConfig

    # Install VS Code settings
    if (-not $SkipVSCode) {
        Install-VSCodeSettings
    }

    # Install Windows Terminal settings
    if (-not $SkipTerminal) {
        Install-WindowsTerminalSettings
    }

    # Check for Nerd Fonts
    Install-NerdFont

    # Show summary
    Show-Summary
}

# Entry point
if ($Help) {
    Show-Help
    exit 0
}

if ($Backup) {
    Backup-ExistingConfig
    exit 0
}

if ($Restore -or $PSBoundParameters.ContainsKey('Restore')) {
    Restore-FromBackup -Timestamp $Restore
    exit 0
}

Main
