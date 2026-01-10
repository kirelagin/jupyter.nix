# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      inherit (nixpkgs) lib;
    in {

      lib = import ./jupyter/lib { inherit lib; };

    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = rec {
          jupyter = self.lib.makeJupyterLab pkgs {
            jupyterEnvPackages = pp: with pp; [
              anywidget
              plotly  # needs to be in both Python envs
            ];

            kernels = {
              "Python" = self.lib.kernels.python.mkPythonKernel {
                inherit pkgs;
                packages = pp: with pp; [
                  anywidget
                  nbconvert
                  numpy
                  pandas
                  plotly
                  polars
                  requests
                  scipy
                ];
                # TODO: allow kernel spec to add packages to jupyter env (e.g plotly)
              };
            };
          };

          default = jupyter;
        };

        checks = {
          eval-lib = pkgs.writeText "eval-lib" (builtins.deepSeq self.lib "OK");
          reuse = pkgs.runCommand "reuse-lint" {
            nativeBuildInputs = [ pkgs.reuse ];
          } ''reuse --root ${./.} lint > "$out"'';
        };
      }
    );
}
