# Function to add a parameter to the path if it exists
function add_to_path() {
    if [[ -z "$1" ]]; then
        echo "Usage: add_to_path <parameter>"
        return 1
    fi

    if [[ -e "$1" ]]; then
        if [[ -d "$1" ]]; then
            export PATH="$1:$PATH"
            # echo "$1 added to PATH"
        else
            # echo "$1 is not a directory"
            return 1
        fi
    else
        # echo "$1 does not exist"
        return 1
    fi
}

# Yazi wrapper
function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}
