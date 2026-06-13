# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (nixpkgs) lib;
    in {

      lib = import ./jupyter/lib.nix { inherit lib; };

      templates = {
        default = self.templates.all-kernels;

        all-kernels = {
          path = ./templates/all-kernels;
          description = "A basic template with all available kernel types";
          welcomeText = ''
            # A basic jupyter.nix template for configuring different kernel types

            ## Customise

            Edit `flake.nix`, see the comments for the most common configuration options
            for the various kernel types available.

            ## Then start Jupyter Lab

            ```
            $ nix run
            ```
          '';
        };
      };

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          default = jupyter-ipykernel;

          jupyter-ipykernel = self.lib.makeJupyterLab {
            inherit pkgs;
            kernels = {
              "python3".ipykernel = {
                packages = pp: with pp; [
                  numpy
                  polars
                  requests
                  scipy
                ];
                withPlotly = true;
              };
            };
          };

          jupyter-ihaskell = self.lib.makeJupyterLab {
            inherit pkgs;
            kernels = {
              "Haskell".ihaskell = {
                packages = hp: with hp; [
                  aeson
                  ihaskell-aeson
                ];
                rtsOptions = [ "-M3g" "-N2" ];
              };
            };
          };
        };

        checks = {
          eval-lib = pkgs.writeText "eval-lib" (builtins.deepSeq self.lib "OK");

          reuse = pkgs.runCommand "reuse-lint" {
            nativeBuildInputs = [ pkgs.reuse ];
          } ''reuse --root ${./.} lint > "$out"'';

          builtin-kernel-types = self.lib.makeJupyterLab {
            inherit pkgs;
            kernels = {
              "kernelspec".kernelspec = {
                spec = {
                  argv = [ "echo" "hello" ];
                  display_name = "kernelspec test";
                  language = "none";
                };
              };
              "ipykernel".ipykernel = { };
              "ihaskell".ihaskell = { };
              "julia".ijulia = { };
            };
          };

          custom-dir-kernel =
            let
              dir-kernel = {
                config.outDir = self.lib.buildKernelSpec pkgs "dir-kernel" {
                  argv = [ "echo" "hello" ];
                  display_name = "kernelspec test";
                  language = "none";
                };
              };
            in
            self.lib.makeJupyterLab {
              inherit pkgs;
              kernelTypes = {
                inherit dir-kernel;
              };
              kernels = {
                "custom-dir-kernel".dir-kernel = { };
              };
            };
        };
      }
    );
}
