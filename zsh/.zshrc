# Uses XDG Base Directory Specification for config when available
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# AWS
export AWS_SHARED_CREDENTIALS_FILE="$XDG_CONFIG_HOME"/aws/credentials
export AWS_CONFIG_FILE="$XDG_CONFIG_HOME"/aws/config

# Docker
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GOPATH="$XDG_DATA_HOME"/go
export LESSHISTFILE="$XDG_STATE_HOME"/less/history
export MINIKUBE_HOME="$XDG_DATA_HOME"/minikube
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME"/npm/npmrc
export PYENV_ROOT="$XDG_DATA_HOME"/pyenv
export RUSTUP_HOME="$XDG_DATA_HOME"/rustup
export SDKMAN_DIR="$XDG_DATA_HOME"/sdkman

# zsh history
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export COLIMA_HOME="$HOME/.colima"

# Path configuration
export PATH=$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH
export PATH=$HOME/.local/share/solana/install/active_release/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$XDG_DATA_HOME"/oh-my-zsh

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  alias-finder
  aliases
  argocd
  asdf
  command-not-found
  docker
  docker-compose
  fzf
  git
  gpg-agent
  kubectl
  kubectx
  man
  nvm
  sdk
  ssh-agent
  tmux
  z
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)
# User configuration
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8
# export LC_ALL=C.UTF-8


# Preferred editor for local and remote sessions
#if [[ -n $SSH_CONNECTION ]]; then
#  export EDITOR='vim'
#else
#  export EDITOR='nvim'
#fi
export EDITOR='nvim'
export VISUAL='nvim'

export NVM_DIR="$XDG_DATA_HOME/nvm"

# Add zsh-completions
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh
compinit -d "$XDG_CACHE_HOME"/zsh/zcompdump-"$ZSH_VERSION"

# Command not found handler (uses command-not-found plugin on apt-based systems)

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="vim ~/.config/zsh/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias vim="nvim"
alias nv="nvim"
alias nvc="nvim ."
alias tmm="tmux new -s main"
alias og="openapi-generator"
# alias kubectl="minikube kubectl --"
alias lg="lazygit"

# XDG vim support
if [ -x "$(command -v vim)" ]; then
	[ "$(vim --clean -es +'exec "!echo" has("patch-9.1.0327")' +q)" -eq 0 ] && \
		export VIMINIT="set nocp | source ${XDG_CONFIG_HOME:-$HOME/.config}/vim/vimrc"
fi

# GPG Config
export GPG_TTY="$(tty)"          
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# PostgreSQL (uncomment and adjust path if needed)
# export PATH="/usr/lib/postgresql/15/bin:$PATH"

# SDKMAN
source "$SDKMAN_DIR/bin/sdkman-init.sh"


[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#
# Oh My Posh
if [ "$TERM_PROGRAM" != "Apple_Terminal" ] && [ "$TERM" != "xterm-color" ]; then
  # eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/tokyonight_storm.omp.json)"
  # eval "$(oh-my-posh init zsh --config $(brew --prefix oh-my-posh)/themes/jandedobbeleer.omp.json)"
  eval "$(oh-my-posh init zsh --config $XDG_CONFIG_HOME/omp/theme.omp.json)"
fi
