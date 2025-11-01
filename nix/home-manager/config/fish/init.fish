# Set greeting
set -U fish_greeting

# Globals
set -x EDITOR nvim
set -x KUBE_EDITOR nvim
set -x FZF_DEFAULT_COMMAND 'fd --type file --hidden --no-ignore'

# Vim keybindings
fish_vi_key_bindings

# Enhanced cd function
function cd --description "Enhanced cd with zoxide integration"
    if test (count $argv) -eq 0
        builtin cd ~ && return
    else if test -d $argv[1]
        builtin cd $argv[1]
    else
        z $argv && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
    end
end

# Starship prompt
if type -q starship
    starship init fish | source
end

# Zoxide integration
if type -q zoxide
    zoxide init fish | source
end

# Mise/rtx integration
if type -q mise
    mise activate fish | source
end

# Source secrets if they exist
if test -f ~/.nelly_secrets.fish
    source ~/.nelly_secrets.fish
end
