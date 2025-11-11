# Conda init
function condainit() {
    __conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
            . "$HOME/miniconda3/etc/profile.d/conda.sh"
        fi
    fi
    unset __conda_setup
}

function mojo_activate() {
    local nightly=0
    if [[ "$1" == "--nightly" ]]; then
        nightly=1
    fi

    local conda_env="mojo"
    local mojo_dir="packages.modular.com_mojo"
    local install_msg="Installing mojo"
    local install_cmd="modular install mojo"

    if [[ $nightly -eq 1 ]]; then
        conda_env="mojo-nightly"
        mojo_dir="packages.modular.com_nightly_mojo"
        install_msg="Installing nightly mojo"
        install_cmd="modular install nightly/mojo"
    fi

    if [[ ! -d "$HOME/.modular" ]]; then
        echo "Modular not installed"
        return 1
    fi

    eval "conda activate $conda_env"

    if [[ ! $? -eq 0 ]]; then
        eval "conda create -n $conda_env python=3.10 -y && conda activate $conda_env"
    fi

    if [[ ! -d "$MODULAR_HOME/pkg/$mojo_dir/" ]]; then
        echo "$install_msg"
        eval "$install_cmd"
    fi

    # Fedora Only (mojo not fully supported natively) Workaround:
    # https://github.com/modularml/mojo/issues/855#issuecomment-2116834443
    # export LD_LIBRARY_PATH=/opt/missing-mojo-deps/lib/x86_64-linux-gnu:/opt/missing-mojo-deps/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH
    add_to_path "$MODULAR_HOME/pkg/$mojo_dir/bin"
}
