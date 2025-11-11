function conda_init
    if test -d $HOME/miniconda3/bin/
        eval $HOME/miniconda3/bin/conda "shell.fish" "hook" $argv | source
    else
        echo "Conda not found"
    end
end
