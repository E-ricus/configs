if (which zoxide | is-not-empty) {
  zoxide init nushell | save --force ~/.cache/zoxide.nu
  source ~/.cache/zoxide.nu
}

if (which starship | is-not-empty) {
  mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
}


# Enhanced cd function with zoxide integration
def --env z [path?: string] {
    if ($path == null) {
        # No arguments - go to home directory
        cd $env.HOME
    } else if ($path | path exists) and ($path | path type) == "dir" {
        # Path exists and is a directory
        cd $path
    } else {
        # Try zoxide
        try {
            let dest = (^zoxide query $path)
            cd $dest
            print $"(char -u 'F17A9') ($env.PWD)"
        } catch {
            print "Error: Directory not found"
        }
    }
}

 # nix goodies
 def nos [] {
  sudo nixos-rebuild switch --flake $"~/configs/nix#(hostname)"
}

def nom [] {
  sudo darwin-rebuild switch --flake $"~/configs/nix#(hostname)"
}
