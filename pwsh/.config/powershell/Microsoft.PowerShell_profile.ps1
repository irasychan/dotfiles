# PowerShell Profile
# Aligned with zsh/bash configuration style

#region Environment Variables

# XDG Base Directory Specification
$env:XDG_CONFIG_HOME = $env:XDG_CONFIG_HOME ?? "$HOME/.config"
$env:XDG_DATA_HOME = $env:XDG_DATA_HOME ?? "$HOME/.local/share"
$env:XDG_STATE_HOME = $env:XDG_STATE_HOME ?? "$HOME/.local/state"
$env:XDG_CACHE_HOME = $env:XDG_CACHE_HOME ?? "$HOME/.cache"

# Editor
$env:EDITOR = "nvim"
$env:VISUAL = "nvim"

# Starship config location
$env:STARSHIP_CONFIG = "$env:XDG_CONFIG_HOME/starship.toml"

#endregion

#region PSReadLine Configuration

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    # Prediction and history
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -HistoryNoDuplicates:$true
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd:$true

    # Colors - Tokyo Night theme
    Set-PSReadLineOption -Colors @{
        Command            = '#7aa2f7'  # terminal-blue
        Parameter          = '#bb9af7'  # terminal-magenta
        Operator           = '#7dcfff'  # light-sky-blue
        Variable           = '#73daca'  # terminal-green
        String             = '#9ece6a'  # pistachio-green
        Number             = '#e0af68'  # terminal-yellow
        Type               = '#bb9af7'  # terminal-magenta
        Comment            = '#565f89'  # blue-black
        Keyword            = '#bb9af7'  # terminal-magenta
        Error              = '#f7768e'  # terminal-red
        Selection          = '#414868'  # terminal-black
        InlinePrediction   = '#565f89'  # blue-black
        ListPrediction     = '#7dcfff'  # light-sky-blue
        ListPredictionSelected = '#414868'  # terminal-black
    }

    # Key bindings - Emacs style (like zsh default)
    Set-PSReadLineOption -EditMode Emacs

    # Custom key bindings
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Key Ctrl+w -Function BackwardDeleteWord
    Set-PSReadLineKeyHandler -Key Alt+d -Function DeleteWord
    Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine
    Set-PSReadLineKeyHandler -Key Ctrl+k -Function ForwardDeleteLine
    Set-PSReadLineKeyHandler -Key Ctrl+u -Function BackwardDeleteLine
}

#endregion

#region PSStyle Configuration (PowerShell 7.2+)

if ($PSVersionTable.PSVersion.Major -ge 7 -and $PSVersionTable.PSVersion.Minor -ge 2) {
    # File info formatting - Tokyo Night theme (24-bit RGB colors)
    $PSStyle.FileInfo.Directory = "`e[38;2;122;162;247m"     # #7aa2f7 terminal-blue
    $PSStyle.FileInfo.Executable = "`e[38;2;158;206;106m"    # #9ece6a pistachio-green
    $PSStyle.FileInfo.SymbolicLink = "`e[38;2;125;207;255m"  # #7dcfff light-sky-blue
}

#endregion

#region Aliases

# Navigation
Set-Alias -Name ll -Value Get-ChildItemLong
Set-Alias -Name la -Value Get-ChildItemAll
Set-Alias -Name l -Value Get-ChildItemCompact

# Editor
Set-Alias -Name vim -Value nvim -ErrorAction SilentlyContinue
Set-Alias -Name nv -Value nvim -ErrorAction SilentlyContinue
Set-Alias -Name vi -Value nvim -ErrorAction SilentlyContinue

# Git
Set-Alias -Name lg -Value lazygit -ErrorAction SilentlyContinue
Set-Alias -Name g -Value git

# Common tools
Set-Alias -Name which -Value Get-Command
Set-Alias -Name touch -Value New-Item

#endregion

#region Functions

# ls -alF equivalent
function Get-ChildItemLong {
    param([string]$Path = ".")
    Get-ChildItem -Path $Path -Force | Format-Table -AutoSize Mode, LastWriteTime, Length, Name
}

# ls -A equivalent
function Get-ChildItemAll {
    param([string]$Path = ".")
    Get-ChildItem -Path $Path -Force | Where-Object { $_.Name -notmatch '^\.$|^\.\.$' }
}

# ls -CF equivalent
function Get-ChildItemCompact {
    param([string]$Path = ".")
    Get-ChildItem -Path $Path | Format-Wide -AutoSize Name
}

# mkdir and cd
function mkcd {
    param([Parameter(Mandatory)][string]$Path)
    New-Item -ItemType Directory -Path $Path -Force | Out-Null
    Set-Location -Path $Path
}

# Quick navigation
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }

# Git shortcuts
function gs { git status }
function ga { git add $args }
function gc { git commit $args }
function gp { git push $args }
function gl { git pull $args }
function gd { git diff $args }
function gco { git checkout $args }
function gb { git branch $args }
function glog { git log --oneline --graph --decorate -20 }

# Open current directory in file explorer
function Open-Here {
    if ($IsWindows) {
        explorer.exe .
    } elseif ($IsMacOS) {
        open .
    } else {
        # WSL or Linux
        if (Get-Command explorer.exe -ErrorAction SilentlyContinue) {
            explorer.exe .
        } elseif (Get-Command xdg-open -ErrorAction SilentlyContinue) {
            xdg-open .
        }
    }
}
Set-Alias -Name open -Value Open-Here

# Reload profile
function Reload-Profile {
    . $PROFILE
    Write-Host "Profile reloaded" -ForegroundColor Green
}
Set-Alias -Name reload -Value Reload-Profile

# Get public IP
function Get-PublicIP {
    (Invoke-WebRequest -Uri "https://api.ipify.org" -UseBasicParsing).Content
}

# Quick find
function Find-File {
    param(
        [Parameter(Mandatory)][string]$Pattern,
        [string]$Path = "."
    )
    Get-ChildItem -Path $Path -Recurse -Filter $Pattern -ErrorAction SilentlyContinue
}
Set-Alias -Name ff -Value Find-File

# Quick grep
function Find-InFile {
    param(
        [Parameter(Mandatory)][string]$Pattern,
        [string]$Path = "."
    )
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
        Select-String -Pattern $Pattern
}
Set-Alias -Name grep -Value Find-InFile

#endregion

#region Completions

# Git completion (if posh-git available)
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
}

# kubectl completion
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    kubectl completion powershell | Out-String | Invoke-Expression
}

# Azure CLI completion
if (Get-Command az -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName az -ScriptBlock {
        param($commandName, $wordToComplete, $cursorPosition)
        $completion_file = New-TemporaryFile
        $env:ARGCOMPLETE_USE_TEMPFILES = 1
        $env:_ARGCOMPLETE_STDOUT_FILENAME = $completion_file
        $env:COMP_LINE = $wordToComplete
        $env:COMP_POINT = $cursorPosition
        $env:_ARGCOMPLETE = 1
        $env:_ARGCOMPLETE_SUPPRESS_SPACE = 0
        $env:_ARGCOMPLETE_IFS = "`n"
        az 2>&1 | Out-Null
        Get-Content $completion_file | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, "ParameterValue", $_)
        }
        Remove-Item $completion_file, Env:\_ARGCOMPLETE_STDOUT_FILENAME, Env:\ARGCOMPLETE_USE_TEMPFILES, Env:\COMP_LINE, Env:\COMP_POINT, Env:\_ARGCOMPLETE, Env:\_ARGCOMPLETE_SUPPRESS_SPACE, Env:\_ARGCOMPLETE_IFS -ErrorAction SilentlyContinue
    }
}

# winget completion (Windows only)
if ($IsWindows -and (Get-Command winget -ErrorAction SilentlyContinue)) {
    Register-ArgumentCompleter -Native -CommandName winget -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        [Console]::InputEncoding = [Console]::OutputEncoding = $OutputEncoding = [System.Text.Utf8Encoding]::new()
        $local:word = $wordToComplete.Replace('"', '""')
        $local:ast = $commandAst.ToString().Replace('"', '""')
        winget complete --word="$local:word" --commandline "$local:ast" --position $cursorPosition | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

# dotnet completion
if (Get-Command dotnet -ErrorAction SilentlyContinue) {
    Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
        param($wordToComplete, $commandAst, $cursorPosition)
        dotnet complete --position $cursorPosition "$commandAst" | ForEach-Object {
            [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
    }
}

#endregion

#region Starship Prompt

# Initialize Starship if available
if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}

#endregion

#region Startup

# Show a brief startup message (optional - comment out if not wanted)
# Write-Host "PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor DarkGray

#endregion
