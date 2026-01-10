# SPDX-FileCopyrightText: 2026 Kirill Elagin <https://kir.elagin.me/>
#
# SPDX-License-Identifier: MPL-2.0 OR MIT

{ lib }:

rec {

  evalJupyterConfig = pkgs: config:
    lib.evalModules {
      modules = [
        { config = {
            _module.args = { inherit pkgs; };
          };
        }
        { inherit config; }
        ./modules.nix
      ];
    };

  makeJupyterLab = pkgs: config:
    (evalJupyterConfig pkgs config).config.outDrv;

}
