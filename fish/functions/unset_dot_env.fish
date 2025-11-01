function unset_dot_env
    if test -z "$argv[1]"
        echo "Usage: unset_dot_env <env_file_path>"
        return 1
    end
    set -l env_file $argv[1]
    for key in (grep -v '^#' $env_file | sed -E 's/(.*)=.*/\1/')
        if string match -qr '^[a-zA-Z_][a-zA-Z0-9_]*$' -- $key
            set -e $key
        else
            echo "Warning: Skipping invalid variable name '$key'"
        end
    end
end
