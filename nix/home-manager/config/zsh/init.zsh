# Enviroments
export ZSH_ENV_HOME=$HOME
export XDG_CONFIG_HOME=$HOME/.config
export ZSH_CUSTOM="$XDG_CONFIG_HOME/zsh"
export DOTFILES="$HOME/.dotfiles"

# Globals
export EDITOR="nvim"
export KUBE_EDITOR="nvim"
export FZF_DEFAULT_COMMAND='fd --type file --hidden --no-ignore'

# Enhanced cd with zoxide
zd() {
  if [ $# -eq 0 ]; then
    cd ~ && return
  elif [ -d "$1" ]; then
    cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}
alias cd=zd

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Fixes missing snippets
if [[ ! -d "$ZSH_CACHE_DIR/completions" ]]; then
    mkdir -p "$ZSH_CACHE_DIR/completions"
fi
(( ${fpath[(Ie)"$ZSH_CACHE_DIR/completions"]} )) || fpath=("$ZSH_CACHE_DIR/completions" $fpath)

# Add in zsh plugins (KEEPING ZINIT FOR PERFORMANCE!)
zinit wait lucid light-mode for \
  atinit"zicompinit; zicdreplay" \
      zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start" \
      zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
      zsh-users/zsh-completions

zi ice wait"1" lucid
zi load Aloxaf/fzf-tab

# Add in snippets
zi wait"2" lucid for \
    OMZP::git \
    OMZP::sudo \
    OMZP::command-not-found

if command -v kubectl &> /dev/null
then
    zi ice wait lucid
    zi snippet OMZP::kubectl
fi

# Keybindings
bindkey -v
export KEYTIMEOUT=1
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Prompt
eval "$(starship init zsh)"

# Shell integrations
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# Functions
if [[ -d "$HOME/.zfuncs" ]]; then
    fpath+=("$HOME/.zfuncs")
    for funcfile in ~/.zfuncs/*.zsh; do
        source $funcfile
    done
fi

[ -f ~/.nelly_secrets ] && source ~/.nelly_secrets
