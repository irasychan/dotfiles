export TERM=xterm-256color

# export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias aws='docker run --rm -it -v ~/.aws:/root/.aws amazon/aws-cli'

# add common shorthand aliases
alias pn='pnpm'

# start zsh
if [ -t 1 ]; then
exec zsh
fi

# SDKMan config must be at the end of file
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
