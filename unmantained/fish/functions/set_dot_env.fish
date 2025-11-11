function set_dot_env
    if test -z "$argv[1]"
        echo "Usage: set_dot_env <env_file_path>"
        return 1
    end
    set -l env_file $argv[1]

    for line in (grep -v '^#' $env_file)
        set -l key (echo $line | cut -d '=' -f 1)
        set -l value (echo $line | cut -d '=' -f 2-)

        # Ensure the key is a valid Fish variable name
        if string match -qr '^[a-zA-Z_][a-zA-Z0-9_]*$' -- $key
            set -gx $key $value
        else
            echo "Warning: Skipping invalid variable name '$key'"
        end
    end
end
