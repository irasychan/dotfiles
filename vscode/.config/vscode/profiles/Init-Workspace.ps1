<#
.SYNOPSIS
    Initialize a VS Code workspace from dotfiles profile templates.

.DESCRIPTION
    Copies one or more language profiles into a project directory,
    merging them into a single .code-workspace file.

.PARAMETER ProjectDir
    Target project directory (default: current directory)

.PARAMETER Profiles
    One or more profile names (node, python, dotnet, go, rust)

.PARAMETER List
    List available profiles

.PARAMETER InstallExtensions
    Install recommended extensions without prompting

.EXAMPLE
    .\Init-Workspace.ps1 . node
    Single profile for Node.js project

.EXAMPLE
    .\Init-Workspace.ps1 . python node
    Merged workspace for fullstack project

.EXAMPLE
    .\Init-Workspace.ps1 -List
    List available profiles
#>

[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$ProjectDir = ".",

    [Parameter(Position = 1, ValueFromRemainingArguments)]
    [string[]]$Profiles,

    [switch]$List,
    [switch]$InstallExtensions
)

$ErrorActionPreference = "Stop"
$Script:ProfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Write-Info { param([string]$Msg) Write-Host "[INFO] " -ForegroundColor Blue -NoNewline; Write-Host $Msg }
function Write-Ok { param([string]$Msg) Write-Host "[OK] " -ForegroundColor Green -NoNewline; Write-Host $Msg }
function Write-Warn { param([string]$Msg) Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline; Write-Host $Msg }
function Write-Err { param([string]$Msg) Write-Host "[ERROR] " -ForegroundColor Red -NoNewline; Write-Host $Msg; exit 1 }

function Get-AvailableProfiles {
    Get-ChildItem -Path $Script:ProfilesDir -Filter "*.code-workspace" |
        ForEach-Object { $_.BaseName }
}

function Show-Profiles {
    Write-Host "Available workspace profiles:"
    Write-Host ""
    Get-AvailableProfiles | ForEach-Object { Write-Host "  $_" }
    Write-Host ""
}

function Read-WorkspaceJson {
    param([string]$Path)
    # Strip comments (// lines) then parse JSON
    $content = Get-Content -Path $Path -Raw
    $content = $content -replace '(?m)^\s*//.*$', ''
    $content | ConvertFrom-Json
}

function Merge-Profiles {
    param(
        [string]$TargetDir,
        [string[]]$ProfileNames
    )

    $projectName = Split-Path -Leaf (Resolve-Path $TargetDir)
    $workspaceFile = Join-Path $TargetDir "$projectName.code-workspace"

    $mergedSettings = [ordered]@{}
    $mergedExtensions = [System.Collections.Generic.List[string]]::new()
    $mergedSearchExclude = [ordered]@{}
    $mergedFilesExclude = [ordered]@{}

    foreach ($profile in $ProfileNames) {
        $profileFile = Join-Path $Script:ProfilesDir "$profile.code-workspace"
        if (-not (Test-Path $profileFile)) {
            $available = (Get-AvailableProfiles) -join ", "
            Write-Err "Profile not found: $profile (available: $available)"
        }

        Write-Info "Loading profile: $profile"
        $workspace = Read-WorkspaceJson -Path $profileFile
        $settings = $workspace.settings

        # Collect settings as hashtable properties
        $settings.PSObject.Properties | ForEach-Object {
            $key = $_.Name
            $value = $_.Value

            if ($key -eq "search.exclude") {
                $value.PSObject.Properties | ForEach-Object {
                    $mergedSearchExclude[$_.Name] = $_.Value
                }
            }
            elseif ($key -eq "files.exclude") {
                $value.PSObject.Properties | ForEach-Object {
                    $mergedFilesExclude[$_.Name] = $_.Value
                }
            }
            else {
                $mergedSettings[$key] = $value
            }
        }

        # Collect extensions
        if ($workspace.extensions -and $workspace.extensions.recommendations) {
            foreach ($ext in $workspace.extensions.recommendations) {
                if (-not $mergedExtensions.Contains($ext)) {
                    $mergedExtensions.Add($ext)
                }
            }
        }
    }

    # Add excludes back
    if ($mergedSearchExclude.Count -gt 0) {
        $mergedSettings["search.exclude"] = $mergedSearchExclude
    }
    if ($mergedFilesExclude.Count -gt 0) {
        $mergedSettings["files.exclude"] = $mergedFilesExclude
    }

    # Build workspace object
    $workspaceObj = [ordered]@{
        folders    = @(@{ path = "." })
        settings   = $mergedSettings
        extensions = @{ recommendations = $mergedExtensions.ToArray() }
    }

    $json = $workspaceObj | ConvertTo-Json -Depth 10
    Set-Content -Path $workspaceFile -Value $json -Encoding UTF8

    return $workspaceFile
}

function Copy-Profile {
    param(
        [string]$TargetDir,
        [string]$ProfileName
    )

    $profileFile = Join-Path $Script:ProfilesDir "$ProfileName.code-workspace"
    if (-not (Test-Path $profileFile)) {
        $available = (Get-AvailableProfiles) -join ", "
        Write-Err "Profile not found: $ProfileName (available: $available)"
    }

    $projectName = Split-Path -Leaf (Resolve-Path $TargetDir)
    $workspaceFile = Join-Path $TargetDir "$projectName.code-workspace"

    if (Test-Path $workspaceFile) {
        Write-Warn "Workspace file already exists: $workspaceFile"
        $reply = Read-Host "Overwrite? [y/N]"
        if ($reply -notmatch '^[Yy]$') {
            Write-Info "Aborted."
            exit 0
        }
    }

    Copy-Item -Path $profileFile -Destination $workspaceFile -Force
    return $workspaceFile
}

function Install-WorkspaceExtensions {
    param([string]$WorkspaceFile)

    $workspace = Read-WorkspaceJson -Path $WorkspaceFile
    if ($workspace.extensions -and $workspace.extensions.recommendations) {
        Write-Info "Installing extensions..."
        foreach ($ext in $workspace.extensions.recommendations) {
            Write-Host "  Installing $ext..."
            code --install-extension $ext --force 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-Warn "Failed to install $ext"
            }
        }
        Write-Ok "Extensions installed."
    }
}

# --- Main ---

if ($List) {
    Show-Profiles
    exit 0
}

if (-not $Profiles -or $Profiles.Count -eq 0) {
    Write-Host "Usage: Init-Workspace.ps1 <project-dir> <profile> [profile...]"
    Write-Host "       Init-Workspace.ps1 -List"
    Write-Host ""
    Write-Host "Profiles: $((Get-AvailableProfiles) -join ', ')"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  Init-Workspace.ps1 .           node          # Node.js project"
    Write-Host "  Init-Workspace.ps1 ~/myapp     python        # Python project"
    Write-Host "  Init-Workspace.ps1 .           node python   # Fullstack (merged)"
    Write-Host "  Init-Workspace.ps1 -List                     # List profiles"
    exit 1
}

if (-not (Test-Path $ProjectDir -PathType Container)) {
    Write-Err "Directory not found: $ProjectDir"
}

if ($Profiles.Count -eq 1) {
    $workspaceFile = Copy-Profile -TargetDir $ProjectDir -ProfileName $Profiles[0]
    Write-Ok "Created workspace: $workspaceFile"
    Write-Info "Open with: code `"$workspaceFile`""
}
else {
    $workspaceFile = Merge-Profiles -TargetDir $ProjectDir -ProfileNames $Profiles
    Write-Ok "Created merged workspace ($($Profiles -join ', ')): $workspaceFile"
    Write-Info "Open with: code `"$workspaceFile`""
}

# Install extensions
if ($InstallExtensions) {
    Install-WorkspaceExtensions -WorkspaceFile $workspaceFile
}
else {
    Write-Host ""
    $reply = Read-Host "Install recommended extensions now? [y/N]"
    if ($reply -match '^[Yy]$') {
        Install-WorkspaceExtensions -WorkspaceFile $workspaceFile
    }
}
