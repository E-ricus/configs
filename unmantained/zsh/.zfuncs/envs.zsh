# Sets the enviroment variables in the given file
function set_dot_env() {
    if [[ -z "$1" ]]; then
        echo "Usage: set_dot_env <env_file_path>"
        return 1
    fi
    export $(grep -v '^#' $1 | xargs)
}

# Unses the enviroment variables in the given file
function unset_dot_env() {
    if [[ -z "$1" ]]; then
        echo "Usage: set_dot_env <env_file_path>"
        return 1
    fi
    unset $(grep -v '^#' .env | sed -E 's/(.*)=.*/\1/' | xargs)
}
