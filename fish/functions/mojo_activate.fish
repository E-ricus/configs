function mojo_activate
    set nightly 0
    if test (count $argv) -gt 0
        if test $argv[1] = "--nightly"
            set nightly 1
        end
    end

    set conda_env "mojo"
    set mojo_dir "packages.modular.com_mojo"
    set install_msg "Installing mojo"
    set install_cmd "modular install mojo"

    if test $nightly -eq 1
        set conda_env "mojo-nightly"
        set mojo_dir "packages.modular.com_nightly_mojo"
        set install_msg "Installing nightly mojo"
        set install_cmd "modular install nightly/mojo"
    end

    if not test -d "$HOME/.modular"
        echo "Modular not installed"
        return 1
    end

    conda activate $conda_env

    if test $status -ne 0
        conda create -n $conda_env python=3.10 -y; and conda activate $conda_env
    end

    if not test -d "$MODULAR_HOME/pkg/$mojo_dir/"
        echo $install_msg
        eval $install_cmd
    end

    # Fedora Only (mojo not fully supported natively) Workaround:
    # https://github.com/modularml/mojo/issues/855#issuecomment-2116834443
    # set -x LD_LIBRARY_PATH /opt/missing-mojo-deps/lib/x86_64-linux-gnu /opt/missing-mojo-deps/usr/lib/x86_64-linux-gnu $LD_LIBRARY_PATH
    add_to_path "$MODULAR_HOME/pkg/$mojo_dir/bin"
end
