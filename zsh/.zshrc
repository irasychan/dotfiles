# =============================================================================
# ZSH Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# XDG Base Directory Specification
# -----------------------------------------------------------------------------
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# XDG paths for various tools
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_PREFIX="$HOME/.local/npm"
export NVM_DIR="$XDG_DATA_HOME/nvm"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# -----------------------------------------------------------------------------
# History Configuration
# -----------------------------------------------------------------------------
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# -----------------------------------------------------------------------------
# Path Configuration
# -----------------------------------------------------------------------------
typeset -U path
path=(
    "$HOME/.local/bin"
    "$HOME/.local/npm/bin"
    "$HOME/bin"
    "$CARGO_HOME/bin"
    "$GOPATH/bin"
    "/usr/local/bin"
    $path
)

# -----------------------------------------------------------------------------
# Oh My Zsh
# -----------------------------------------------------------------------------
export ZSH="$XDG_DATA_HOME/oh-my-zsh"

# Plugins (keep minimal for fast startup)
plugins=(
    git
    docker
    fzf
    z
    command-not-found
    zsh-autosuggestions
    zsh-completions
    zsh-syntax-highlighting
)

# Plugin settings
zstyle ':omz:plugins:nvm' lazy yes

# Load oh-my-zsh
source "$ZSH/oh-my-zsh.sh"

# Add zsh-completions to fpath
fpath+="${ZSH_CUSTOM:-$ZSH/custom}/plugins/zsh-completions/src"

# Completion cache
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

# -----------------------------------------------------------------------------
# Environment
# -----------------------------------------------------------------------------
# export LANG=en_US.UTF-8
# export LC_ALL=en_US.UTF-8
export EDITOR='nvim'
export VISUAL='nvim'

# GPG/SSH Agent
export GPG_TTY="$(tty)"
if command -v gpgconf &>/dev/null; then
    export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
    gpgconf --launch gpg-agent 2>/dev/null
fi

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
# Editor
alias vim='nvim'
alias v='nvim'
alias vi='nvim'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# List files
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'

# Git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate -10'

# Tools
alias lg='lazygit'
alias tm='tmux'
alias tma='tmux attach -t'
alias tmn='tmux new -s'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "Unknown archive format: $1" ;;
        esac
    else
        echo "File not found: $1"
    fi
}

# -----------------------------------------------------------------------------
# Tool Initialization (lazy load where possible)
# -----------------------------------------------------------------------------
# NVM (lazy load)
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    nvm() {
        unfunction nvm node npm npx 2>/dev/null
        source "$NVM_DIR/nvm.sh"
        nvm "$@"
    }
    node() { nvm use default &>/dev/null; command node "$@" }
    npm() { nvm use default &>/dev/null; command npm "$@" }
    npx() { nvm use default &>/dev/null; command npx "$@" }
fi


# -----------------------------------------------------------------------------
# Prompt (Starship)
# -----------------------------------------------------------------------------
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# opencode
export PATH=/home/irasy/.opencode/bin:$PATH
