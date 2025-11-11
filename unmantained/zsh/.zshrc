### ENVIROMENTS
export ZSH_ENV_HOME=$HOME
export XDG_CONFIG_HOME=$HOME/.config
export ZSH_CUSTOM="$XDG_CONFIG_HOME/zsh"
export DOTFILES="$HOME/.dotfiles"

# Globals
export EDITOR="nvim"
export KUBE_EDITOR="nvim"
export FZF_DEFAULT_COMMAND='fd --type file --hidden --no-ignore'

# Alias
alias e="nvim"
alias czsh="nvim ~/.zshrc"
alias cnvim="cd $XDG_CONFIG_HOME/nvim/ && nvim"
alias ls="eza -lh --group-directories-first --icons=auto"
alias lsa="ls -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias lta="lt -a"
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
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


# MacOs only
if [[ -f "/opt/homebrew/bin/brew" ]] then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

function add_to_path() {
    if [[ -z "$1" ]]; then
        echo "Usage: add_to_path <parameter>"
        return 1
    fi

    if [[ -e "$1" ]]; then
        if [[ -d "$1" ]]; then
            export PATH="$1:$PATH"
        else
            return 1
        fi
    else
        return 1
    fi
}



# PATH
add_to_path "$HOME/.bin"
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/Applications"
add_to_path "/opt/homebrew/bin"
add_to_path "$HOME/.cargo/bin"
add_to_path "$HOME/zigup/zig-out/bin"
add_to_path "$HOME/roc"
# add_to_path "$HOME/.local/share/nvim/mason/bin"
add_to_path "$HOME/go/bin"
add_to_path "$HOME/google-cloud-sdk/bin"
add_to_path "$HOME/.local/share/coursier/bin"
add_to_path "$HOME/.ghcup/bin"
add_to_path "$HOME/.cabal/bin"
add_to_path "$HOME/Odin"
add_to_path "$HOME/swift/usr/bin"
add_to_path "$HOME/miniconda3/bin"
add_to_path "$HOME/c3c/build"
add_to_path "$HOME/.deno/bin"
add_to_path "$XDG_CONFIG_HOME/emacs/bin"
add_to_path "$HOME/.bun/bin"


#  Bun
if [[ -d "$HOME/.bun" ]]; then
    export ODIN_ROOT="$HOME/Odin"
    export BUN_INSTALL="$HOME/.bun"
fi

#  pnpm
if [[ -d "$HOME/Library/pnpm" ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
    export PATH="$HOME/Library/pnpm:$PATH"
fi

# Odin
if [[ -d "$HOME/Odin" ]]; then
    export ODIN_ROOT="$HOME/Odin"
fi

# ZVM
if [[ -d "$HOME/.zvm" ]]; then
    export ZVM_INSTALL="$HOME/.zvm/self"
    export PATH="$HOME/.zvm/self:$PATH"
    export PATH="$HOME/.zvm/bin:$PATH"
fi

# Go
if [[ -d "/usr/local/go" ]]; then
    export PATH="/usr/local/go/bin:$PATH"
fi

#Mojo
if [[ -d "$HOME/.modular" ]]; then
    export MODULAR_HOME="$HOME/.modular"
    export PATH="$HOME/.modular/bin:$PATH"
fi

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
# # TODO: Remove if it is fixed in zinit
if [[ ! -d "$ZSH_CACHE_DIR/completions" ]]; then
    mkdir -p "$ZSH_CACHE_DIR/completions"
fi
(( ${fpath[(Ie)"$ZSH_CACHE_DIR/completions"]} )) || fpath=("$ZSH_CACHE_DIR/completions" $fpath)

# Add in zsh plugins
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

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Prompt
eval "$(starship init zsh)"
# Something weird happening
# PS1="READY > "
# zi ice wait"0" lucid as"program" id-as'starship' run-atpull \
#     atinit"eval $(starship init zsh)"
# zi light zdharma-continuum/null

# Shell integrations
zi ice wait"1" lucid as"program" id-as'zoxide' run-atpull \
    atinit"source <(fzf --zsh);eval $(zoxide init zsh)"
zi light zdharma-continuum/null

# Functions
if [[ -d "$HOME/.zfuncs" ]]; then
    fpath+=("$HOME/.zfuncs")
    for funcfile in ~/.zfuncs/*.zsh; do
        source $funcfile
    done
fi

[ -f ~/.nelly_secrets ] && source ~/.nelly_secrets


# Automatically load conda and nvm, too slow for not that much use
# zi ice wait"1" lucid as"program" id-as'condainit' run-atpull \
#     atinit"condainit"
# zi light zdharma-continuum/null
# zi ice wait"1" lucid as"program" id-as'nvminit' run-atpull \
#     atinit"nvminit"
# zi light zdharma-continuum/null
#
