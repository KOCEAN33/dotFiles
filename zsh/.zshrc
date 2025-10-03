# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -n $CURSOR_TRACE_ID ]]; then
  PROMPT_EOL_MARK=""
  test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
  precmd() { print -Pn "\e]133;D;%?\a" }
  preexec() { print -Pn "\e]133;C;\a" }
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git fzf zsh-syntax-highlighting zsh-autosuggestions autojump kubectl-autocomplete zsh-abbr)

source $ZSH/oh-my-zsh.sh

# User configuration

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Homebrew Setting
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_ENV_HINTS=1
HOMEBREW_NO_VERIFY_ATTESTATIONS=1
ABBR_SET_EXPANSION_CURSOR=1
# language setting
export LANG=en_US.UTF-8

# Volta
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# Autojump
[ -f /opt/homebrew/etc/profile.d/autojump.sh ] && . /opt/homebrew/etc/profile.d/autojump.sh

# Alias
alias bu='brew update'
alias buu='brew upgrade'
alias bcu='brew cu -a -f'
alias pn='pnpm'
alias ya='yarn'
alias ls='colorls'
alias py='python3'
alias pip='pip3'
alias ku='kubectl'
alias cd='z'
alias ka='kubectl apply -f'
alias kd='kubectl delete -f'
alias ti='terraform init'
alias ta='terraform apply -auto-approve'
alias tf='terraform'
alias tp='terraform plan'
alias ktx='kubectx'
alias ga='git add .'
alias gp='git push'
alias s='ssh'
alias dc='docker compose'
alias c='cursor'
alias an="ansible"
alias k='k9s'
alias v='nvim'

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_DEFAULT_OPTS='--height 60% --layout=reverse --border'

# zoxide config
eval "$(zoxide init zsh)"

# krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# auto complete for terraform
complete -o nospace -C /opt/homebrew/bin/terraform terraform

fpath+=~/.zfunc
autoload -Uz compinit && compinit

## curl path
export PATH="/opt/homebrew/opt/curl/bin:$PATH"

# golang
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$PATH

# pnpm
export PNPM_HOME="/Users/kocean/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/kocean/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# kiro
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"