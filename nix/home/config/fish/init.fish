# Set greeting
set -U fish_greeting

# Globals
set -x EDITOR nvim
set -x KUBE_EDITOR nvim
set -x FZF_DEFAULT_COMMAND 'fd --type file --hidden --no-ignore'


# TODO: Integrate better with nix these
function add_to_path -a path
    if test -e $path
        fish_add_path $path
    end
end

add_to_path $HOME/.cargo/bin
# Mac annoying shit
add_to_path /opt/homebrew/bin
add_to_path /etc/profiles/per-user/ericpuentes/bin

# Vim keybindings
fish_vi_key_bindings

# Bind Tab to fzf completion (similar to fzf-tab in zsh)
# This replaces the default Tab completion with fzf
function fzf_complete
    set -l token (commandline -t)
    set -l completions (complete -C (commandline -p))
    set -l comp_count (count $completions)

    # If no completions, do nothing
    if test $comp_count -eq 0
        return
    # If only one completion, auto-complete without fzf
    else if test $comp_count -eq 1
        commandline -t -- (string trim $completions[1] | string split -f1 \t)
    # If multiple completions, use fzf
    else
        set -l result (printf '%s\n' $completions | fzf \
            --height 40% \
            --reverse \
            --query="$token" \
            --bind 'tab:down,shift-tab:up' \
            --cycle)
        if test -n "$result"
            commandline -t -- (string trim $result | string split -f1 \t)
        end
    end
    commandline -f repaint
end

# Only bind Tab in insert mode (for vi bindings)
bind -M insert \t fzf_complete
# For default/emacs mode users:
# bind \t fzf_complete

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
