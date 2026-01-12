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
          jupyter = self.lib.makeJupyterLab {
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
