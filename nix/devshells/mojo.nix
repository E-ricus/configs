{
  description = "Mojo development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true; # Required for CUDA
            cudaSupport = true;
          };
        };

        # Only support Linux systems for now (GPU requirements)
        isLinux = pkgs.stdenv.isLinux;

        # Determine GPU type and features
        # For NVIDIA, we need CUDA toolkit
        cudaPackages = pkgs.cudaPackages_12;

        # System libraries that pixi-installed binaries might need
        systemLibs = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          glibc
          libGL
          libGLU
          libx11
          libxext
          libxi
          libxrender
          libxrandr
          fontconfig
          freetype
          ncurses
          libbsd # Required by mojo-lldb
        ];

        # Build FHS environment for better compatibility with pixi (Linux only)
        fhsEnv =
          if isLinux
          then
            pkgs.buildFHSEnv {
              name = "mojo-gpu-env";
              targetPkgs = pkgs: (with pkgs; [
                # Core development tools
                pixi
                git
                bash
                coreutils

                # CUDA support for NVIDIA GPUs
                cudaPackages.cudatoolkit
                cudaPackages.cuda_nvcc
                cudaPackages.cuda_cudart
                cudaPackages.cuda_nvml_dev
                cudaPackages.libcublas
                cudaPackages.libcufft
                cudaPackages.libcurand
                cudaPackages.libcusparse
                cudaPackages.libcusolver
                cudaPackages.cudnn

                # Additional GPU tools
                linuxPackages.nvidia_x11 # Provides proper driver integration

                # Python (fallback, pixi will manage its own)
                python312

                # System libraries
                stdenv.cc.cc.lib
                zlib
                glibc
                libGL
                libGLU
                libx11
                libxext
                libxi
                libxrender
                libxrandr
                fontconfig
                freetype
                ncurses
                libbsd # Required by mojo-lldb

                # Development utilities
                which
                findutils
                gnugrep
                gnused
                gawk
              ]);

              profile = ''
                export CUDA_PATH=${cudaPackages.cudatoolkit}
                export CUDA_HOME=${cudaPackages.cudatoolkit}
                export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath systemLibs}:${cudaPackages.cudatoolkit}/lib:$LD_LIBRARY_PATH
                export PATH=${cudaPackages.cudatoolkit}/bin:$PATH

                # Ensure GPU is accessible
                export NVIDIA_VISIBLE_DEVICES=all
                export NVIDIA_DRIVER_CAPABILITIES=compute,utility

                # Set up environment for pixi
                export PIXI_HOME=$HOME/.pixi

                # Activate pixi environment if pixi.toml exists
                echo "Activating pixi environment..."
                # eval "$(pixi shell-hook)" NOT WORKING, run manually

                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "  Mojo GPU Development Environment"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "  CUDA Toolkit: ${cudaPackages.cudatoolkit.version}"
                echo "  Pixi: $(pixi --version)"
                echo "  Mojo: $(mojo --version 2>/dev/null | head -1 || echo 'Run pixi install first')"
                echo ""
                echo "  GPU Info:"
                nvidia-smi --query-gpu=name,compute_cap,memory.total,driver_version --format=csv 2>/dev/null || echo "    (Run 'nvidia-smi' to see GPU details)"
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
              '';

              runScript = "bash";
            }
          else throw "FHS environment is only available on Linux";
      in {
        # Default development shell using FHS environment for maximum compatibility
        devShells.default =
          if isLinux
          then fhsEnv.env
          else throw "This flake only supports Linux systems with GPUs";

        # Alternative: lighter shell without FHS (preserves your shell but may have compatibility issues)
        devShells.light = pkgs.mkShell {
          name = "mojo-gpu-light";

          buildInputs = with pkgs;
            [
              pixi
              git
              bash

              # CUDA for NVIDIA
              cudaPackages.cudatoolkit
              cudaPackages.cuda_nvcc

              # System libraries for pixi-installed binaries
            ]
            ++ systemLibs;

          shellHook = ''
            export CUDA_PATH=${cudaPackages.cudatoolkit}
            export CUDA_HOME=${cudaPackages.cudatoolkit}
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath systemLibs}:${cudaPackages.cudatoolkit}/lib:''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

            # Ensure GPU is accessible
            export NVIDIA_VISIBLE_DEVICES=all
            export NVIDIA_DRIVER_CAPABILITIES=compute,utility

            echo "Mojo (Light Shell - preserves your shell)"
            echo "CUDA: ${cudaPackages.cudatoolkit.version}"
            echo "Note: If you encounter library errors, use: nix develop"
            echo ""
            echo "Run 'pixi install' to set up the environment"
          '';
        };

        # Packages
        packages = pkgs.lib.optionalAttrs isLinux {
          # Expose the FHS environment as a package
          default = fhsEnv;
        };

        # Apps
        apps = pkgs.lib.optionalAttrs isLinux {
          # Quick access to the FHS environment
          default = {
            type = "app";
            program = "${fhsEnv}/bin/mojo-gpu-env";
          };
        };
      }
    );
}
