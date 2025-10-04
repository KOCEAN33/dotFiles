# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/exa" # brew install exa
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "wintermi/zsh-brew"
plug "romkatv/powerlevel10k"
plug "atoftegaard-git/zsh-omz-autocomplete"
plug "chrishrb/zsh-kubectl"

# Load and initialise completion system
autoload -Uz compinit
compinit
